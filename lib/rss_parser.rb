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
      
      #prefer the parlycal:event data if available
      if item.xpath("parlycal:event") and item.xpath("parlycal:event") != []
        event_id = item.xpath("parlycal:event").attribute("id").value
        house = item.xpath("parlycal:event/parlycal:house").text
        chamber = item.xpath("parlycal:event/parlycal:chamber").text
      
        committee = item.xpath("parlycal:event/parlycal:comittee").text
        subject = item.xpath("parlycal:event/parlycal:subject").text.strip
        inquiry = item.xpath("parlycal:event/parlycal:inquiry").text.strip
      
        date = item.xpath("parlycal:event/parlycal:date").text
        if item.xpath("parlycal:event/parlycal:startTime") and !(item.xpath("parlycal:event/parlycal:startTime").empty?)
          start_time = item.xpath("parlycal:event/parlycal:startTime").text
        else
          start_time = nil
        end
        
        if item.xpath("parlycal:event/parlycal:endTime") and !(item.xpath("parlycal:event/parlycal:endTime").empty?)
          end_time = item.xpath("parlycal:event/parlycal:endTime").text
        else
          end_time = nil
        end
      
        witnesses = item.xpath("parlycal:event/parlycal:witnesses").text
        location = item.xpath("parlycal:event/parlycal:location").text
      else #otherwise treat as standard RSS
        #RSS handling code goes here
      end
      
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
          category = committee
          committee = nil
          if subject.empty?
            subject = inquiry
            sponsor = ""
          else
            sponsor = inquiry.gsub(subject,"").strip
            if sponsor[0..0] == "-"
              sponsor = sponsor[1..sponsor.length].strip
            end
          end
          
          if sponsor.empty?
            subject_parts = subject.split(" - ")
            if subject_parts.length == 3
              sponsor = subject_parts.pop
              subject = subject_parts.join(" - ").strip
            end
          end
          
          # p subject
          # p "Category: #{category}"
          # p "Sponsor: #{sponsor}"
          # p ""
        when "Westminster Hall"
          #almost certainly a debate
          if subject.empty?
            subject = inquiry
            sponsor = ""
          else
            sponsor = inquiry.gsub(subject,"").strip
            if sponsor[0..0] == "-"
              sponsor = sponsor[1..sponsor.length].strip
            end
          end
          
          # p subject
          # p "Category: #{category}"
          # p "Sponsor: #{sponsor}"
          # p "#{start_time} - #{end_time}"
          # p ""
        else
          #of interest - an actual committee thing?
          if subject.empty?
            p "BLANK SUBJECT"
          else
            p subject
          end
          
      end
    end
    
    # p chambers
    # p ""
    # p committees
  end
end