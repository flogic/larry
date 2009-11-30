class UpdateDeployments < ActiveRecord::Migration
  def self.up
    add_column :deployments, :deployable_id, :integer
    remove_column :deployments, :host_id
    remove_column :deployments, :instance_id
  end

  def self.down
    add_column :deployments, :instance_id, :integer
    add_column :deployments, :host_id, :integer
    remove_column :deployments, :deployable_id
  end
end
