# module Crawler
#
#   class WeTalkTrade < Crawler::Base
#
#     HOST = "https://signal.wetalktrade.com"
#
#     def login!
#       puts "opening page"
#       visit("/login")
#       puts "taking action"
#       fill_in "email", with: "nkj20932@hotmail.com", wait: 5, id: "username"
#       fill_in "password", with: "biohazard"
#       click_button "LOG IN", id: "LoginSubmit"
#       puts "clicked button"
#     end
#
#     def recent_signals
#       visit("/FreeSignal")
#       sleep(5)
#
#       body = Nokogiri::HTML(page.body)
#       body.xpath("//div").select do |div| 
#         div.attributes["ng-repeat"].try(:value).try(:include?, "userFreeSignal")
#       end
#     end
#
#     def process!
#       login!
#
#       recent_signals.each do |signal_element|
#         header = find_header(signal_element)
#         direction = %w[BUY SELL].find { |term| header.css("div").find {|ele| ele.text.include?(term) } }
#         title = header.css("div").find {|ele| ele.attributes["class"].try(:value).try(:include?, "title") }.try(:text)
#         source_id = header.css("div").find {|ele| ele.attributes["class"].try(:value).try(:include?, "title") }.try(:text)
#
#         raise "Direction not found" if direction.nil?
#         raise "Title not found" if title.nil?
#         raise "Source ID not found" if source_id.nil?
#         
#       end
#     end
#
#     def find_header(signal_element)
#       signal_element.children.find {|ele| ele.name == "header"}
#     end
#
#   end
#
# end
