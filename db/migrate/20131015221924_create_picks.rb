class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.integer :week
      t.integer :number
      t.belongs_to :user
      t.belongs_to :chef
      t.string :record
      t.integer :points

      t.timestamps
    end
    add_index :picks, :user_id
    add_index :picks, :chef_id
    add_index :picks, [:week, :number], {:unique => true, :name => "picks_week_num_uq"}
    add_index :picks, [:week, :chef_id, :record],
        {:unique => true, :name => "picks_week_chef_record_uq"}
    add_index :picks, [:week, :user_id, :record],
        {:unique => true, :name => "picks_week_user_record_uq"}
  end
end
