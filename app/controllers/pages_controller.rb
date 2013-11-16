

class PagesController < ApplicationController
  def index
    t = Time.new
    @time = t-t.sec-t.min%15*60 + (15*60)
    @power = 20000
    @points = 128
  end

  def settings
  end

  def empty
    Curve.delete_all
    acc = []
    CSV.foreach('data_set.csv') do |row|
      m = []
      next if row[0] == 'Date'
      m[Utils::Csv::DATE] = DateTime.parse(row[0])
      m[Utils::Csv::RADIATION] = row[1]
      m[Utils::Csv::HUMIDITY] = row[2]
      m[Utils::Csv::TEMPERATURE] = row[3]
      m[Utils::Csv::WINDSPEED] = row[4]
      m[Utils::Csv::TIME] = Time.parse(row[0])
      m[Utils::Csv::CONSUMPTION] = row[5]
      acc << m
    end
    render :text => Matrix.rows(acc)
  end
end
