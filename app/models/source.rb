class Source < ApplicationRecord
  has_many :signals, class_name: "FxSignal", foreign_key: :source_id
  has_many :positions
  has_many :orders

  scope :active, -> { where(active: true) }

  # For reporting
  attr_accessor :signals_by_date, :positions_by_date, :pl

  def fullname
    "#{abbreviation || name} #{"- #{username}" if username}".squish
  end

  def all_positions
    pos = positions.includes(:pair).to_a
    pos += orders.includes(position: :pair).map { |o| o.position }
    pos += signals.includes(order: { position: :pair }).map { |s| s.order.try(:position) }
    
    pos.flatten.compact.uniq.sort_by { |position| position.created_at }.reverse
  end

end
