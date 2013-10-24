class AddStatTypeToStats < ActiveRecord::Migration
  def change
    add_column :stats, :stat_type, :string
  end
end
