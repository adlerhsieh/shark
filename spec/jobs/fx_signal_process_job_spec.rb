describe FxSignalProcessJob do

  describe "#perform" do
    let!(:fx_signal) { create(:fx_signal, :buy, :order, :create,
      expired_at: Time.now + 20.minutes) }
    
    subject { described_class.perform_now(fx_signal.id) }

    it "processes the fx_signal" do
      expect { subject }.to change { Order.count }.by(1)

      order = Order.last

      expect(order.entry).to eq(0.9)
      expect(order.take_profit).to eq(0.95)
      expect(order.stop_loss).to eq(0.85)
    end

    context "when the deal is not found" do
      let!(:fx_signal) { create(:fx_signal, :buy, :position, :close,
        expired_at: Time.now + 20.minutes) }

      before do
        allow(described_class).to receive_message_chain(:set, :perform_later)
      end

      it "enqueue the same job with the same signal id" do
        expect(described_class).to receive(:set)

        subject
      end

    end

    context "when the signal is expired" do
      let!(:fx_signal) { create(:fx_signal, :buy, :order, :create,
        expired_at: Time.now - 10.minutes) }

      it "does not process the signal" do
        expect { subject }.not_to change { Order.count }
      end
    end

  end

end
