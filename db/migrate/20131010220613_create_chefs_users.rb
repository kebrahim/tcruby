class CreateChefsUsers < ActiveRecord::Migration
  def self.up
    create_table :chefs_users, :id => false do |t|
      t.integer :chef_id, :null => false
      t.integer :user_id, :null => false
    end

    # Add index to speed up looking up the connection, and ensure
    # we only assign a user to each chef once
    add_index :chefs_users, [:chef_id, :user_id], :unique => true
  end
  
  def self.down
    remove_index :chefs_users, :column => [:chef_id, :user_id]
    drop_table :chefs_users
  end
end
