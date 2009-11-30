class CreateDeployedServices < ActiveRecord::Migration
  def self.up
    create_table :deployed_services, :force => true do |t|
      t.integer :host_id, :deployment_id, :service_id
      t.timestamps
    end
  end

  def self.down
    drop_table :deployed_services
  end
end
