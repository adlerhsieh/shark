class Source < ApplicationRecord
  has_many :signals, class_name: "FxSignal", foreign_key: :source_id
  has_many :positions

  scope :active, -> { where(active: true) }
end
