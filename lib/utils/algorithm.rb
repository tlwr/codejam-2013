module Utils
  class Algorithm


    #Get two matrices X(n*5) and Y(n*1) where X is all the parameters(radiation, temp, ...) and Y the compsumption
    #Return a 6*1 matrices with all the coefficnets
    def self.compute_coefs(x, y)
      #Add an row of 1 at the beginning of each matrices for finding b0
      array = [Array.new(x.row_size, 1)]
      (0...x.column_size).each do |index|
        array.append(x.column(index))
      end
      x = Matrix.columns(array)
      ((x.transpose*x).inverse)*(x.transpose*y)
    end

    #Compute the curve using the last n points given
    def self.get_curve(csv, value=nil)
      curve = Curve.new
      curve.value=value

      x = get_matrix_from_column(csv, [Csv::RADIATION, Csv::HUMIDITY, Csv::TEMPERATURE, Csv::WINDSPEED, Csv::TIME])
      y = get_matrix_from_column(csv, [Csv::CONSUMPTION])
      coefs = compute_coefs(x, y).to_a
      curve.coef_offset=coefs[Coef::OFFSET][0]
      curve.coef_radiation=coefs[Coef::RADIATION][0]
      curve.coef_humidity=coefs[Coef::HUMIDITY][0]
      curve.coef_temperature=coefs[Coef::TEMPERATURE][0]
      curve.coef_wind=coefs[Coef::WINDSPEED][0]
      curve.coef_time=coefs[Coef::TIME][0]
      curve.delta= compute_delta(csv, curve)
      curve
    end

    #Compute the delta of the aprox curve compared to the real one
    #The csv matrix sent needs to have n rows
    def self.compute_delta(csv, curve)
      delta = 0
      (0...csv.row_size).each do |i|
        row = csv.row(i)
        delta += (row[Csv::CONSUMPTION] - compute_consumption(row, curve)).abs
      end
      delta
    end

    #Compute the consumption using the params value and the curve
    def self.compute_consumption(row, curve)
      result = row[Csv::RADIATION]*curve.coef_radiation
      result += row[Csv::HUMIDITY]*curve.coef_humidity
      result += row[Csv::TEMPERATURE]*curve.coef_temperature
      result += row[Csv::WINDSPEED]*curve.coef_wind
      result += row[Csv::TIME]*curve.coef_time
      result += curve.coef_offset
      result
    end

    #Create a new matrix using only the given column
    def self.get_matrix_from_column(csv, cols)
      csv.column(0)
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
    def self.get_all_similar_curves(csv)
      simlar_curves = {}
      Curve.all.each do |compare_curve|
        delta = compute_delta(csv, compare_curve)
        if  delta <= 4000
          simlar_curves[compare_curve] = delta
        end
      end
      simlar_curves
    end

    #Get the predicated value using all the similar curve we have found
    def self.compute_avg_value_using_similar_curves(curve, csv)
      result = 0.0
      coef = 0.0
      sim = get_all_similar_curves(csv)
      puts 'Simi:  ' + sim.size.to_s
      sim.each do |curve, delta|
        coef += 1
        result += curve.value
      end
      puts 'Coef: ' + coef.to_s
      result/coef
    end

    #Get the last rows in the matrix
    #Can specify at what point you consider the end
    def self.get_last_n_rows(csv, start = csv.row_size)
      array = []
      (1..Constant::N).each do |i|
        array << csv.row(start-i)
      end
      Matrix.rows(array)
    end

    def self.get_last_rows(csv, start = csv.row_size, nb = Constant::N)
      array = []
      (1..nb).each do |i|
        array << csv.row(start-i)
      end
      Matrix.rows(array)
    end

    #Forcast the next value in the csv using the given row_index
    def self.forcast_next_value(full_csv, row_index)
      array = [-1, 5, 10, 20, 50,90]
      coefs = 0.0
      result = 0.0
      array.each do |nb|
        begin
          value = 0.0
          coef = 0.0
          if nb == -1
            value = general_curve(full_csv.row(row_index))
            coef = 1678
          else
            csv = get_last_rows(full_csv, row_index, nb)
            curve = get_curve(csv)
            value = compute_consumption(full_csv.row(row_index), curve)
            delta = compute_delta(csv, curve)
            coef = delta/nb
          end
          coefs += 1/(Math::exp(coef))
          result += value/(Math.exp(coef))
        rescue ExceptionForMatrix::ErrNotRegular => exp
          puts ' expr not regular wtf '
        end
      end
      result/coefs
    end

    #TODO spline
    #Just basic for the moment loading the last value all the time
    def self.fill_missing_values(csv)
      array = csv.to_a
      last_set_row_index = nil
      next_set_row_index = nil
      array.each_with_index do |row, index|
        if row[Csv::RADIATION] != 0.0
          last_set_row_index = index
          break
        end
      end
      array.each_with_index do |row, index|
        if row[Csv::RADIATION]== 0.0
          (index...array.size).each do |i|
            next_row = csv.row(i)
            if next_row[Csv::RADIATION] != 0.0
              next_set_row_index = i
              break
            end
          end
          row[Csv::RADIATION] = linear_aprx(last_set_row_index, next_set_row_index, csv.row(last_set_row_index)[Csv::RADIATION], csv.row(next_set_row_index)[Csv::RADIATION], index)
          row[Csv::HUMIDITY] = linear_aprx(last_set_row_index, next_set_row_index, csv.row(last_set_row_index)[Csv::HUMIDITY], csv.row(next_set_row_index)[Csv::HUMIDITY], index)
          row[Csv::TEMPERATURE] = linear_aprx(last_set_row_index, next_set_row_index, csv.row(last_set_row_index)[Csv::TEMPERATURE], csv.row(next_set_row_index)[Csv::TEMPERATURE], index)
          row[Csv::WINDSPEED] = linear_aprx(last_set_row_index, next_set_row_index, csv.row(last_set_row_index)[Csv::WINDSPEED], csv.row(next_set_row_index)[Csv::WINDSPEED], index)
        else
          last_set_row_index = index
        end
      end
      Matrix.rows(array)
    end

    def self.linear_aprx(x1, x2, y1, y2, x)
      y1+(y2-y1)*(x-x1)/(x2-x1)
    end


    def self.time_to_f(time)
      time.sec+time.min*60+time.hour*3600
    end


    def self.csv_to_matrix(string)
      acc =[]
      CSV.parse(string) do |row|
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
      Matrix.rows(acc)
    end

    def self.general_curve(row)
      val = row[Utils::Csv::RADIATION]*6.366220067822319
      val += row[Utils::Csv::HUMIDITY]*1427.5721800736064
      val += row[Utils::Csv::TEMPERATURE]*56.918239470698005
      val += row[Utils::Csv::WINDSPEED]*-6.746236762662363
      val += row[Utils::Csv::TIME]*0.02188813826348701
      val += 14444.072665824584
    end

    def self.update_csv(csv, x, y, val)
      array = csv.to_a
      array[x][y]= val
      Matrix.rows(array)
    end
  end

end

