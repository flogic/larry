class DropActiveFlagFromInstances < ActiveRecord::Migration
  def self.up
    remove_column :instances, :is_active
  end

  def self.down
    add_column :instances, :is_active, :boolean
  end
end
