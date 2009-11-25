class AddParametersToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :parameters, :text
  end

  def self.down
    remove_column :customers, :parameters
  end
end
