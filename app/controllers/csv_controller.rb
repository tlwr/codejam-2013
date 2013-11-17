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
      (0...matrix.row_size).each do |i|
        puts matrix.get_row(i)[Utils::Csv::CONSUMPTION]
      end
      puts '-----------------'
      render :text => matrix, :status => 200
    end
  end

  def local
    file = File.open('sample_input.csv')
    matrix = Utils::Algorithm::csv_to_matrix(file.read)

    render :text => get_missing_value(matrix), :status => 200
  end


  def get_missing_value(csv)
    #Remove all existing prediction
    Point.where(:prediction => true).delete_all
    vals = []
    (0...csv.row_size).each do |i|
      if csv.row(i)[Utils::Csv::CONSUMPTION] == 0.0
        array = []
        Point.order(date_record: :desc).limit(1000).each do |p|
          array.unshift(p.to_a)
        end
        array << csv.row(i).to_a
        val = Utils::Algorithm.forcast_next_value(Matrix.rows(array), array.size-1)
        puts 'last: ' + array[array.size-2][Utils::Csv::CONSUMPTION].to_s
        puts val
        p = Point::from_row(csv.row(i))
        p.consumption = val
        p.prediction = true
        p.save
        vals << val
      else
        p = Point::from_row(csv.row(i))
        exi_p = Point.where(:date_record => p.date_record)
        if exi_p.first.nil?
          p.save
        elsif exi_p.first.prediction
          exi_p.value = p.value
          exi_p.save
        end
      end
    end
    vals
  end

end