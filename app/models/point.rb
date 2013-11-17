class Point < ActiveRecord::Base

  validates_uniqueness_of :date_record

  before_save :default_values
  def default_values
    self.radiation ||= 0.0
    self.humidity ||= 0.0
    self.windspeed ||= 0.0
    self.temperature ||= 0.0
    self.consumption ||= 0.0
  end

  def self.from_row(row)
    p = Point.new
    p.date_record=row[Utils::Csv::DATE]
    p.radiation=row[Utils::Csv::RADIATION]
    p.humidity=row[Utils::Csv::HUMIDITY]
    p.windspeed=row[Utils::Csv::WINDSPEED]
    p.temperature=row[Utils::Csv::TEMPERATURE]
    p.time=row[Utils::Csv::TIME]
    p.consumption=row[Utils::Csv::CONSUMPTION]
    p
  end

  def to_a
    array = []
    array[Utils::Csv::DATE]=date_record
    array[Utils::Csv::RADIATION]=radiation
    array[Utils::Csv::HUMIDITY]=humidity
    array[Utils::Csv::TEMPERATURE]=temperature
    array[Utils::Csv::TIME]=time
    array[Utils::Csv::WINDSPEED] = windspeed
    array[Utils::Csv::CONSUMPTION]=consumption
    array
  end

  def save_if
    exi_p = Point.where(:date_record => date_record)
    if exi_p.first.nil?
      save
    elsif exi_p.first.prediction
      exi_p.first.consumption = consumption
      exi_p.first.prediction = prediction
      exi_p.first.save
    end
  end
end
