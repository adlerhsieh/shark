describe FxSignal::Generator::Fs do

  describe "#process!" do
    let!(:pair) { create(:pair, :eurusd, :mini) }
    let!(:strategy) { create(:trading_strategy) }

    let(:timestamp) { Time.current }
    let(:data) do
      "ForexSignals <https://www.forexsignals.com>"\
      "          You are\r\nfollowing nmkvijay on "\
      "ForexSignals trade room and they've just shared "\
      "a new\r\ntrade signal. \r\n nmkvijay\r\n  SHORT "\
      "EURUSD @ 1.24600 \r\n  Take Profit: 1.25600 "\
      "Stop Loss: 1.95000\r\n"
    end

    subject { described_class.new("foo").process! }

    before do
      allow_any_instance_of(Order).to receive(:ig_place_order)
      allow(Gmail::Service).to receive(:new).and_return(Gmail::ServiceStub.new)
      allow_any_instance_of(Gmail::ServiceStub).to receive(:message).and_return(
        double(
          payload: double(
            headers: [ 
              double(
                name: "Received", 
                value: "; #{timestamp}"
              )
            ],
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

    it "creates a source record" do
      expect { subject }.to change { Source.count }.by(1)

      source = Source.last

      expect(source.name).to eq("forexsignals.com")
      expect(source.username).to eq("nmkvijay")
      expect(source.active).to be_truthy
    end

    it "associates the source with a strategy" do
      expect { subject }.to change { SourcesTradingStrategy.count }.by(1)

      source = Source.last

      expect(source.sources_trading_strategies.size).to eq 1
    end

    it "creates a fx_signal record" do
      expect { subject }.to change { FxSignal.count }.by(1)

      signal = FxSignal.last

      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.pair).to eq(pair)
      expect(signal.direction).to eq("sell")
      expect(signal.entry).to eq(1.246)
      expect(signal.take_profit).to eq(1.256)
      expect(signal.stop_loss).to eq(1.95)
    end

    it "creates an order record" do
      expect { subject }.to change { Order.count }.by(1)

      order = Order.last

      expect(order.pair).to eq(pair)
      expect(order.direction).to eq("sell")
      expect(order.entry).to eq(1.246)
      expect(order.take_profit).to eq(1.256)
      expect(order.stop_loss).to eq(1.95)
    end

    context "when it does not have tp/sl" do
      let(:data) do
        "ForexSignals <https://www.forexsignals.com>"\
        "          You are\r\nfollowing nmkvijay on "\
        "ForexSignals trade room and they've just shared "\
        "a new\r\ntrade signal. \r\n nmkvijay\r\n  SHORT "\
        "EURUSD @ 1.24600 \r\n  Take Profit: 0.00000 "\
        "Stop Loss: 0.00000\r\n"
      end

      it "generates a signal" do
        expect { subject }.to change { FxSignal.count }.by(1)

        signal = FxSignal.last

        expect(signal.source_secondary_id).to eq("foo")
        expect(signal.pair).to eq(pair)
        expect(signal.direction).to eq("sell")
        expect(signal.entry).to eq(1.246)
        expect(signal.take_profit).to eq(0.0)
        expect(signal.stop_loss).to eq(0.0)
      end

      it "does not create an order record" do
        expect { subject }.to change { Order.count }.by(0)
      end
    end

  end
  
end
