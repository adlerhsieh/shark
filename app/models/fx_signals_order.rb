class FxSignalsOrder < ApplicationRecord
  belongs_to :fx_signal
  belongs_to :order
end
