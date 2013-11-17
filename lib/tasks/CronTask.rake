require 'rake'
require 'json'

task :load_pulse_energy => :environment do
  Point.destroy_all

  dt = DateTime.now
  dt = dt.advance(:hours => -25, :minutes => -30)

  power = JSON.parse(pulseapi(50578, dt))
  radiation = JSON.parse(pulseapi(66094, dt))
  humidity = JSON.parse(pulseapi(66095, dt))
  temperature = JSON.parse(pulseapi(66077, dt))
  windspeed = JSON.parse(pulseapi(66096, dt))
  powero = []
  power['data'].each do |row|
    unless row[1].nil?
      powerv = Point.new
      powerv.date_record = DateTime.parse(row[0])
      powerv.time = Time.parse(row[0])
      powerv.consumption = row[1]
      powero.append powerv
    end
  end

  radiation['data'].each do |row|
    powero.each do |po|
      if po.date_record == DateTime.parse(row[0]) then
        po.radiation = row[1]
      end
    end
  end

  humidity['data'].each do |row|
    powero.each do |po|
      if po.date_record == DateTime.parse(row[0]) then
        po.humidity = row[1]
      end
    end
  end

  temperature['data'].each do |row|
    powero.each do |po|
      if po.date_record == DateTime.parse(row[0]) then
        po.temperature = row[1]
      end
    end
  end

  windspeed['data'].each do |row|
    powero.each do |po|
      if po.date_record == DateTime.parse(row[0]) then
        po.windspeed = row[1]
      end
    end
  end

  powero.each do |po|
    po.save
  end

end

def pulseapi(attr, time)
  key = '60777831C1AA2C232B6D4E796B4C3650'
  loc = 'https://api.pulseenergy.com/pulse/1/points/' + attr.to_s + '/data.json?key=' + key + '&interval=day&start=' + (time.iso8601)[0..-7]
  uri = URI.parse(loc)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  response.body
end