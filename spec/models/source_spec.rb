RSpec.describe Source, type: :model do

  it { is_expected.to have_many(:signals) }
  it { is_expected.to have_many(:positions) }
  it { is_expected.to have_many(:orders) }

  describe ".active" do
    let!(:source_a) { create(:source, :active) }
    let!(:source_b) { create(:source, :inactive) }

    subject { described_class.active }

    it "scopes correctly" do
      expect(subject).to include(source_a)
      expect(subject).not_to include(source_b)
    end
    
  end

  describe "#fullname" do
    let(:source) { create(:source, abbreviation: "ff", name: "fn") }

    subject { source.fullname }

    it { is_expected.to eq("ff") }

    context "when the source does not have a abbreviation" do
      let(:source) { create(:source, abbreviation: nil, name: "fn") }

      it { is_expected.to eq("fn") }
    end

    context "when there is username" do
      let(:source) { create(:source, abbreviation: nil, name: "fn", username: "un") }

      it { is_expected.to eq("fn - un") }
    end
    
  end

  describe "#all_positions" do
    let(:source) { create(:source) }

    let!(:position_a) { create(:position, source: source) }
    let!(:position_b) { create(:position, source: nil) }

    # associated through order
    let(:order_a) { create(:order, source: source) }
    let!(:position_c) { create(:position, source: nil, order: order_a) }

    # associated through signal
    let(:signal) { create(:fx_signal, :buy, source: source) }
    let(:order_b) { create(:order, source: nil, signal: signal) }
    let!(:position_d) { create(:position, source: nil, order: order_b) }

    subject { source.all_positions }

    it { is_expected.to include(position_a) }
    it { is_expected.not_to include(position_b) }
    it { is_expected.to include(position_c) }
    it { is_expected.to include(position_d) }
    
  end

end
