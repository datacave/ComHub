class AddTimewindowsToKeywords < ActiveRecord::Migration
  def self.up
		add_column :keywords, :time_window_id, :integer
  end

  def self.down
		remove_column :keywords, :time_window_id
  end
end
