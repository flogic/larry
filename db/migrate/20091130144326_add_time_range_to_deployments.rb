class AddTimeRangeToDeployments < ActiveRecord::Migration
  def self.up
    add_column :deployments, :start_time, :timestamp
    add_column :deployments, :end_time, :timestamp
  end

  def self.down
    remove_column :deployments, :end_time
    remove_column :deployments, :start_time
  end
end
