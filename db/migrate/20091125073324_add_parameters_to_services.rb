class AddParametersToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :parameters, :text
  end

  def self.down
    remove_column :services, :parameters
  end
end
