module IG
  class Price

    def initialize(price = {})
      @time = Segment.new  price["snapshotTime"]
      @open = Segment.new  price["openPrice"]
      @close = Segment.new price["closePrice"]
      @high = Segment.new  price["highPrice"]
      @low = Segment.new   price["lowPrice"]
    end

    class Segment
      attr_reader :bid, :ask

      def initialize(options = {})
        @bid = options["bid"]
        @ask = options["ask"]
      end

      def mid
        (@bid - @ask).abs
      end

    end

  end

end
