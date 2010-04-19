class RenameMbtaIndexes < ActiveRecord::Migration
  def self.up
    remove_index :stops, :column => :mbta_id
    remove_index :trips, :column => :mbta_id
    add_index :trips, :gtfs_id
    add_index :stops, :gtfs_id
  end

  def self.down
    remove_index :stops, :column => :gtfs_id
    remove_index :trips, :column => :gtfs_id
    add_index :trips, :mbta_id
    add_index :stops, :mbta_id
  end
end
