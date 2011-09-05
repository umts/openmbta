module Boat

  GTFS_ID_TO_NAME = {
    "Boat-F1" => "Hingham Boat",
    "Boat-F2" => "Quincy Boat",
    "Boat-F2(H)" => "Quincy/Hull Boat",
    "Boat-F4" => "Charlestown Ferry",
  }

  NAME_TO_GTFS_ID = GTFS_ID_TO_NAME.invert

  unless RAILS_ENV == 'test' || Route.boat.empty?
    ROUTE_ID_TO_NAME = GTFS_ID_TO_NAME.inject({}) do |memo, pair|
      gtfs_id, name = pair
      route_id = Route.find_by_gtfs_id(gtfs_id).id
      memo[route_id] = name
      memo
    end
  else
    ROUTE_ID_TO_NAME = {}
  end

  NAME_TO_ROUTE_ID = ROUTE_ID_TO_NAME.invert

  def self.routes(now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    return [] if service_ids.empty?
    results = ActiveRecord::Base.connection.select_all("select route_id, trips.first_stop, trips.last_stop, count(trips.id) as trips_remaining from trips inner join routes on routes.id = trips.route_id where routes.route_type = 4 and trips.end_time > '#{now.time}' and trips.service_id in (#{service_ids.join(',')}) group by route_id, trips.first_stop;").
      group_by {|x| ROUTE_ID_TO_NAME[x["route_id"].to_i] }.
      map { |route_name, values| { :route_short_name  =>  route_name, :headsigns => generate_headsigns(values) }}
  end

  def self.trips(options)
    now = options[:now] || Now.new
    route_gtfs_id = NAME_TO_GTFS_ID[options[:route_short_name]]

    first_stop, last_stop = headsign_to_stops(options[:headsign])
    conditions = ["routes.gtfs_id = ? and first_stop = ? and last_stop = ? and service_id in (?) and end_time > '#{now.time}'", route_gtfs_id, first_stop, last_stop, Service.ids_active_on(now.date)]
    Trip.all(:joins => :route,
             :conditions => conditions,
             :order => "start_time asc", 
             :limit => options[:limit])
  end

  def self.arrivals(stopping_id, options)
    now = options[:now] || Now.new
    route_gtfs_id = NAME_TO_GTFS_ID[options[:route_short_name]]
    first_stop, last_stop = headsign_to_stops(options[:headsign])
    conditions = ["stoppings.stop_id = ? and routes.gtfs_id = ? and first_stop = ? and last_stop = ? and service_id in (?) and stoppings.arrival_time > '#{now.time}'", 
        stopping_id, route_gtfs_id, first_stop, last_stop, Service.ids_active_on(now.date)]
    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id inner join routes on routes.id = trips.route_id",
      :conditions => conditions,
      :order => "stoppings.arrival_time asc"
    )
  end

  def self.generate_headsigns(values)
    values.map {|x| [generate_headsign(x["first_stop"], x["last_stop"]), x["trips_remaining"].to_i] }
  end

  def self.generate_headsign(first_stop, last_stop)
    "#{first_stop} to #{last_stop}"
  end

  def self.headsign_to_stops(headsign)
    first_stop, last_stop = headsign.split(" to ")
  end
end
