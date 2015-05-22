class AddTestingColumnToMigrations < ActiveRecord::Migration
  def change
    add_column :visit_metrics_entries, :testing, :boolean, default: false
  end
end
