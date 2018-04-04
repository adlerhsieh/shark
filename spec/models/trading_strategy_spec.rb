RSpec.describe TradingStrategy, type: :model do

  it { is_expected.to have_many(:sources) }

end
