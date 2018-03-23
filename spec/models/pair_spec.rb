RSpec.describe Pair, type: :model do

  it { is_expected.to have_many(:signals) }
  it { is_expected.to have_many(:positions) }
  it { is_expected.to have_many(:orders) }

  describe "#pair" do
    let(:pair) { create(:pair, :audusd, :mini) }

    subject { pair.pair }

    it { is_expected.to eq("AUD/USD MINI") }

    context "when mini is turned off" do
      subject { pair.pair(false) }

      it { is_expected.to eq("AUD/USD") }
    end

    context "when mini = nil" do
      let(:pair) { create(:pair, :audusd) }

      it { is_expected.to eq("AUD/USD") }
    end

  end

end
