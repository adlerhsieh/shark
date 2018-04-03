describe FxSignal::Generator::Pia do

  describe "#process!" do
    let!(:eurusd) { create(:pair, :eurusd, :mini) }
    let!(:gbpusd) { create(:pair, :gbpusd, :mini) }
    let(:data) do
      "\r\nPIA First - FX Majors, Thursday's Sentiment Analysis\r\n"\
      "For the purposes of our performance report, our trade ideas are "\
      "opened at an order entry time/price detailed in the email until "\
      "target, stop or 21:00 hrs for European/US sessions or 06:00 the "\
      "following day for Asian/Pacific session. Email updates between "\
      "07:00-16:00 Hrs (UK Time)\r\n\r\n\r\n\t"\
      "EURUSD - We look to Buy at 1.2345 (stop at 1.1212)\r\n\t"\
      "GBPUSD - We look to Sell at 1.4129 (stop at 1.4169)"\
      "\r\n\r\n\r\n\t\t"\
      "EURUSD -\r\n\t\t\t\t\tPosted Mixed Daily results for the last 44 days."\
      "\r\n\t\t\t\t\tLevels close to the 78.6% pullback level of 1.2470 found "\
      "sellers.\r\n\t\t\t\t\tContinued downward momentum from 1.2476 resulted in"\
      "the pair posting net daily losses yesterday.\r\n\t\t\t\t\tThe trend of "\
      "higher lows is located at 1.2280.\r\n\t\t\t\t\tThe formation has a "\
      "measured move target of 1.2155.\r\n\t\t\t\t\tRisk/Reward would be poor"\
      "to call a sell from current levels.\r\n\t\t\t\t\t"\
      "Further selling is expected to follow with the hourly Ichimoku "\
      "cloud and our bespoke resistance (1.2345) offering incentive."\
      "\r\n\t\t\t\t\r\n\t\t\t\t\tOur profit targets will be 1.5678 and 1.6789"\
      "\t\t\r\n\t\t\t\t\tConfidence Level: 65%\r\n\t\t\r\n\r\n\t\t"\
      "GBPUSD -\r\n\t\t\t\t\t2 negative daily performances in succession."\
      "\r\n\t\t\t\t\tThere is no sign that this bearish momentum is faltering "\
      "but the pair has stalled close to a previous swing low of 1.4065."\
      "\r\n\t\t\t\t\tYesterday's Marabuzo is located at 1.4121.\r\n\t\t\t\t\t"\
      "Bespoke resistance is located at 1.4129.\r\n\t\t\t\t\tPreferred trade "\
      "is to sell into rallies.\r\n\t\t\t\t\r\n\t\t\t\t\tOur profit targets "\
      "will be 1.4060 and 1.3992"\
      "\r\n\t\t\r\n\r\nRisk Warning"
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

      travel_to Time.new(2018, 10, 10, 18, 0, 0)
    end

    after do
      travel_back
    end

    it "does not raise any error" do
      expect { subject }.not_to raise_error
    end

    it "creates a source record" do
      expect { subject }.to change { Source.count }.by(1)

      source = Source.last

      expect(source.name).to eq("PIA First")
      expect(source.active).to be_truthy
    end

    it "creates 2 fx_signal records" do
      expect { subject }.to change { FxSignal.count }.by(2)
    end

    it "creates a EURUSD fx_signal record" do
      subject

      signal = FxSignal.find_by(pair_id: eurusd.id)

      expect(signal).to be_truthy
      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.pair).to eq(eurusd)
      expect(signal.direction).to eq("buy")
      expect(signal.entry).to eq(1.2345)
      expect(signal.take_profit).to eq(1.5678)
      expect(signal.stop_loss).to eq(1.1212)
      expect(signal.confidence).to eq(0.65)
      expect(signal.terminated_at).to eq(Time.new(2018, 10, 11, 21))
    end

    it "creates a GBPUSD fx_signal record" do
      subject

      signal = FxSignal.find_by(pair_id: gbpusd.id)

      expect(signal).to be_truthy
      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.pair).to eq(gbpusd)
      expect(signal.direction).to eq("sell")
      expect(signal.entry).to eq(1.4129)
      expect(signal.take_profit).to eq(1.406)
      expect(signal.stop_loss).to eq(1.4169)
    end

    it "creates an order record" do
      expect { subject }.to change { Order.count }.by(2)
    end

    context "when email including duplicate signals is received" do
      let(:process_another_email) { described_class.new("bar").process! }

      before do
        subject
      end

      it "create a blacklist email record" do
        expect { process_another_email }.to change { Blacklist::Email.count }.by(1)

        email = Blacklist::Email.last

        expect(email.source_id).to eq("bar")
      end

      it "does not create another signal record" do
        expect { process_another_email }.not_to change { FxSignal.count }
      end

    end

  end
  
end
