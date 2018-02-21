module IG
  class Service
    def initialize
      uri = URI('https://api.ig.com/gateway/deal/session')
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new uri

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json; charset=UTF-8"

        res = http.request(request, {
          "identifier" => ENV["IG_USERNAME"],
          "password" => ENV["IG_PASSWORD"]
        }.to_json)

        @cst = res.header["CST"]
        puts @cst
        @xst = res.header["X-SECURITY-TOKEN"]
        puts xst
      end
    end

    def xst
      @xst
    end

    def cst
      @cst
    end

    def deal_host
      "https://deal.ig.com"
    end

    def api_host
      "https://api.ig.com"
    end

    def get(url, options = {})
      puts "GET #{url}"
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new uri

        options[:headers].to_a.each do |key, value|
          request[key] = value
        end

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json; charset=UTF-8"
        request["Accept"] = "application/json; charset=UTF-8"
        request["X-SECURITY-TOKEN"] = options[:xst] || xst
        request["CST"] = options[:cst] || cst
        request["IG-ACCOUNT-ID"] = ENV["IG_ACCOUNT_ID"]

        # request["HOST"] = "deal.ig.com"
        # request["ORIGIN"] = "https://deal.ig.com"
        # request["Content-Length"] = "2"
        # request["ADRUM"] = "isAjax:true"
        # request["Referer"] = "https://deal.ig.com/wtp"
        # request["X-Device-User-Agent"] = "vendor=IG Group | applicationType=ig | platform=WTP | version=0.2432.0+f418e8b1"
        # request["X-Requested-With"] = "XMLHttpRequest"
        # request["Cookie"] = "ADRUM=s=1518788236992&r=https%3A%2F%2Fwww.ig.com%2Fau%2Fmyig%2Fdashboard%3F0; AMCVS_434717FE52A6476F0A490D4C%40AdobeOrg=1; _ga=GA1.2.762215792.1518788238; _gid=GA1.2.911720049.1518788238; optimizelyEndUserId=oeu1518788238646r0.6111823256002993; mbox=check#true#1518788299|session#1518788238015-22190#1518790099|PC#1518788238015-22190.17_71#1519997839; s_vi=[CS]v1|2D436F47852A268B-400001062000120A[CE]; AMCV_434717FE52A6476F0A490D4C%40AdobeOrg=1406116232%7CMCIDTS%7C17579%7CMCMID%7C71405982659753861132636702248555879879%7CMCAAMLH-1519393039%7C3%7CMCAAMB-1519393039%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1518795438s%7CNONE%7CMCAID%7C2D436F47852A268B-400001062000120A%7CMCSYNCSOP%7C411-17586%7CvVersion%7C2.5.0; adviggroupaulive=1; s_nr2=1518788241405-New; s_cvp_mktch19=%5B%5B%27OTHREF%27%2C%271518788241407%27%5D%5D; gpv_pn=ex%20nav%3Alogin; s_cc=true; s_cvp_mktch28=%5B%5B%27OTHREF%27%2C%271518788241400%27%5D%2C%5B%27OTHREF%27%2C%271518788245696%27%5D%5D; CST=e3b3e371d6d94526e2db7c0a19f13190d0f4b1e90a6dca9058cacfa44176e83101113; ID=TD=C74B1B1064B165BA3997641D1BA8074FDE8C81D6:CS=2; IG-ENVIRONMENT=PROD; X-SECURITY-TOKEN=b8634002ebd2c4963c8896b66daff70b8a2d310986d7f23ee2f88a354ebc0f3d01113; callerReqId=8b4fb819a3fbdbe5; client_id=fe0abd89e78195cfa09d68a3decdb80a; deviceOs=Other; deviceType=Desktop; exitPath=au; exitUrl=https://www.ig.com/au; sessionOpen=true; s_sq=%5B%5BB%5D%5D; session_start_time=1518788263199; wtp:session=%7B%22authenticated%22%3A%7B%22authenticator%22%3A%22authenticator%3Aplatform%22%2C%22cst%22%3A%22e3b3e371d6d94526e2db7c0a19f13190d0f4b1e90a6dca9058cacfa44176e83101113%22%2C%22xst%22%3A%22f2754438ec6095c4249bf0ee8b182631efe0171d8832cccc4a97277bafc56cfe01113%22%7D%7D; lang=en-GB"

        res = http.request(request)
        puts res.code

        JSON.parse(res.body)
      end
    end

    def watchlist(list_id)
      get("#{api_host}/gateway/deal/watchlists/#{list_id}")
    end

    def watchlists
      get("#{api_host}/gateway/deal/watchlists")
    end

    def signals
      get("#{deal_host}/signals-gateway/signalsFiltered/0/1000", 
          cst: "7071055ae70574c2d31ae09c9f2df7eab6c1a27695ae7797c0f7f0656f7b9ae501111",
          xst: "1530432c81f7a81c67605d84e21da4db93617d01811cc29a73245781246b0eb601111"
         )
    end
    
    def price(epic, start_date, end_date, page_number = 1)
      resolution = "MINUTE"

      get("#{api_host}/gateway/deal/prices/#{epic}?resolution=#{resolution}&from=#{start_date}&to=#{end_date}&pageSize=20&pageNumber=#{page_number}", headers: { "Version" => "3" })
    end

  end
end
