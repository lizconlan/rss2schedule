require 'spec_helper'
 
describe RSSParser do 
  before :each do
    RestClient.stub(:get).and_return("rss")
    @rssparser = RSSParser.new
  end
  
  describe "initialize" do
    it "takes no parameters and returns a RSSParser object" do
      @rssparser.should be_an_instance_of RSSParser
    end
    
    it "returns the correct feed url" do
      @rssparser.feed_url.should eql "http://services.parliament.uk/calendar/all.rss"
    end
    
    it "accepts an alternate feed url" do
      RSSParser.new("http://example.com/fake.rss").feed_url.should eql "http://example.com/fake.rss"
    end
  end
  
  describe "parse" do
    it "" do
    end
  end
  
  describe "parse_business_item" do
  
  end
  
  describe "parse_westminster_hall_item" do
  end
  
  describe "parse_other_item" do
  end
end