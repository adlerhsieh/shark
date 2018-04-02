class FxSignal < ApplicationRecord

  class DealNotFound < StandardError; end

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source
  has_many :fx_signals_positions
  has_many :fx_signals_orders
  has_many :positions, through: :fx_signals_positions
  has_many :orders, through: :fx_signals_orders

  belongs_to :pair
  belongs_to :source, class_name: "Source", optional: true

  scope :recent, -> { where("created_at > ?", (Date.today - 1.day).to_s + " 00:00:00") }

  before_create :init_evaluated_at

  def create_position(options = {})
    position = Position.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      source_id: source_id
    )
    position.tap { |pos| pos.signals << self }
  end

  def create_order(options = {})
    order = Order.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      source_id: source_id,
      expired_at: expired_at
    )
    order.tap { |o| o.signals << self }
  end

  def init_evaluated_at
    self.evaluated_at ||= Time.current
  end

  def process(options = {})
    @log = options[:log]

    case target_resource
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
        matched_order.update(deleted: true)
        matched_order.ig_remove_order
      when "create"
        order = create_order
        order.ig_place_order
      end
    when "Position"
      matched_position = Position
        .where(pair_id: pair.id, source_id: source.id)
        .where("opened_at > ?", Time.current - 1.day)
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
