class CreateChefstats < ActiveRecord::Migration
  def change
    create_table :chefstats do |t|
      t.belongs_to :chef
      t.belongs_to :stat
      t.integer :week

      t.timestamps
    end
    add_index :chefstats, :chef_id
    add_index :chefstats, :stat_id
    add_index :chefstats, [:stat_id, :chef_id, :week], :unique => true
  end
end
