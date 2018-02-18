RSpec.describe Pair, type: :model do

  it { is_expected.to have_many(:signals) }

end
