class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.integer :number
      t.datetime :start_time

      t.timestamps
    end
    add_index :weeks, :number, {:unique => true, :name => "weeks_number_uq"}
    add_index :weeks, :start_time, {:unique => true, :name => "weeks_start_time_uq"}
  end
end
