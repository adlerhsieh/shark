RSpec.describe SourcesTradingStrategy, type: :model do

  it { is_expected.to belong_to(:trading_strategy) }
  it { is_expected.to belong_to(:source) }

end
