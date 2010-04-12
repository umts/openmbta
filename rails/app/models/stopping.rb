class Stopping < ActiveRecord::Base
  belongs_to :trip
  belongs_to :stop

  def arrival_time
    self.attributes_before_type_cast["arrival_time"]
  end
  def departure_time
    self.attributes_before_type_cast["departure_time"]
  end

  def self.populate
    # because this is a huge file
    index  = 0
    # These are for speeding up this loop by avoiding some SQL queries
    dead_trip_ids = [] 
    dead_stop_ids = []

    file = 'stop_times.txt'
    fields = Generator.get_fields(file)

    Generator.generate(file) do |row|
      index += 1
      if (index % 1000 == 0)
        puts "Row #{index/1000}K" 
        dead_trip_ids = []
        dead_stop_ids = []
      end

      next false if dead_trip_ids.include?(row[fields[:trip_id]])
      trip = Trip.find_by_gtfs_id row[fields[:trip_id]]
      if trip.nil? 
        dead_trip_ids << row[fields[:trip_id]]
        next false 
      end
      next false if dead_stop_ids.include?(row[fields[:stop_id]])
      stop = Stop.find_by_gtfs_id row[fields[:stop_id]]
      if stop.nil? 
        dead_stop_ids << row[fields[:stop_id]]
        next false
      end

      params = {:trip_id        => trip.id,
                :stop_id        => stop.id,
                :arrival_time   => row[fields[:arrival_time]],
                :departure_time => row[fields[:departure_time]],
                :position       => row[fields[:stop_sequence]]}

      # We use this raw sql creation method because Rails can't handle MySQL 
      # time type for values >= 24:00:00 (i.e., a.m. stop times)
      Stopping.raw_create params
    end
  end

  def self.raw_create(params)
    stmt = "insert into stoppings (trip_id, stop_id, arrival_time, departure_time, position) 
            values ( #{params[:trip_id]}, #{params[:stop_id]}, '#{params[:arrival_time]}',
                     '#{params[:departure_time]}', #{params[:position]}) "
    self.connection.execute(stmt)
  end

end
