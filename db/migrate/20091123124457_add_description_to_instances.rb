class AddDescriptionToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :description, :text
  end

  def self.down
    remove_column :instances, :description
  end
end
