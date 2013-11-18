require 'time'
require 'net/https'
require 'uri'

class PagesController < ApplicationController
  def index
    @power = Point.where(prediction: true).order(date_record: :asc).first
    @time = @power[:date_record].advance(:hours => 1)
    raw = Point.order(date_record: :desc).limit(100).to_a
    if raw.nil? or raw.empty? then
      render :text => 'We are currently grabbing data from pulse energy, please wait'
    else
      @min = raw.first[:consumption]
      @max = raw.first[:consumption]

      @pred = Point.order(date_record: :asc).where(prediction: true).to_a.map { |m| [m[:date_record].advance(:hours => 1), m[:consumption]] }

      raw.each do |r|
        puts r[:consumption]
        if r[:consumption] > @max then
          @max = r[:consumption]
        end
        if r[:consumption] < @min then
          @min = r[:consumption]
        end
        if r[:prediction] then
          raw.delete(r)
        end
      end

      @max = @max*1.1
      @min = @min*0.9

      @graph = raw.map { |m| [m[:date_record].advance(:hours => 1), m[:consumption]] }
      @both = [{:name => 'Actual', :data => @graph}, {:name => 'Predicted', :data => @pred}]
    end
  end

  def round_to_15_minutes(t)
    rounded = Time.at((t.to_time.to_i / 900.0).round * 900)
    t.is_a?(DateTime) ? rounded.to_datetime : rounded
  end

  def set
    high = params[:settings_high]
    low = params[:settings_low]
    highwatt = Settings.find_by_name('highwatt')
    lowwatt = Settings.find_by_name('lowwatt')
    if highwatt.nil?
      highwatt = Settings.new
      highwatt.name = 'highwatt'
    end
    if lowwatt.nil?
      lowwatt = Settings.new
      lowwatt.name = 'lowwatt'
    end
    unless high.nil?
      highwatt.ivalue = high
    else
      highwatt.ivalue = 20000
    end
    unless low.nil?
      lowwatt.ivalue = low
    else
      lowwatt.ivalue = 5000
    end
    if lowwatt.ivalue > highwatt.ivalue then
      lowwatt.ivalue = 0
    end
    if lowwatt.ivalue < 0 then
      lowwatt.ivalue = 0
    end
    if highwatt.ivalue < 0 then
      highwatt.ivalue = 0
    end
    highwatt.save
    lowwatt.save
    redirect_to settings_path
  end

  def pulseapi(attr, time)
    key = '60777831C1AA2C232B6D4E796B4C3650'
    loc = 'https://api.pulseenergy.com/pulse/1/points/' + attr + '/data.json?key=' + key + '&interval=day&start=' + (time.iso8601)[0..-7]
    puts loc
    uri = URI.parse(loc)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    response.body
  end

  def empty
    Point.delete_all
    acc = []
    times = []
    CSV.foreach('data_set.csv') do |row|
      m = []
      next if row[0] == 'Date'
      m[Utils::Csv::DATE] = DateTime.parse(row[0])
      m[Utils::Csv::RADIATION] = row[1].to_f
      m[Utils::Csv::HUMIDITY] = row[2].to_f
      m[Utils::Csv::TEMPERATURE] = row[3].to_f
      m[Utils::Csv::WINDSPEED] = row[4].to_f
      m[Utils::Csv::TIME] = Utils::Algorithm::time_to_f(Time.parse(row[0]))
      times << m[Utils::Csv::TIME]
      m[Utils::Csv::CONSUMPTION] = row[5].to_f
      acc << m
    end
    full_csv = Utils::Algorithm::fill_missing_values(Matrix.rows(acc))
    #delta_c = 0
    #(Utils::Constant::N+548...full_csv.row_size).each do |index|
    #  csv = Utils::Algorithm::get_last_n_rows(full_csv, index)
    #  begin
    #  curve = Utils::Algorithm::get_curve(csv, full_csv.row(index)[Utils::Csv::CONSUMPTION])
    #  puts index.to_s  + ' - ' + curve.value.to_s
    #  if curve.delta <= Utils::Constant::MAX_DELTA
    #  curve.save
    #  else
    #    puts 'To big delta'
    #    delta_c += 1
    #  end
    #
    #  rescue ExceptionForMatrix::ErrNotRegular => error
    #    puts '===================error '
    #  end
    #end

    puts 'fill values'
    (full_csv.row_size-1000...full_csv.row_size-96).each do |row|
      #Point::from_row(full_csv.row(row)).save
    end

    render :text => times.join('<br>')

  end
end
