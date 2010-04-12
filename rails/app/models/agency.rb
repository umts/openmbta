class Agency < ActiveRecord::Base

  def self.links
    self.all.map { |a| a.link }.to_sentence
  end
  
  def link
    "<a href='#{url}' target='_blank'>#{name}</a>"
  end

  def acronym
    # This is a bit of a kludge, agency "name" in the GTFS could be a name or
    # just an acronym.  If it's all uppercase, we'll assume it's an acronym
    if self.name == self.name.upcase
      return self.name
    else
      acro = self.name.split.map(&:first).join.upcase
      return acro
    end
  end

  def self.populate
    file = 'agency.txt'
    fields = Generator.get_fields(file)

    Generator.generate(file) do |row|
      Agency.create :gtfs_id => (fields[:agency_id] == nil ? nil : row[fields[:agency_id]]),
                    :name    => row[fields[:agency_name]],
                    :url     => row[fields[:agency_url]],
                    :tz      => row[fields[:agency_timezone]]
    end
  end
end
