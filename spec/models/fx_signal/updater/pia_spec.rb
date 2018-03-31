describe FxSignal::Updater::Pia do

  describe "#process!" do
    let!(:audusd) { create(:pair, :audusd, :mini) }
    let!(:position) { create(:position, :buy, pair: audusd, 
      entry: 0.7663, take_profit: 0.775, stop_loss: 0.761) }
    let(:data) do
      "PIA First - UPDATE - AUDUSD - Adjusting Target and Stop\r\n"\
      "AUDUSD - The move to 0.7663 triggered our long trade "\
      "In the interest of money management, we look to move "\
      "the stop to 0.7670 and the 1st target to 0.7800.\r\n\r\n"\
      "Risk Warning"
    end

    subject { described_class.new("foo").process! }

    before do
      allow_any_instance_of(Order).to receive(:ig_place_order)
      allow(Gmail::Service).to receive(:new).and_return(Gmail::ServiceStub.new)
      allow_any_instance_of(Gmail::ServiceStub).to receive(:message).and_return(
        double(
          payload: double(
            parts: [
              double(
                body: double(
                  data: data
                )
              )
            ]
          )
        )
      )
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end

    it "creates a fx_signal record" do
      expect { subject }.to change { FxSignal.count }.by(1)
    end

    # it "creates an audit_log record" do
    #   expect { subject }.to change { AuditLog.count }.by(1)
    # end
    
    it "creates a AUDUSD fx_signal record" do
      subject

      signal = FxSignal.last

      expect(signal).to be_truthy
      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.pair).to eq(audusd)
      expect(signal.take_profit).to eq(0.78)
      expect(signal.stop_loss).to eq(0.767)
      expect(signal.target_resource).to eq("Position")
      expect(signal.action).to eq("update")
    end

    it "enqueues a job for updating position" do

    end

    context "when it moves stop to entry" do
      let(:data) do
        "PIA First - UPDATE - AUDUSD - Adjusting Stop\r\n"\
        "AUDUSD - The move to 1.3420 triggered our long trade "\
        "We now look to move stop to entry"
      end

      it "creates a AUDUSD fx_signal record accordingly" do
        subject

        signal = FxSignal.last

        expect(signal).to be_truthy
        expect(signal.stop_loss).to eq(1.342)
      end
    end

    context "when it cancels a trade idea" do
      let(:data) do
        "PIA First - UPDATE - AUDUSD - Cancel Trade Idea\r\n"\
        "AUDUSD - With the outlook no longer clearly bearish, "\
        "we look to cancel the trade idea"
      end

      it "creates a AUDUSD fx_signal record accordingly" do
        subject

        signal = FxSignal.last

        expect(signal).to be_truthy
        expect(signal.target_resource).to eq("Order")
        expect(signal.action).to eq("cancel")
      end
    end

    context "when it asks to take profit" do
      let(:data) do
        "PIA First - UPDATE - AUDUSD - Taking Some Profit\r\n"\
        "EURGBP - The move to 0.8715 triggered our long trade "\
        "The rally has posted an exhaustion count on the intraday chart "\
        "With the upside stalling we look to take some profit at "\
        "current levels 0.8735"
      end

      it "creates a AUDUSD fx_signal record accordingly" do
        subject

        signal = FxSignal.last

        expect(signal).to be_truthy
        expect(signal.target_resource).to eq("Position")
        expect(signal.action).to eq("close")
      end
    end

  end
  
end

