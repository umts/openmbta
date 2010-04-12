class ServiceException < ActiveRecord::Base
  belongs_to :service

  def self.populate
    file = 'calendar_dates.txt'
    fields = Generator.get_fields(file)

    Generator.generate(file) do |row|
      service = Service.find_by_gtfs_id row[fields[:service_id]]
      next false unless service
      ServiceException.create :service => service,
        :date => Date.new(*ParseDate::parsedate(row[fields[:date]])[0,3]),
        :exception_type => row[fields[:exception_type]]
    end
  end

end
