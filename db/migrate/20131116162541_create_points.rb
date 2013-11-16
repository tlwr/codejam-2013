class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.date :date
      t.float :radiation
      t.float :humidity
      t.float :temperature
      t.float :windspeed
      t.time :time
      t.float :consumption

      t.timestamps
    end
  end
end
