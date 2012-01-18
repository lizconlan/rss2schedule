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

    end

end


