require 'rspec'
require 'spec_helper'
require 'models/item'
 
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
        RestClient.stub(:get).and_return(File.read("spec/data/noparlyevent-wh.rss"))
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "calls the parse_rss method" do
        @rssparser.should_receive(:parse_rss)
        @rssparser.parse
      end
      
      it "does not call the parse_parlyevent method" do
        @rssparser.should_not_receive(:parse_parlyevent)
        @rssparser.parse
      end
      
      it "sets the 'House' for the Item" do
        @item.should_receive(:house=).with("Commons")
        @rssparser.parse
      end
      
      it "sets the 'Date' for the Item" do
        @item.should_receive(:date=).with("2012-02-24")
        @rssparser.parse
      end
      
      it "sets the 'start time' for the Item" do
        @item.should_receive(:start_time=).with("9:30am")
        @rssparser.parse
      end
      
      it "sets the 'end time' for the Item" do
        @item.should_receive(:end_time=).with("11:00am")
        @rssparser.parse
      end
      
      it "sets the 'Sponsor' for the Item" do
        @item.should_receive(:sponsor=).with("Chi Onwurah")
        @rssparser.parse
      end
    end

    describe "when given an RSS feed with ParlyCal markup" do
      before :each do
        RestClient.stub(:get).and_return(File.read("spec/data/parlyevent-wh.rss"))
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "calls the parse_parlyevent method" do
        @rssparser.should_receive(:parse_parlyevent)
        @rssparser.parse
      end
      
      it "does not call the parse_rss method" do
        @rssparser.should_not_receive(:parse_rss)
        @rssparser.parse
      end
    end
  end
end