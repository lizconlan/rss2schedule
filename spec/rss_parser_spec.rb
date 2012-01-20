require 'rspec'
require 'spec_helper'
require 'models/item'
require 'models/rss_item'
 
describe RSSParser do 
  describe "new" do
    before :each do
      RestClient.stub(:get).and_return("rss")
      @rssparser = RSSParser.new
    end
    
    it "creates an RSSParser" do
      @rssparser.should be_an_instance_of RSSParser
    end
    
    it "sets the feed URL to 'http://services.parliament.uk/calendar/all.rss' by default" do
      @rssparser.feed_url.should eql "http://services.parliament.uk/calendar/all.rss"
    end
    
    it "sets the feed URL when provided with one" do
      RSSParser.new("http://example.com/fake.rss").feed_url.should eql "http://example.com/fake.rss"
    end
  end
  
  describe "parse" do
    describe "when given an RSS feed without ParlyCal markup" do
      before :each do
        RestClient.stub(:get).and_return(File.read("spec/data/noparlyevent-commons.rss"))
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "calls the parse_rss method" do
        @rssparser.should_receive(:parse_rss).at_least(1).times.and_return(RssItem.new)
        @rssparser.parse
      end
      
      it "does not call the parse_parlyevent method" do
        @rssparser.should_not_receive(:parse_parlyevent)
        @rssparser.parse
      end
      
      describe "when parsing a House of Commons item" do
        before :each do
          @rssitem1 = RssItem.new
          @rssitem2 = RssItem.new
          @rssitem3 = RssItem.new
          RssItem.should_receive(:new).and_return(@rssitem1)
          RssItem.should_receive(:new).and_return(@rssitem2)
          RssItem.should_receive(:new).and_return(@rssitem3)
        end
        
        it "should set the 'event_id' for the RssItem" do
          @rssitem1.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/02/24/events.html#23288")
          @rssitem2.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/02/24/events.html#23288")
          @rssitem3.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/02/24/events.html#23681")
          @rssparser.parse
        end
        
        it "sets the 'house' for the RssItem" do
          @rssitem1.should_receive(:house=).with("Commons")
          @rssitem2.should_receive(:house=).with("Commons")
          @rssitem3.should_receive(:house=).with("Commons")
          @rssparser.parse
        end
        
        it "sets the 'chamber' for the RssItem" do
          @rssitem1.should_receive(:chamber=).at_least(1).times.with("Westminster Hall")
          @rssitem2.should_receive(:chamber=).at_least(1).times.with("Main Chamber")
          @rssitem3.should_receive(:chamber=).at_least(1).times.with("Main Chamber")
          @rssparser.parse
        end
        
        it "should not set the 'committee' for the RssItem" do
          @rssitem1.should_not_receive(:committee=)
          @rssitem2.should_not_receive(:committee=)
          @rssitem3.should_not_receive(:committee=)
          @rssparser.parse
        end
        
        it "should set the 'subject' for the RssItem" do
          @rssitem1.should_receive(:subject=).with("House of Commons Westminster Hall - Chi Onwurah")
          @rssitem2.should_receive(:subject=).with("House of Commons Main Chamber - Business")
          @rssitem3.should_receive(:subject=).with("House of Commons Main Chamber - Legislation - Paul Maynard")
          @rssparser.parse
        end
        
        it "should set the 'inquiry' for the RssItem" do
          @rssitem1.should_receive(:inquiry=).with("House of Commons Westminster Hall - Chi Onwurah")
          @rssitem2.should_receive(:inquiry=).with("House of Commons Main Chamber - Business")
          @rssitem3.should_receive(:inquiry=).with("House of Commons Main Chamber - Legislation - Paul Maynard")
          @rssparser.parse
        end
        
        it "should set the 'note' for the RssItem" do
          @rssitem1.should_receive(:notes=).with("Friday 24 February 2012 - 9:30am - 11:00am <br /> Health inequalities in the North East today")
          @rssitem2.should_receive(:notes=).with("Friday 24 February 2012 <br /> The House is not expected to sit today")
          @rssitem3.should_receive(:notes=).with("Friday 24 February 2012 <br /> Concessionary Bus Travel (Amendment) Bill - Second reading - Paul Maynard")
          @rssparser.parse
        end
        
        it "should set the 'location' for the RssItem"
        
        it "sets the 'date' for the RssItem" do
          @rssitem1.should_receive(:date=).with("2012-02-24")
          @rssitem2.should_receive(:date=).with("2012-02-24")
          @rssitem3.should_receive(:date=).with("2012-02-24")
          @rssparser.parse
        end
        
        it "sets the 'start time' for the RssItem (if there is one)" do
          @rssitem1.should_receive(:start_time=).with("9:30am")
          @rssitem2.should_not_receive(:start_time=)
          @rssitem3.should_not_receive(:start_time=)
          @rssparser.parse
        end
        
        it "sets the 'end time' for the RssItem (if there is one)" do
          @rssitem1.should_receive(:end_time=).with("11:00am")
          @rssitem2.should_not_receive(:end_time=)
          @rssitem3.should_not_receive(:end_time=)
          @rssparser.parse
        end
        
        it "sets the 'sponsor' for the RssItem (if there is one)" do
          @rssitem1.should_receive(:sponsor=).with("Chi Onwurah")
          @rssitem2.should_not_receive(:sponsor=)
          @rssitem3.should_receive(:sponsor=).with("Paul Maynard")
          @rssparser.parse
        end
        
        it "sets the 'category' for the RssItem (if there is one)" do
          @rssitem1.should_not_receive(:category=)
          @rssitem2.should_receive(:category=).with("Business")
          @rssitem3.should_receive(:category=).with("Legislation")
          @rssparser.parse
        end
      end
    end

    describe "when given an RSS feed with ParlyCal markup" do
      before :each do
        RestClient.stub(:get).and_return(File.read("spec/data/parlyevent-commons.rss"))
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "calls the parse_parlyevent method" do        
        @rssparser.should_receive(:parse_parlyevent).at_least(1).times.and_return(RssItem.new)
        @rssparser.parse
      end
      
      it "does not call the parse_rss method" do
        @rssparser.should_not_receive(:parse_rss)
        @rssparser.parse
      end
      
      describe "when parsing a House of Commons item" do
        before :each do
          @rssitem1 = RssItem.new
          @rssitem2 = RssItem.new
          @rssitem3 = RssItem.new
          RssItem.should_receive(:new).and_return(@rssitem1)
          RssItem.should_receive(:new).and_return(@rssitem2)
          RssItem.should_receive(:new).and_return(@rssitem3)
        end
        
        it "should set the 'event_id' for the RssItem" do
          @rssitem1.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/01/24/events.html#25638")
          @rssitem2.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/02/24/events.html#23288")
          @rssitem3.should_receive(:event_id=).with("http://services.parliament.uk/calendar/2012/02/24/events.html#23681")
          @rssparser.parse
        end
        
        it "sets the 'house' for the RssItem" do
          @rssitem1.should_receive(:house=).with("Commons")
          @rssitem2.should_receive(:house=).with("Commons")
          @rssitem3.should_receive(:house=).with("Commons")
          @rssparser.parse
        end
        
        it "sets the 'chamber' for the RssItem" do
          @rssitem1.should_receive(:chamber=).at_least(1).times.with("Westminster Hall")
          @rssitem2.should_receive(:chamber=).at_least(1).times.with("Main Chamber")
          @rssitem3.should_receive(:chamber=).at_least(1).times.with("Main Chamber")
          @rssparser.parse
        end
        
        it "should not set the 'committee' for the RssItem" do
          @rssitem1.should_not_receive(:committee=)
          @rssitem2.should_not_receive(:committee=)
          @rssitem3.should_not_receive(:committee=)
          @rssparser.parse
        end
        
        it "should set the 'subject' for the RssItem" do
          @rssitem1.should_receive(:subject=).with("Health inequalities in the North East")
          @rssitem2.should_receive(:subject=).with("The House is not expected to sit today")
          @rssitem3.should_receive(:subject=).with("Concessionary Bus Travel (Amendment) Bill - Second reading - Paul Maynard")
          @rssparser.parse
        end
        
        it "should set the 'inquiry' for the RssItem" do
          @rssitem1.should_receive(:inquiry=).with("Health inequalities in the North East - Chi Onwurah")
          @rssitem2.should_receive(:inquiry=).with("The House is not expected to sit today")
          @rssitem3.should_receive(:inquiry=).with("Concessionary Bus Travel (Amendment) Bill - Second reading - Paul Maynard")
          @rssparser.parse
        end
        
        it "should set the 'notes' for the RssItem (if there are any)" do
          @rssitem1.should_not_receive(:notes=)
          @rssitem2.should_not_receive(:notes=)
          @rssitem3.should_not_receive(:notes=)
          @rssparser.parse
        end
        
        it "sets the 'date' for the RssItem" do
          @rssitem1.should_receive(:date=).with("2012-01-24")
          @rssitem2.should_receive(:date=).with("2012-02-24")
          @rssitem3.should_receive(:date=).with("2012-02-24")
          @rssparser.parse
        end
        
        it "sets the 'start time' for the RssItem (if there is one)" do
          @rssitem1.should_receive(:start_time=).with("09:30:00")
          @rssitem2.should_not_receive(:start_time=)
          @rssitem3.should_not_receive(:start_time=)
          @rssparser.parse
        end
        
        it "sets the 'end time' for the RssItem (if there is one)" do
          @rssitem1.should_receive(:end_time=).with("11:00:00")
          @rssitem2.should_not_receive(:end_time=)
          @rssitem3.should_not_receive(:end_time=)
          @rssparser.parse
        end
        
        it "should not set the 'sponsor' for the RssItem" do
          @rssitem1.should_not_receive(:sponsor=)
          @rssitem2.should_not_receive(:sponsor=)
          @rssitem3.should_not_receive(:sponsor=)
          @rssparser.parse
        end
        
        it "should not set the 'category' for the RssItem" do
          @rssitem1.should_not_receive(:category=)
          @rssitem2.should_not_receive(:category=)
          @rssitem3.should_not_receive(:category=)
          @rssparser.parse
        end
        
        it "should set the 'location' for the RssItem (if there is one)" do
          @rssitem1.should_not_receive(:location=)
          @rssitem2.should_not_receive(:location=)
          @rssitem3.should_not_receive(:location=)
          @rssparser.parse
        end
      end
    end
  end
end