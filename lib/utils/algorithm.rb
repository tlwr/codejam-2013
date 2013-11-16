class Algorithm


  #Get two matrices X(n*5) and Y(n*1) where X is all the parameters(radiation, temp, ...) and Y the compsumption
  #Return a 6*1 matrices with all the coefficnets
  def self.compute_coefs(x, y)
    #Add an row of 1 at the beginning of each matrices for finding b0
    x = Matrix.rows(x.to_a << Array.new(x.column_count, 1))
    y = Matrix.rows(y.to_a << [1])
    ((x.transpose*x).inverse)*(x.transpose*y)
  end

  #Compute the curve using the last n points given
  def self.get_curve(value, csv)
    curve = Curve.new
    curve.value=value

    x = get_matrix_from_column(csv, [Csv::RADIATION, Csv::HUMIDITY, Csv::TEMPERATURE, Csv::WINDSPEED, CSV::Time])
    y = get_matrix_from_column(csv, [Csv::CONSUMPTION])
    coefs = compute_coefs(x, y)

    curve.coef_offset=coefs[Coef::OFFSET]
    curve.coef_radiation=coefs[Coef::RADIATION]
    curve.coef_humidity=coefs[Coef::HUMIDITY]
    curve.coef_temperature=coefs[Coef::TEMPERATURE]
    curve.coef_wind=coefs[Coef::WINDSPEED]
    curve.coef_time=coefs[Coef::TIME]
  end

  #Compute the delta of the aprox curve compared to the real one
  #The csv matrix sent needs to have n rows
  def self.compute_delta(csv, curve)
    delta = 0
    (0...csv.row_count).each do |i|
      row = curve.row(i)
      delta = (row[Csv::CONSUMPTION] - compute_consumption(row, curve)).abs
    end
  end

  #Compute the consumption using the params value and the curve
  def self.compute_consumption(row, curve)
    row[Csv::RADIATION]*curve.coef_radiation
    +row[Csv::HUMIDITY]*curve.coef_humidity
    +row[Csv::TEMPERATURE]*curve.coef_temperature
    +row[Csv::WINDSPEED]*curve.coef_wind
    +row[Csv::TIME]*curve.coef_time
    +curve.coef_offset
  end

  #Create a new matrix using only the given column
  def self.get_matrix_from_column(csv, cols)
    Matrix.columns(cols.map { |col| csv.column(col) })
  end

  #Compare two curves to say if they are similar
  def self.compare_curve(curve1, curve2)
    (curve1.coef_offset-curve2.coef_offset).abs < CoefPrecision::OFFSET and
        (curve1.coef_radiation-curve2.coef_radiation).abs < CoefPrecision::RADIATION and
        (curve1.coef_humidity-curve2.coef_humidity).abs < CoefPrecision::HUMIDITY and
        (curve1.coef_temperature-curve2.coef_temperature).abs < CoefPrecision::TEMPERATURE and
        (curve1.coef_wind-curve2.coef_wind).abs < CoefPrecision::WINDSPEED and
        (curve1.coef_time-curve2.coef_time).abs < CoefPrecision::TIME
  end

  #Get all the simmilar curves in the database to the given one
  def get_all_similar_curves(curve)
    simlar_curves = []
    Curve.all.each do |compare_curve|
      if compare_curve(curve, compare_curve)
        simlar_curves << compare_curve
      end
    end
    simlar_curves
  end

  #Get the predicated value using all the similar curve we have found
  def compute_avg_value_using_similar_curves(curve)
    result = 0
    coef = 0
    get_all_similar_curves(curve).each do |curve|
      coef += 1/curve.delta
      result += curve.value*coef
    end
    result/coef
  end
end

