RSpec.describe FxSignal, type: :model do
  
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:positions) }
  it { is_expected.to have_many(:orders) }
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

  describe "#process" do
    let!(:signal) { create(:fx_signal, :buy, :order, :create) }

    subject { signal.process }

    before do
      allow(IG::PlaceOrderJob).to receive(:perform_later)
    end

    it "creates an order" do
      expect(IG::PlaceOrderJob).to receive(:perform_later)
      expect { subject }.to change { Order.count }.by(1)

      order = Order.last

      expect(order.entry).to eq(0.9)
      expect(order.take_profit).to eq(0.95)
      expect(order.stop_loss).to eq(0.85)
    end

    it "adds the signal to order" do
      subject

      order = Order.last
      expect(order.reload.fx_signals).to include(signal)
    end

    context "when cancelling order" do
      let!(:signal) { create(:fx_signal, :with_order, :buy, :order, :cancel) }

      before do
        allow(IG::RemoveOrderJob).to receive(:perform_later)
      end

      it "cancels the order" do
        expect(IG::RemoveOrderJob).to receive(:perform_later)

        subject

        order = Order.last
        expect(order.deleted).to be_truthy
      end

      it "adds the signal to order" do
        subject

        order = Order.last
        expect(order.reload.fx_signals).to include(signal)
      end
    end

    context "when closing a position" do
      let!(:signal) { create(:fx_signal, :with_position, :buy, :position, :close) }

      before do
        allow(IG::ClosePositionJob).to receive(:perform_later)
      end

      it "closes the position" do
        expect(IG::ClosePositionJob).to receive(:perform_later)

        subject
      end

      it "adds the signal to position" do
        subject

        position = Position.last

        expect(position.reload.fx_signals).to include(signal)
      end
    end

    context "when updating a position" do
      let!(:signal) { create(:fx_signal, :buy, :position, :update, take_profit: 1.1, stop_loss: 0.3) }
      let!(:position) { create(:position, :buy, pair: signal.pair, source: signal.source, opened_at: Time.current - 1.hour) }

      before do
        allow(IG::UpdatePositionJob).to receive(:perform_later)
      end

      it "updates the position" do
        expect(IG::UpdatePositionJob).to receive(:perform_later)

        subject

        reloaded_position = position.reload

        expect(reloaded_position.take_profit).to eq(1.1)
        expect(reloaded_position.stop_loss).to eq(0.3)
      end

      it "adds the signal to position" do
        subject

        expect(position.reload.fx_signals).to include(signal)
      end
    end

    
  end

end
