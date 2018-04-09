describe FxSignal::Generator::Premiere do

  describe "#process!" do
    let!(:nzdusd) { create(:pair, :nzdusd, :mini) }
    let!(:nzdjpy) { create(:pair, :nzdjpy, :mini) }
    let!(:chfjpy) { create(:pair, :chfjpy, :mini) }

    let(:data) do
      <<-HTML
        "<html><body><span style=\"font-family:Verdana; color:#000; font-size:10pt;\">
        <div style=\"\"><div style=\"\"><div style=\"\"><div style=\"\"><div style=\"\">
        <div style=\"font-family: verdana, geneva;\"><span mce_style=\"font-size: 8pt;\" style=\"\">Dear Members,</span></div>
        <div style=\"font-family: verdana, geneva;\"><br style=\"\"></div>
        <div style=\"font-family: verdana, geneva;\"><div style=\"\">
        <span mce_style=\"font-size: 8pt;\" style=\"\"><b style=\"\">
          Today's Educational Forex Signals are as follows:</b>
        </span></div>
        <div style=\"\"><span mce_style=\"font-size: 8pt;\" style=\"\"><b style=\"\">
          RULE: TRADE 0.1 LOTS NOT 1 LOT AS HIGH RISK ON ALL.</b></span>
        </div><div style=\"\"><span mce_style=\"font-size: 8pt;\" style=\"\">
        <b style=\"\"><br style=\"\"></b></span></div><div style=\"\">
        <span mce_style=\"font-size: 8pt;\" style=\"\"><b style=\"\"><div style=\"\">06/04/2018 |9AM</div>
        <div style=\"\">SELL NZDUSD @ 0.72527 FINAL TP 0.72193</div>
        <div style=\"\">BUY NZDJPY @ 77.869 FINAL TP 78.333</div>
        <div style=\"\">SELL CHFJPY @ 111.466 FINAL TP 111.127</div>
        </b></span></div><div style=\"\"><br style=\"\"></div><div style=\"\">******</div>
        </div></div></div></div>
        </body></html>
      HTML
    end

    subject { described_class.new("foo").process! }

    before do
      create(:trading_strategy, :constant)

      allow_any_instance_of(Order).to receive(:ig_place_order)
      allow(Gmail::Service).to receive(:new).and_return(Gmail::ServiceStub.new)
      allow_any_instance_of(Gmail::ServiceStub).to receive(:message).and_return(
        double(
          payload: double(
            body: double(
              data: data
            )
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

      expect(source.name).to eq("fxpremiere.com")
      expect(source.active).to be_truthy
    end

    it "creates 3 fx_signal records" do
      expect { subject }.to change { FxSignal.count }.by(3)
    end

    it "creates a NZDUSD fx_signal record" do
      subject

      signal = FxSignal.find_by(pair_id: nzdusd.id)

      expect(signal).to be_truthy
      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.direction).to eq("sell")
      expect(signal.entry).to eq(0.72527)
      expect(signal.take_profit).to eq(0.72193)
      expect(signal.stop_loss).to eq(0.72827)
    end

    it "creates a NZDJPY fx_signal record" do
      subject

      signal = FxSignal.find_by(pair_id: nzdjpy.id)

      expect(signal).to be_truthy
      expect(signal.source_secondary_id).to eq("foo")
      expect(signal.direction).to eq("buy")
      expect(signal.entry).to eq(77.869)
      expect(signal.take_profit).to eq(78.333)
      expect(signal.stop_loss).to eq(77.569)
    end

    it "creates 3 order records" do
      expect { subject }.to change { Order.count }.by(3)
    end

  end

end
