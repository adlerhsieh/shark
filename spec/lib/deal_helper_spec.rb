describe DealHelper do

  let(:klass) do
    Class.new do
      attr_accessor :direction, :opened_at, :closed_at
      include DealHelper
    end
  end

  describe "#buy?" do
    let(:deal) do 
      klass.new.tap { |obj| obj.direction = "buy" }
    end

    subject { deal.buy? }

    it { is_expected.to be_truthy }

    it "alias to long?" do
      expect(deal.long?).to be_truthy
    end

    context "when selling" do
      let(:deal) do 
        klass.new.tap { |obj| obj.direction = "sell" }
      end

      it { is_expected.to be_falsey }

      it "alias to long?" do
        expect(deal.long?).to be_falsey
      end
    end
    
  end

  describe "#sell?" do
    let(:deal) do 
      klass.new.tap { |obj| obj.direction = "buy" }
    end

    subject { deal.sell? }

    it { is_expected.to be_falsey }

    it "alias to short?" do
      expect(deal.short?).to be_falsey
    end

    context "when selling" do
      let(:deal) do 
        klass.new.tap { |obj| obj.direction = "sell" }
      end

      it { is_expected.to be_truthy }

      it "alias to short?" do
        expect(deal.short?).to be_truthy
      end
    end
    
  end

end
