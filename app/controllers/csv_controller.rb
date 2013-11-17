class CsvController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def upload
    file = params[:file]
    if file.nil?
      render :nothing => true, :status => 204
    elsif file.class != ActionDispatch::Http::UploadedFile
      render :nothing => true, :status => 400
    else
      matrix = Utils::Algorithm::csv_to_matrix(file.read)

      render :text => get_missing_value(matrix), :status => 200
    end
  end

  def uploadbonus
    file = params[:file]
    if file.nil?
      render :nothing => true, :status => 204
    elsif file.class != ActionDispatch::Http::UploadedFile
      render :nothing => true, :status => 400
    else
      matrix = Utils::Algorithm::csv_to_matrix(file.read)

      render :text => get_missing_value(matrix), :status => 200
    end
  end

  def local
    file = File.open('sample_input.csv')
    matrix = (Utils::Algorithm::csv_to_matrix(file.read))
    render :text => get_missing_value(matrix).join('<br/>'), :status => 200
  end


    def get_missing_value(csv)
    #Remove all existing prediction
    Point.where(:prediction => true).delete_all
    vals = []
    array = []
    Point.order(date_record: :desc).limit(1000).each do |p|
      #array.unshift(p.to_a)
    end
    (0...csv.row_size).each do |i|
      row = csv.row(i).to_a
      array << row
      last = array.size-1

      if csv.row(i)[Utils::Csv::CONSUMPTION] == 0.0
        tmp = nil
        #Forget temporaly the data
        if array[last][Utils::Csv::RADIATION] != 0.0
          tmp = array[last].clone
          array[last][Utils::Csv::RADIATION] = 0.0
          array[last][Utils::Csv::HUMIDITY] = 0.0
          array[last][Utils::Csv::TEMPERATURE] = 0.0
          array[last][Utils::Csv::WINDSPEED] = 0.0
        end
        val = Utils::Algorithm.forcast_next_value(Matrix.rows(array), last)
        array[last][Utils::Csv::CONSUMPTION] = val
        #Replace the data
        unless tmp.nil?
          array[last][Utils::Csv::RADIATION] = tmp[Utils::Csv::RADIATION]
          array[last][Utils::Csv::HUMIDITY] = tmp[Utils::Csv::HUMIDITY]
          array[last][Utils::Csv::TEMPERATURE] = tmp[Utils::Csv::TEMPERATURE]
          array[last][Utils::Csv::WINDSPEED] = tmp[Utils::Csv::WINDSPEED]
        end
        vals << val[:val].to_s
      end
    end
    vals
  end

end
