class CreateDeployables < ActiveRecord::Migration
  def self.up
    create_table :deployables, :force => true do |t|
      t.integer :instance_id
      t.text :snapshot
      t.timestamps
    end
  end

  def self.down
    drop_table :deployables
  end
end
