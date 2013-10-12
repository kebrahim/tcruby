class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :name
      t.integer :points
      t.string :abbreviation
      t.string :short_name
      t.integer :ordinal

      t.timestamps
    end
  end
end
