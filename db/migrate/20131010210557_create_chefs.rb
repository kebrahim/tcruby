class CreateChefs < ActiveRecord::Migration
  def change
    create_table :chefs do |t|
      t.string :first_name
      t.string :last_name
      t.string :abbreviation

      t.timestamps
    end
    add_index :chefs, [:first_name, :last_name], {:unique => true, :name => "chefs_name_uq"}
    add_index :chefs, [:abbreviation], {:unique => true, :name => "chefs_abbr_uq"}
  end
end
