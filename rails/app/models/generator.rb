module Generator
  require 'csv'
  
  def self.generate(datafile)
    path = File.join(Rails.root, 'data', datafile)

    reader = CSV.open(path, 'r') 
    header = reader.shift
    reader.each_with_index  do |row, index|
      result = yield row
      if result == false # record was not created 
        nil
      else
        puts("#{datafile}: #{index}") if index % 1000 == 0 
      end
    end
  end

  # Returns a hash of the fields fo a GTFS file
  def self.get_fields(datafile)
    path = File.join(Rails.root, 'data', datafile)
    fields = Hash.new
 
    reader = CSV.open(path, 'r')
    field_list = reader.shift

    field_list.each do |f|
      fields[f.strip.to_sym] = field_list.index(f)
    end
      
    return fields
  end  

end
