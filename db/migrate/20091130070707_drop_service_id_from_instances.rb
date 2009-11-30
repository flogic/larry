class DropServiceIdFromInstances < ActiveRecord::Migration
  def self.up
    remove_column :instances, :service_id
  end

  def self.down
    add_column :instances, :service_id, :integer
  end
end
