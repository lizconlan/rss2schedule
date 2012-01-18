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
        else  #meetings, rising times, room bookings
          if committee == "Estimated Rising Time"
            subject = committee
            committee = ""
          end
          
          if subject.empty?
            case witnesses
              when /evidence session/
                subject = "Evidence Session"
              when /private meeting/
                subject = "Private meeting"
            end
          end
          
          if subject == "to consider the bill"
            if committee =~ /(^.* Bill)/
              subject = "To consider the #{$1}"
            end
          end
          
          item = Item.new
          
          item.source_file = @feed_url
          item.event_id = event_id
          
          item.date = date
          item.title = subject
          item.house = house
          if location.empty?
            item.location = "tbc"
          else
            item.location = location
          end
          item.sponsor = "#{chamber} - #{committee}"
          item.start_time = start_time unless start_time.nil?
          item.end_time = end_time unless start_time.nil?
          item.link = link
          item.witnesses = witnesses unless witnesses.empty?
          
          item.created_at = Time.now
          
          item.save
      end
    end
  end
end