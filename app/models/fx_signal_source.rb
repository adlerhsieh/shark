class FxSignalSource < ApplicationRecord
  has_many :signals, class_name: "FxSignal", foreign_key: :source_id
end
