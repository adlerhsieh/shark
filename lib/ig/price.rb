module IG
  class Price
     attr_reader :time, :open, :close, :high, :low

    def initialize(price = {})
      @time = parse_time(price["snapshotTimeUTC"])
      # @time = parse_time(price["snapshotTime"])
      @open = Segment.new price["openPrice"]
      @close = Segment.new price["closePrice"]
      @high = Segment.new price["highPrice"]
      @low = Segment.new price["lowPrice"]
    end

    def parse_time(t)
      Time.parse(t.gsub("T", " ") + " UTC")
      # Time.parse(t.gsub("T", " ") + " Sydney")
      # t.gsub("T", " ") << " Sydney"
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
