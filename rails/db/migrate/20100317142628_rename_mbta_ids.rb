class RenameMbtaIds < ActiveRecord::Migration
  def self.up
    rename_column :routes,   :mbta_id, :gtfs_id
    rename_column :services, :mbta_id, :gtfs_id
    rename_column :stops,    :mbta_id, :gtfs_id
    rename_column :trips,    :mbta_id, :gtfs_id
  end

  def self.down
    rename_column :routes,   :gtfs_id, :mbta_id 
    rename_column :services, :gtfs_id, :mbta_id 
    rename_column :stops,    :gtfs_id, :mbta_id 
    rename_column :trips,    :gtfs_id, :mbta_id 
  end
end
