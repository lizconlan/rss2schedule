require 'nokogiri'
require 'rest_client'
require 'models/item'
require 'models/rss_item'

class RSSParser
  attr_reader :feed_url, :rss
  
  def initialize(url="http://services.parliament.uk/calendar/all.rss")
    @feed_url = url
    @rss = RestClient.get(@feed_url)
  end
  
  def parse
    doc = Nokogiri::XML(@rss)
    items = doc.xpath("//item")
    
    items.each do |item|
      @link  = item.xpath("link").text
      @guid = item.xpath("guid").text

      event = nil
      
      #prefer the parlycal:event data if available
      if item.xpath("parlycal:event") and !(item.xpath("parlycal:event").empty?)
        event = parse_parlyevent(item)
      else #otherwise treat as standard RSS
        event = parse_rss(item)
      end
      
      case event.chamber
        when "Main Chamber"
          result = parse_business_item(event)
        when "Westminster Hall"
          result = parse_westminster_hall_item(event)
        else  #meetings, rising times, room bookings
          result = parse_other_item(event)
      end
      
      #result.store()
      save_item_data(result)
    end
  end
  
  def parse_business_item(event)
    item = Item.new
    
    if event.sponsor.nil? or event.sponsor.empty?
      if event.subject.nil? or event.subject.empty?
        item.title = event.inquiry
      else
        item.title = event.subject
        item.sponsor = event.inquiry.gsub(event.subject,"").strip unless event.inquiry.nil?
        if item.sponsor and item.sponsor[0..0] == "-"
          item.sponsor = item.sponsor[1..item.sponsor.length].strip
        end
      end
    else
      item.sponsor = event.sponsor
    end
    
    if item.sponsor.nil? or item.sponsor.empty?
      unless event.subject.nil?
        subject_parts = event.subject.split(" - ")
        if subject_parts.length == 3
          item.sponsor = subject_parts.pop
          item.title = subject_parts.join(" - ").strip
        end
      end
    end
    
    item.location = event.chamber
    item.item_type = event.category
    item
  end
  
  def parse_westminster_hall_item(event)
    item = Item.new
    
    item.title = event.subject
    if event.sponsor.nil? or event.sponsor.empty?
      if event.subject.nil? or event.subject.empty?
        item.title = event.inquiry
      else
        item.title = event.subject
        item.sponsor = event.inquiry.gsub(event.subject,"").strip if event.inquiry
        if item.sponsor and item.sponsor[0..0] == "-"
          item.sponsor = item.sponsor[1..item.sponsor.length].strip
        end
      end
    end
    
    item.location = event.chamber
    item.item_type = event.category || "Debate"
    item
  end
  
  def parse_other_item(event)
    item = Item.new
    
    item.location = event.chamber
    if event.committee == "Estimated Rising Time"
      item.title = event.committee
      item.item_type = "Business"
    end
    
    if event.subject.nil? or event.subject.empty?
      case @notes
        when /evidence session/
          item.title = "Evidence Session"
        when /private meeting/
          item.title = "Private meeting"
      end
    end
    
    item.title = event.subject if item.title.nil? or item.title.empty?
    
    if item.title == "to consider the bill"
      if event.committee =~ /(^.* Bill)/
        item.title = "To consider the #{$1}"
      end
    end
    
    item.sponsor = "#{event.chamber} - #{event.committee}"
    item.item_type = "Meeting"
    item
  end
  
  def parse_parlyevent(item)
    event_item = RssItem.new
    event_item.event_id = item.xpath("guid").text.gsub("\n", "").strip
    event_item.house = item.xpath("parlycal:event/parlycal:house").text.gsub("\n", "").strip
    event_item.chamber = item.xpath("parlycal:event/parlycal:chamber").text.gsub("\n", "").strip

    event_item.committee = item.xpath("parlycal:event/parlycal:comittee").text unless item.xpath("parlycal:event/parlycal:witnesses").text.empty?
    event_item.subject = item.xpath("parlycal:event/parlycal:subject").text.strip.gsub("\n", " ").squeeze(" ").strip
    event_item.inquiry = item.xpath("parlycal:event/parlycal:inquiry").text.strip.gsub("\n", " ").squeeze(" ").strip

    event_item.date = item.xpath("parlycal:event/parlycal:date").text.gsub("\n", "").strip
    if item.xpath("parlycal:event/parlycal:startTime") and !(item.xpath("parlycal:event/parlycal:startTime").empty?)
      event_item.start_time = item.xpath("parlycal:event/parlycal:startTime").text.gsub("\n", "").strip
    end

    if item.xpath("parlycal:event/parlycal:endTime") and !(item.xpath("parlycal:event/parlycal:endTime").empty?)
      event_item.end_time = item.xpath("parlycal:event/parlycal:endTime").text.gsub("\n", "").strip
    end

    event_item.notes = item.xpath("parlycal:event/parlycal:witnesses").text unless item.xpath("parlycal:event/parlycal:witnesses").text.empty?
    event_item.location = item.xpath("parlycal:event/parlycal:location").text unless item.xpath("parlycal:event/parlycal:location").text.empty?
    
    return event_item
  end

  def parse_rss(item)
    event_item = RssItem.new
    event_item.event_id = item.xpath("guid").text.gsub("\n", "").strip
    
    title = item.xpath("title").text.gsub("\n", " ").squeeze(" ").strip
    if title =~ /House of Commons/
      event_item.house = "Commons"
    else
      event_item.house = "Lords"
    end
    title_parts = title.split(" - ")
    
    event_item.subject = title
    event_item.inquiry = title
    event_item.chamber = title_parts[0].gsub("House of #{event_item.house} ", "").gsub("\n", "").strip
    
    category = title_parts[1].gsub("\n", "").strip
    
    event_item.sponsor = title_parts[2] if title_parts.length > 2
    event_item.notes = item.xpath("description").text.gsub("\n", " ").squeeze(" ").strip
    
    categories = item.xpath("category")
    categories.each do |cat|
      cat = cat.text.gsub("\n", "").strip
      unless cat =~ /^House of /
        if event_item.chamber != cat
          event_item.chamber = cat
        end
      end
    end
    
    if event_item.sponsor.nil? and event_item.chamber != category and event_item.chamber == "Westminster Hall"
      event_item.sponsor = category
    else
      event_item.category = category
    end
    
    if event_item.notes =~ /([A-Z][a-z]*day \d{1,2} [A-Z][a-z]* \d{4})/
      date = Date.parse($1)
      event_item.date = date.strftime("%Y-%m-%d")
    end
    
    if event_item.notes =~ /(\d{1,2}:\d{2}(?: )?[a|p]m) - (\d{1,2}:\d{2}(?: )?[a|p]m)/
      event_item.start_time = $1
      event_item.end_time = $2
    elsif event_item.notes =~ /(\d{1,2}:\d{2}(:? )?[a|p]m)/
      event_item.start_time = $1
    end
    
    return event_item
  end
  
  def save_item_data(event)
    item = Item.new
    item.source_file = @feed_url
    item.rss_id = 'guid should go here'
    item.event_id = event.event_id
    item.item_type = event.item_type
    item.date = event.date
    item.title = event.title
    item.house = event.house
    if event.location.nil? or event.location.empty?
      item.location = "tbc"
    else
      item.location = event.location
    end
    item.sponsor = event.sponsor unless event.sponsor.nil? or event.sponsor.empty?
    item.start_time = event.start_time unless event.start_time.nil?
    item.end_time = event.end_time unless event.end_time.nil?
    item.link = event.link
    item.notes = event.notes unless event.notes.nil? or event.notes.empty?
    item.created_at = Time.now
    item.save
  end
end