class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name
      t.string :svalue
      t.integer :ivalue

      t.timestamps
    end
  end
end
