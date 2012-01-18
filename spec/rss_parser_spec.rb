require 'spec_helper'
 
describe RSSParser do
    
    before :each do
	    @rssparser = RSSParser.new
    end

    describe "#new" do
	    it "takes no parameters and returns a RSSParser object" do
		    @rssparser.should be_an_instance_of RSSParser
	    end
	
	    it "returns the correct feed url" do
		    @rssparser.feed_url.should eql "http://services.parliament.uk/calendar/all.rss"
	    end

      it "accepts an alternate feed url" do
        parser = RSSParser.new("http://example.com/fake.rss")
        parser.feed_url.should eql "http://example.com/fake.rss"
      end

    end

end


