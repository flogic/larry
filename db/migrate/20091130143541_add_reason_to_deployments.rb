class AddReasonToDeployments < ActiveRecord::Migration
  def self.up
    add_column :deployments, :reason, :string
  end

  def self.down
    remove_column :deployments, :reason
  end
end
