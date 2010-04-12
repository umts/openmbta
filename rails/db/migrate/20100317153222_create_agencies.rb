class CreateAgencies < ActiveRecord::Migration
  def self.up
    create_table :agencies do |t|
      t.string :gtfs_id
      t.string :name
      t.string :url
      t.string :tz
      t.string :phone
    end
  end

  def self.down
    drop_table :agencies
  end
end
