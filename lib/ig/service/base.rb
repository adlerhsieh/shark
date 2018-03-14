module IG

  module Service

    class NotAvailable < StandardError; end

    class Base

      DEAL_HOST = "https://deal.ig.com"

      def initialize
      end

      def authorize!
        uri = URI("#{ENV['IG_API_HOST']}/gateway/deal/session")

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          request = Net::HTTP::Post.new uri

          request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
          request["Content-Type"] = "application/json"
          request["Accept"] = "application/json; charset=UTF-8"

          res = http.request(request, {
            "identifier" => ENV["IG_USERNAME"],
            "password" => ENV["IG_PASSWORD"]
          }.to_json)
          puts res.code

          if res.code.match(/^50/)
            raise ::IG::Service::NotAvailable, "Status code: #{res.code}"
          end

          update_token!("xst", res.header["X-SECURITY-TOKEN"])
          update_token!("cst", res.header["CST"])

          @cst = res.header["CST"]
          puts @cst
          @xst = res.header["X-SECURITY-TOKEN"]
          puts @xst
        end
      end

      def xst
        Token.find_or_create_by(name: "xst", scope: "ig").token
      end

      def cst
        Token.find_or_create_by(name: "cst", scope: "ig").token
      end

      def update_token!(token_name, value)
        Token.find_or_create_by(name: token_name, scope: "ig").update(token: value)
      end

      def send_request(method, url, headers = {}, body = nil, extra_options = {})
        klass = case method 
                when :get    then Net::HTTP::Get
                when :post   then Net::HTTP::Post
                when :put    then Net::HTTP::Put
                when :delete then Net::HTTP::Delete
                end

        puts "#{method.to_s.upcase} #{url}"
        uri = URI(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          request = klass.new uri

          headers.each do |key, value|
            request[key] = value
          end

          request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
          request["Content-Type"] = "application/json; charset=UTF-8"
          request["Accept"] = "application/json; charset=UTF-8"
          request["X-SECURITY-TOKEN"] ||= xst
          request["CST"] ||= cst
          request["IG-ACCOUNT-ID"] = ENV["IG_ACCOUNT_ID"]

          http.request(request, body)
        end
      end

      def authorize_and_request(method, url, headers = {}, body = nil, extra_options = {})
        response = send_request(method, url, headers, body, extra_options)

        # Refresh token if tokens are outdated. Then send the request again.
        if response.code == "401"
          authorize! 
          response = send_request(method, url, headers, body, extra_options)
        end

        JSON.parse(response.body)
      end

      def get(path, options = {})
        authorize_and_request(:get, "#{ENV['IG_API_HOST']}/#{path}", options[:headers], options[:body])
      end

      def post(path, options)
        authorize_and_request(:post, "#{ENV['IG_API_HOST']}/#{path}", options[:headers], options[:body])
      end

      def delete(path, options)
        authorize_and_request(:delete, "#{ENV['IG_API_HOST']}/#{path}", options[:headers], options[:body])
      end

      def confirm(deal_reference)
        authorize_and_request(:get, "#{ENV["IG_API_HOST"]}/gateway/deal/confirms/#{deal_reference}", { "Version" => "1" }, nil)
      end

    end

  end

end
