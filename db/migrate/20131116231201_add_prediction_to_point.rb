class AddPredictionToPoint < ActiveRecord::Migration
  def change
    add_column :points, :prediction, :boolean
  end
end
