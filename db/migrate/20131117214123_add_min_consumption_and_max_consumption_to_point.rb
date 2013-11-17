class AddMinConsumptionAndMaxConsumptionToPoint < ActiveRecord::Migration
  def change
    add_column :points, :min_consumption, :float
    add_column :points, :max_consumption, :float
  end
end
