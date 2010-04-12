namespace :gtfs do

  desc "populate from data files, denornmalize, massage, etc."
  task :populate => [:populate_only, :denorm, :headsigns]

  desc "populate from data files"
  task :populate_only => [:environment, 'db:migrate'] do
    [Agency, Route, Service, ServiceException, Trip, Stop, Stopping].each do |x|
      puts "Populating #{x.to_s}"
      x.populate
    end
  end

  desc "denormalization only"
  task :denorm  => :environment do
    puts "\n\nDenormalizing trips..."
    Trip.denormalize
  end

  desc "Fix nil headsigns"
  task :headsigns => :environment do
    puts "\n\nFixing nil headsigns..."
    Trip.populate_nil_headsigns
  end

end
