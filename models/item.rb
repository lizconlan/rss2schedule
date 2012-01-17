require 'mongo_mapper'
require 'htmlentities'

class Item
  include MongoMapper::Document
  
  key :_type, String
  key :title, String
  key :link, String
  key :categories, Array
  key :house, String
  key :location, String
  key :chamber, String
  key :subject, String
  key :date, String
  key :event_id, String
  key :author, String
  key :start_time, String
  key :end_time, String
  key :created_at, Date
end

class CommitteeItem < Item
  key :committee, String
  key :inquiry, String
  key :witnesses, String
end