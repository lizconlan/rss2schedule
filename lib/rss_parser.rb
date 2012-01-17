require 'nokogiri'
require 'rest_client'

class RSSParser
  attr_reader :feed_url, :rss
  
  def initialize(url="http://services.parliament.uk/calendar/all.rss")
    @feed_url = url
    @rss = RestClient.get(@feed_url)
  end
  
  def parse
    doc = Nokogiri::XML(@rss)
    
    items = doc.xpath("//item")
    
    chambers = []
    committees = []
    
    items.each do |item|
      link  = item.xpath("link").text
      guid = item.xpath("guid").text
      
      event_id = item.xpath("parlycal:event").attribute("id").value
      house = item.xpath("parlycal:event/parlycal:house").text
      chamber = item.xpath("parlycal:event/parlycal:chamber").text
      
      committee = item.xpath("parlycal:event/parlycal:comittee").text
      subject = item.xpath("parlycal:event/parlycal:subject").text
      inquiry = item.xpath("parlycal:event/parlycal:inquiry").text
      
      date = item.xpath("parlycal:event/parlycal:date").text
      if item.xpath("parlycal:event/parlycal:startTime") and !(item.xpath("parlycal:event/parlycal:startTime").empty?)
        start_time = item.xpath("parlycal:event/parlycal:startTime")
      else
        start_time = nil
      end
      
      witnesses = item.xpath("parlycal:event/parlycal:witnesses").text
      location = item.xpath("parlycal:event/parlycal:location").text
      
      
      
      
      #debug/testing
      chambers << chamber unless chambers.include?(chamber)
      committees << committee unless committees.include?(committee)
      
      # case committee
      #   when /Committee/
      #     #is a committee
      #     type = "Committee"
      #   when /Estimated Rising Time/
      #     type = "EstimatedRisingTime"
      #   else
      #     #generic business item
      # end
      
      case chamber
        when "Main Chamber"
          #business item
        when "Westminster Hall"
          #almost certainly a debate
          p "#{chamber} - #{inquiry}"
        else
          #of interest - an actual committee thing?
          p "#{chamber} - #{committee}"
      end
    end
    
    p chambers
    p ""
    p committees
  end
end