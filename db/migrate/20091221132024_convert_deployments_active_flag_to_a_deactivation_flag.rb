class ConvertDeploymentsActiveFlagToADeactivationFlag < ActiveRecord::Migration
  def self.up
    rename_column :deployments, :is_active, :is_deactivated
  end

  def self.down
    rename_column :deployments, :is_deactivated, :is_active
  end
end
