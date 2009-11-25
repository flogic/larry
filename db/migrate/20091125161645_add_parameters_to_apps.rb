class AddParametersToApps < ActiveRecord::Migration
  def self.up
    add_column :apps, :parameters, :text
  end

  def self.down
    remove_column :apps, :parameters
  end
end
