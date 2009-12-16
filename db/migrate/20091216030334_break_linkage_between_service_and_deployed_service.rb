class BreakLinkageBetweenServiceAndDeployedService < ActiveRecord::Migration
  def self.up
    remove_column :deployed_services, :service_id
    add_column :deployed_services, :service_name, :string
  end

  def self.down
    remove_column :deployed_services, :service_name
    add_column :deployed_services, :service_id, :integer
  end
end
