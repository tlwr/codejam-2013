require 'rufus/scheduler'

Thread.new do
  Pulse::run
end


class Pulse

  def self.run
    puts 'running backgriund pulse'
    scheduler = Rufus::Scheduler.new
    scheduler.every '15m' do
      sleep(30)
      active = true
      puts 'Update pulse energy...'
      if active
        if Point.all.size <10
          loaddata(-32) #Load extra data the first time
        end
        loaddata(-6)
      end
      Utils::Algorithm::fill_prediction
    end
    scheduler.join
  end

  def self.loaddata(hour)
    dt = DateTime.now
    dt = dt.advance(:hours => hour, :minutes => 0)

    power = JSON.parse(pulseapi(50578, dt))
    radiation = JSON.parse(pulseapi(66094, dt))
    humidity = JSON.parse(pulseapi(66095, dt))
    temperature = JSON.parse(pulseapi(66077, dt))
    windspeed = JSON.parse(pulseapi(66096, dt))
    powero = []
    puts 'GOT DATA FROM PULSE'
    puts power['data'].size
    power['data'].each do |row|
      powerv = Point.new
      powerv.date_record = DateTime.parse(row[0])
      powerv.time = Utils::Algorithm::time_to_f(Time.parse(row[0]))
      powerv.consumption = row[1].to_f
      if row[1].nil?
        powerv.prediction=true
      else
        powerv.prediction=false
      end
      powero.append powerv
    end

    radiation['data'].each do |row|
      powero.each do |po|
        if po.date_record == DateTime.parse(row[0]) then
          po.radiation = row[1].to_f
        end
      end
    end

    humidity['data'].each do |row|
      powero.each do |po|
        if po.date_record == DateTime.parse(row[0]) then
          po.humidity = row[1].to_f
        end
      end
    end

    temperature['data'].each do |row|
      powero.each do |po|
        if po.date_record == DateTime.parse(row[0]) then
          po.temperature = row[1].to_f
        end
      end
    end

    windspeed['data'].each do |row|
      powero.each do |po|
        if po.date_record == DateTime.parse(row[0]) then
          po.windspeed = row[1].to_f
        end
      end
    end

    powero.each do |po|
      po.save_if
    end
  end

  def self.pulseapi(attr, time)
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
end