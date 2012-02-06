# encoding: utf-8

require 'mongo_mapper'

class Item
  include MongoMapper::Document
  many :revisions
  
  key :event_id, String
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
      unless var.to_s.include?("before_type_cast")
        a, b = self.instance_variable_get(var), other.instance_variable_get(var)
        diffs[var] = b if a != b and var != :@_id
      end
    end
    return diffs
  end
  
  def store
    record = Item.find_by_date_and_house_and_title(date, house, title)
    unless record
      self.created_at = Time.now
      self.save
    else
      diffs = record.diff(self)
      unless diffs.empty?
        changes = {}
        diffs.keys.each do |var|
          changes[var] = record.instance_variable_get(var)
          record.instance_variable_set(var, diffs[var])
        end
        self.updated_at = Time.now
        rev = Revision.new
        rev.date = self.updated_at
        rev.diff = changes
        self.revisions << rev
        self.save
      end
    end
  end
end

class Revision
  include MongoMapper::EmbeddedDocument
  one :item
  
  key :date, Date
  key :diff, Hash
end