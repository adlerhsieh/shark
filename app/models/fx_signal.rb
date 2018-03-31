class FxSignal < ApplicationRecord

  class DealNotFound < StandardError; end

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source
  has_one :position, foreign_key: :signal_id
  has_one :order, foreign_key: :signal_id

  belongs_to :pair
  belongs_to :source, class_name: "Source", optional: true

  scope :recent, -> { where("created_at > ?", (Date.today - 1.day).to_s + " 00:00:00") }

  before_create :init_evaluated_at

  def create_position(options = {})
    Position.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      signal_id: id,
      source_id: source_id
    )
  end

  def create_order(options = {})
    Order.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      signal_id: id,
      source_id: source_id,
      expired_at: expired_at
    )
  end

  def init_evaluated_at
    self.evaluated_at ||= Time.current
  end

  def process(options = {})
    @log = options[:log]

    case target_source
    when "Order"
      case action
      when "cancel"
        matched_order = Order
          .where(pair_id: pair.id, source_id: source.id)
          .where("expired_at > ?", Time.current)
          .order(created_at: :desc)
          .first
        raise DealNotFound if matched_order.blank?
        @log.write("order ##{matched_order.id}") if @log
        order.update(deleted: true)
        order.ig_remove_order
      when "create"
        create_order
        order.ig_place_order
      end
    when "Position"
      matched_position = Position
        .where(pair_id: pair.id, source_id: source.id)
        .where("expired_at > ?", Time.current)
        .order(created_at: :desc)
        .first
      raise DealNotFound if matched_position.blank?
      @log.write("position ##{matched_position.id}") if @log
      case action
      when "close"
        matched_position.ig_close_position
      when "update"
        attrs = {
          take_profit: take_profit,
          stop_loss: stop_loss
        }.reject { |k, v| v.nil? }

        matched_position.update(attrs)
        matched_position.ig_update_tpsl
      end
    end
  end

end
