class AddReportNameToStats < ActiveRecord::Migration
  def change
    add_column :stats, :report_name, :string
  end
end
