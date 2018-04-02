RSpec.describe Position, type: :model do

  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:fx_signals) }
  it { is_expected.to belong_to(:pair) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:order) }

  describe "#profit?" do
    let(:position) { create(:position, :buy, :closed, :profit) }

    subject { position.profit? }

    it { is_expected.to be_truthy }

    context "when it's loss" do
      let(:position) { create(:position, :buy, :closed, :loss) }

      it { is_expected.to be_falsey }
    end

    context "when the position has not closed" do
      let(:position) { create(:position, :buy) }

      it { is_expected.to be_nil }
    end
  end

  describe "#loss?" do
    let(:position) { create(:position, :buy, :closed, :profit) }

    subject { position.loss? }

    it { is_expected.to be_falsey }

    context "when it's loss" do
      let(:position) { create(:position, :buy, :closed, :loss) }

      it { is_expected.to be_truthy }
    end

    context "when the position has not closed" do
      let(:position) { create(:position, :buy) }

      it { is_expected.to be_nil }
    end
  end

  describe "#opposite_direction" do
    let(:position) { create(:position, :buy) }

    subject { position.opposite_direction }

    it { is_expected.to eq("sell") }

    context "when the direction is sell" do
      let(:position) { create(:position, :sell) }

      it { is_expected.to eq("buy") }
    end
    
  end

end
