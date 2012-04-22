class Stat_Array
	
   attr_accessor :name, :date_count 
   
   def initialize(name, date_count)
      @name = name
      @date_count = date_count
   end
   
   def name
     return @name
   end
   
   def count
     return @date_count.count
   end 
   
 end
 
 
 TagCountByName = Struct.new(:name, :count) 
TagCountByDate = Struct.new(:date, :count)