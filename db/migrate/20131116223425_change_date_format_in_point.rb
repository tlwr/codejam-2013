class ChangeDateFormatInPoint < ActiveRecord::Migration
  def change
    change_column :points, :date, :datetime
    change_column :points, :time, :float
    rename_column :points, :date, :date_record
  end
end
