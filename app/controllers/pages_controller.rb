

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
      m[Utils::Csv::RADIATION] = row[1].to_f
      m[Utils::Csv::HUMIDITY] = row[2].to_f
      m[Utils::Csv::TEMPERATURE] = row[3].to_f
      m[Utils::Csv::WINDSPEED] = row[4].to_f
      m[Utils::Csv::TIME] = Utils::Algorithm::time_to_f(Time.parse(row[0]))
      m[Utils::Csv::CONSUMPTION] = row[5].to_f
      acc << m
    end
    delta_c = 0
    full_csv = Utils::Algorithm::fill_missing_values(Matrix.rows(acc))
    (Utils::Constant::N+548...full_csv.row_size).each do |index|
      csv = Utils::Algorithm::get_last_n_rows(full_csv, index)
      begin
      curve = Utils::Algorithm::get_curve(csv, full_csv.row(index)[Utils::Csv::CONSUMPTION])
      puts index.to_s  + ' - ' + curve.value.to_s
      if curve.delta <= Utils::Constant::MAX_DELTA
      curve.save
      else
        puts 'To big delta'
        delta_c += 1
      end

      rescue ExceptionForMatrix::ErrNotRegular => error
        puts '===================error '
      end



    end

    puts delta_c


  end
end
