class CreateDraftPicks < ActiveRecord::Migration
  def change
    create_table :draft_picks do |t|
      t.string :league
      t.integer :round
      t.integer :pick
      t.belongs_to :user
      t.belongs_to :chef

      t.timestamps
    end
    add_index :draft_picks, :user_id
    add_index :draft_picks, :chef_id
  end
end
