class CsvController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def upload
    file = params[:file]
    if file.nil?
      render :nothing => true, :status => 204
    elsif file.class != ActionDispatch::Http::UploadedFile
      render :nothing => true, :status => 400
    else
      render :text => loadCsv(file.read), :status => 200
    end
  end

  def loadCsv(string)
    acc = []
    CSV.parse(string) do |row|
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
    Matrix.rows(acc)
    #TODO output
  end

end