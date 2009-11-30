class DropDestinations < ActiveRecord::Migration
  def self.up
    drop_table :destinations
  end

  def self.down
    create_table "destinations", :force => true do |t|
      t.boolean  "is_active"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
