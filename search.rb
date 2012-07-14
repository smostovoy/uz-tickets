# encoding: UTF-8
require 'uri'
require 'net/http'
require "json"

# Response Example:
#    {"value"=>
#      [{"num"=>"241О",
#        "model"=>0,
#        "from"=>
#         {"station_id"=>"2204001", "station"=>"ХАРКІВ-ПАС", "date"=>1343318580},
#        "till"=>
#         {"station_id"=>"2210770",
#          "station"=>"ЄВПАТОРІЯ-КУРОРТ",
#          "date"=>1343358600},
#        "types"=>
#         [{"type_id"=>4, "title"=>"Плацкарт", "letter"=>"П", "places"=>2}]}],
#     "error"=>false,
#     "data"=>nil}



dates = ['17.07.2012', '18.07.2012', '19.07.2012', '26.07.2012']
types = ["Плацкарт", "Купе"]
buffer = {}

loop do
  for date in dates do
    buffer[date] ||= []
    post_data = {
      station_id_from: '2204001',
      station_id_till: '2210770',
      station_from: 'Харків',
      station_till: 'Євпаторія-Курорт',
      date_start: date,
      time_from: '00:00',
      search: ''
    }
    url = URI.parse("http://booking.uz.gov.ua/purchase/search/")
    sock = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(post_data)
    resp = sock.start { |http| http.request(req) }

    res =  JSON.parse resp.body
    if !res['error']
      res['value'].each do |train|
        if train['types'].any? {|type| types.include? type['title'] }
          unless buffer[date].index train['num']
            p "Date: #{date}. Train# #{train['num']} ========  found at: #{Time.now}"
            buffer[date] << train['num']
          end
        end
      end
    end
  end
  sleep 10
end
