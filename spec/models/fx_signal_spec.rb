RSpec.describe FxSignal, type: :model do
  
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_one(:position) }
  it { is_expected.to have_one(:order) }
  it { is_expected.to belong_to(:pair) }
  it { is_expected.to belong_to(:source) }

  describe ".recent" do
    let!(:signal_a) { create(:fx_signal, created_at: Time.current - 12.hours) }
    let!(:signal_b) { create(:fx_signal, created_at: Time.current - 48.hours) }

    subject { described_class.recent }

    it { is_expected.to include(signal_a) }
    it { is_expected.not_to include(signal_b) }
  end

  describe "#create_position" do
    let(:signal) { create(:fx_signal, :buy) }

    subject { signal.create_position }

    it "creates a position" do
      expect { subject }.to change { Position.count }.by(1)

      position = Position.last

      expect(position.direction).to eq("buy")
      expect(position.entry).to eq(0.9)
    end
  end

  describe "#create_order" do
    let(:signal) { create(:fx_signal, :buy) }

    subject { signal.create_order }

    it "creates an order" do
      expect { subject }.to change { Order.count }.by(1)

      order = Order.last

      expect(order.direction).to eq("buy")
      expect(order.entry).to eq(0.9)
    end
  end

end
