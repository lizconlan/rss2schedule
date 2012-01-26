require 'mongo_mapper'

class Item
  include MongoMapper::Document
  many :revisions
  
  key :event_id, String
  key :rss_id, String
  key :source_file, String
  
  key :date, String
  key :title, String
  key :house, String
  key :location, String
  key :sponsor, String
  key :start_time, String
  key :end_time, String
  
  key :link, String
  key :item_type, String
  
  key :notes, String
  
  key :created_at, Date
  key :updated_at, Date
  
  #adapted from http://stackoverflow.com/questions/1648473/ruby-get-list-of-different-properties-between-objects#answer-1648547
  def diff(other)
    diffs = {}
    self.instance_variables.each do |var|
      unless var.include?("before_type_cast")
        a, b = self.instance_variable_get(var), other.instance_variable_get(var)
        diffs[var] = b if a != b and var != "@_id"
      end
    end
    return diffs
  end
  
  def store
    #update existing record or create new one
  end
end

class Revision
  include MongoMapper::EmbeddedDocument
  one :item
  
  key :date, Date
  key :event_id, String
  key :rss_id, String
  key :source_file, String
  
  key :date, String
  key :title, String
  key :house, String
  key :location, String
  key :sponsor, String
  key :start_time, String
  key :end_time, String
  
  key :link, String
  key :item_type, String
  
  key :notes, String
end