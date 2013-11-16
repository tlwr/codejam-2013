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



end