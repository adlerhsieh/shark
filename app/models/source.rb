class Source < ApplicationRecord
  has_many :signals, class_name: "FxSignal", foreign_key: :source_id
  has_many :positions
  has_many :orders

  scope :active, -> { where(active: true) }

  # For reporting
  attr_accessor :signals_by_date, :positions_by_date, :pl

  def fullname
    "#{abbreviation || name} #{"- #{username[0..3]}." if username}".squish
  end

  def all_positions
    pos = positions.includes(:pair).to_a
    pos += orders.includes(position: :pair).map { |o| o.position }
    pos += signals.includes(orders: { position: :pair }).map do |s| 
      s.orders.map { |o| o.try(:position)  }
    end
    
    pos.flatten.compact.uniq.sort_by { |position| position.created_at }.reverse
  end

end
