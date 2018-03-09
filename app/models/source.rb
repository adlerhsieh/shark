class Source < ApplicationRecord
  has_many :signals, class_name: "FxSignal", foreign_key: :source_id

  scope :active, -> { where(active: true) }
end
