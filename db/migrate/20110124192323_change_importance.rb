class ChangeImportance < ActiveRecord::Migration
  def self.up
    remove_column :messages, :importance
    add_column :messages, :importance, :string
  end

  def self.down
    remove_column :messages, :importance
    add_column :messages, :importance, :integer
  end
end
