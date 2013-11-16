class CreateCurves < ActiveRecord::Migration
  def change
    create_table :curves do |t|
      t.float :value
      t.float :coef_radiation
      t.float :coef_humidity
      t.float :coef_temperature
      t.float :coef_wind
      t.float :coef_offset
      t.float :coef_time
      t.float :delta

      t.timestamps
    end
  end
end
