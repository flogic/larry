class AddParametersToDeployedServices < ActiveRecord::Migration
  def self.up
    add_column :deployed_services, :parameters, :text
  end

  def self.down
    remove_column :deployed_services, :parameters
  end
end
