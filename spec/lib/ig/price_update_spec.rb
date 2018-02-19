describe IG::PriceUpdate do

  describe "#update!" do
    let(:pair) { create(:pair, :audusd) }
    let(:time) { Time.new(2018, 1, 17, 23) }
    let(:price_list) do
      {
        "prices" => [
          {
            "snapshotTime"     => "2018/01/18 00:00:00", 
            "snapshotTimeUTC"  => "2018-01-17T13:00:00", 
            "openPrice"        => { "bid" => 0.883, "ask" => 0.884, "lastTraded" => nil }, 
            "closePrice"       => { "bid" => 0.885, "ask" => 0.886, "lastTraded" => nil }, 
            "highPrice"        => { "bid" => 0.887, "ask" => 0.888, "lastTraded" => nil }, 
            "lowPrice"         => { "bid" => 0.882, "ask" => 0.883, "lastTraded" => nil }, 
            "lastTradedVolume" => 2363
          }, 
          {
            "snapshotTime"     => "2018/01/18 01:00:00", 
            "snapshotTimeUTC"  => "2018-01-17T14:00:00", 
            "openPrice"        => { "bid" => 0.885, "ask" => 0.886, "lastTraded" => nil }, 
            "closePrice"       => { "bid" => 0.915, "ask" => 0.916, "lastTraded" => nil }, 
            "highPrice"        => { "bid" => 0.923, "ask" => 0.925, "lastTraded" => nil }, 
            "lowPrice"         => { "bid" => 0.882, "ask" => 0.883, "lastTraded" => nil }, 
            "lastTradedVolume" => 300
          }, 
          {
            "snapshotTime"     => "2018/01/18 02:00:00", 
            "snapshotTimeUTC"  => "2018-01-17T15:00:00", 
            "openPrice"        => { "bid" => 0.915, "ask" => 0.916, "lastTraded" => nil }, 
            "closePrice"       => { "bid" => 1.025, "ask" => 1.035, "lastTraded" => nil }, 
            "highPrice"        => { "bid" => 1.026, "ask" => 1.036, "lastTraded" => nil }, 
            "lowPrice"         => { "bid" => 0.900, "ask" => 0.910, "lastTraded" => nil }, 
            "lastTradedVolume" => 200
          },
          {
            "snapshotTime"     => "2018/01/18 03:00:00", 
            "snapshotTimeUTC"  => "2018-01-17T16:00:00", 
            "openPrice"        => { "bid" => 1.025, "ask" => 1.035, "lastTraded" => nil }, 
            "closePrice"       => { "bid" => 1.125, "ask" => 1.135, "lastTraded" => nil }, 
            "highPrice"        => { "bid" => 1.126, "ask" => 1.136, "lastTraded" => nil }, 
            "lowPrice"         => { "bid" => 0.900, "ask" => 0.910, "lastTraded" => nil }, 
            "lastTradedVolume" => 200
          }
        ]
      }
    end

    subject { described_class.new(price_list, fx_signal).update! }

    before do
      subject
    end

    let(:fx_signal) { create(:fx_signal, :buy, pair: pair, created_at: time,
                             entry: 0.90, take_profit: 1.00, stop_loss: 0.80) }

    it "opens position & takes profit for a long trade" do
      expect(fx_signal.reload.opened_at).to eq(Time.new(2018, 1, 18, 1, 0, 0).in_time_zone("Sydney"))
      expect(fx_signal.reload.closed).to eq(1.00)
      expect(fx_signal.reload.closed_at).to eq(Time.new(2018, 1, 18, 2, 0, 0).in_time_zone("Sydney"))
    end

    context "when the trade is short" do
      let(:fx_signal) { create(:fx_signal, :sell, pair: pair, created_at: time,
                               entry: 1.00, take_profit: 0.80, stop_loss: 1.10) }

      it "opens position & stops loss" do
        expect(fx_signal.reload.opened_at).to eq(Time.new(2018, 1, 18, 2, 0, 0).in_time_zone("Sydney"))
        expect(fx_signal.reload.closed).to eq(1.10)
        expect(fx_signal.reload.closed_at).to eq(Time.new(2018, 1, 18, 3, 0, 0).in_time_zone("Sydney"))
      end
    end

    context "when it does not reach either take profit or stop loss" do
      let(:fx_signal) { create(:fx_signal, :buy, pair: pair, created_at: time,
                               entry: 0.9, take_profit: 2.00, stop_loss: 0.10) }

      it "only fills 'opened_at'" do
        expect(fx_signal.reload.opened_at).to eq(Time.new(2018, 1, 18, 1, 0, 0).in_time_zone("Sydney"))
        expect(fx_signal.reload.closed).to be_nil
        expect(fx_signal.reload.closed_at).to be_nil
      end
    end

    context "when it never hits the entry point" do
      let(:fx_signal) { create(:fx_signal, :buy, pair: pair, created_at: time,
                               entry: 2.00, take_profit: 2.10, stop_loss: 1.90) }

      it "never opens position" do
        expect(fx_signal.reload.opened_at).to be_nil
        expect(fx_signal.reload.closed).to be_nil
        expect(fx_signal.reload.closed_at).to be_nil
      end
    end

    context "when the market is bearish" do
      let(:price_list) do
        {
          "prices" => [
            {
              "snapshotTime"     => "2018/01/18 00:00:00", 
              "snapshotTimeUTC"  => "2018-01-17T13:00:00", 
              "openPrice"        => { "bid" => 1.025, "ask" => 1.035, "lastTraded" => nil }, 
              "closePrice"       => { "bid" => 1.125, "ask" => 1.135, "lastTraded" => nil }, 
              "highPrice"        => { "bid" => 1.126, "ask" => 1.136, "lastTraded" => nil }, 
              "lowPrice"         => { "bid" => 0.900, "ask" => 0.910, "lastTraded" => nil }, 
              "lastTradedVolume" => 200
            },
            {
              "snapshotTime"     => "2018/01/18 01:00:00", 
              "snapshotTimeUTC"  => "2018-01-17T14:00:00", 
              "openPrice"        => { "bid" => 0.915, "ask" => 0.916, "lastTraded" => nil }, 
              "closePrice"       => { "bid" => 1.025, "ask" => 1.035, "lastTraded" => nil }, 
              "highPrice"        => { "bid" => 1.026, "ask" => 1.036, "lastTraded" => nil }, 
              "lowPrice"         => { "bid" => 0.900, "ask" => 0.910, "lastTraded" => nil }, 
              "lastTradedVolume" => 200
            },
            {
              "snapshotTime"     => "2018/01/18 02:00:00", 
              "snapshotTimeUTC"  => "2018-01-17T15:00:00", 
              "openPrice"        => { "bid" => 0.885, "ask" => 0.886, "lastTraded" => nil }, 
              "closePrice"       => { "bid" => 0.915, "ask" => 0.916, "lastTraded" => nil }, 
              "highPrice"        => { "bid" => 0.923, "ask" => 0.925, "lastTraded" => nil }, 
              "lowPrice"         => { "bid" => 0.882, "ask" => 0.883, "lastTraded" => nil }, 
              "lastTradedVolume" => 300
            }, 
            {
              "snapshotTime"     => "2018/01/18 03:00:00", 
              "snapshotTimeUTC"  => "2018-01-17T16:00:00", 
              "openPrice"        => { "bid" => 0.883, "ask" => 0.884, "lastTraded" => nil }, 
              "closePrice"       => { "bid" => 0.885, "ask" => 0.886, "lastTraded" => nil }, 
              "highPrice"        => { "bid" => 0.887, "ask" => 0.888, "lastTraded" => nil }, 
              "lowPrice"         => { "bid" => 0.882, "ask" => 0.883, "lastTraded" => nil }, 
              "lastTradedVolume" => 2363
            }
          ]
        }
      end

      context "when the trade is long" do
        let(:fx_signal) { create(:fx_signal, :buy, pair: pair, created_at: time,
                                 entry: 1.00, take_profit: 1.20, stop_loss: 0.888) }

        it "opens position & stops loss" do
          expect(fx_signal.reload.opened_at).to eq(Time.new(2018, 1, 18, 0, 0, 0).in_time_zone("Sydney"))
          expect(fx_signal.reload.closed).to eq(0.888)
          expect(fx_signal.reload.closed_at).to eq(Time.new(2018, 1, 18, 2, 0, 0).in_time_zone("Sydney"))
        end
      end

      context "when the trade is short" do
        let(:fx_signal) { create(:fx_signal, :sell, pair: pair, created_at: time,
                                 entry: 1.00, take_profit: 0.888, stop_loss: 1.20) }

        it "opens position & takes profit" do
          expect(fx_signal.reload.opened_at).to eq(Time.new(2018, 1, 18, 0, 0, 0).in_time_zone("Sydney"))
          expect(fx_signal.reload.closed).to eq(0.888)
          expect(fx_signal.reload.closed_at).to eq(Time.new(2018, 1, 18, 2, 0, 0).in_time_zone("Sydney"))
        end
      end
    end

  end

end
