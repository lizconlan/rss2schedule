require 'spec_helper'
require 'models/item'
 
describe RSSParser do 
  describe "#new" do
    before :each do
      RestClient.stub(:get).and_return("rss")
      @rssparser = RSSParser.new
    end
    
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
    describe "when given an rss feed with no parlyevent markup" do
      before :each do
        RestClient.stub(:get).and_return(%Q|
<rss xmlns:parlycal='http://services.parliament.uk/ns/calendar/feeds' version='2.0'>
  <channel>
    <title>
      Houses of Parliament
    </title>
    <description>
      Forthcoming events in the Houses of Parliament
    </description>
    <language>
      en
    </language>
    <link>
      http://services.parliament.uk/calendar/
    </link>
    <item>
      <title>
        House of Commons Westminster Hall - Chi Onwurah
      </title>
      <link>
        http://services.parliament.uk/calendar/Commons/MainChamber/2012/02/24/events.html
      </link>
      <guid>
        http://services.parliament.uk/calendar/2012/02/24/events.html#23288
      </guid>
      <author>
        webmaster@parliament.uk (UK Parliament Webmaster)
      </author>
      <category>
        House of Commons
      </category>
      <category>
        Westminster Hall
      </category>
      <description>
        Friday 24 February 2012 - 9:30am - 11:00am &lt;br /&gt; Health inequalities in the North East
        today
      </description>
    </item>
  </channel>
</rss>|)
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "should call the parse_rss method" do
        @rssparser.should_receive(:parse_rss)
        @rssparser.should_not_receive(:parse_parlyevent)
        @rssparser.parse
      end
      
      it "should correctly determine the house" do
        @item.should_receive(:house=).with("Commons")
        @rssparser.parse
      end
      
      it "should work out the date" do
        @item.should_receive(:date=).with("2012-02-24")
        @rssparser.parse
      end
      
      it "should look for start and end times" do
        @item.should_receive(:start_time=).with("9:30am")
        @item.should_receive(:end_time=).with("11:00am")
        @rssparser.parse
      end
      
      it "should work out the sponsor" do
        @item.should_receive(:sponsor=).with("Chi Onwurah")
        @rssparser.parse
      end
    end

    describe "when given an rss feed with parlyevent markup" do
      before :each do
        RestClient.stub(:get).and_return(%Q|
<rss xmlns:parlycal='http://services.parliament.uk/ns/calendar/feeds' version='2.0'>
<channel>
  <title>
    Houses of Parliament
  </title>
  <description>
    Forthcoming events in the Houses of Parliament
  </description>
  <language>
    en
  </language>
  <link>
    http://services.parliament.uk/calendar/
  </link>
  <item>
    <title>
      House of Commons Westminster Hall - Chi Onwurah
    </title>
    <link>
      http://services.parliament.uk/calendar/Commons/MainChamber/2012/02/24/events.html
    </link>
    <guid>
      http://services.parliament.uk/calendar/2012/02/24/events.html#23288
    </guid>
    <author>
      webmaster@parliament.uk (UK Parliament Webmaster)
    </author>
    <category>
      House of Commons
    </category>
    <category>
      Westminster Hall
    </category>
    <description>
      Friday 24 February 2012 - 9:30am - 11:00am &lt;br /&gt; Health inequalities in the North East
      today
    </description>
    <parlycal:event id='25638'>
      <parlycal:house>
        Commons
      </parlycal:house>
      <parlycal:chamber>
        Westminster Hall
      </parlycal:chamber>
      <parlycal:date>
        2012-01-24
      </parlycal:date>
      <parlycal:startTime>
        09:30:00
      </parlycal:startTime>
      <parlycal:endTime>
        11:00:00
      </parlycal:endTime>
      <parlycal:comittee/>
      <parlycal:inquiry>
        Health inequalities in the North East - Chi Onwurah
      </parlycal:inquiry>
      <parlycal:witnesses/>
      <parlycal:location/>
      <parlycal:subject>
        Health inequalities in the North East
      </parlycal:subject>
    </parlycal:event>
  </item>
</channel>
</rss>|)
        @rssparser = RSSParser.new
        @item = Item.new
        Item.stub(:new).and_return(@item)
        @item.stub(:save)
      end
      
      it "should call the parse_parlyevent method" do
        @rssparser.should_receive(:parse_parlyevent)
        @rssparser.should_not_receive(:parse_rss)
        @rssparser.parse
      end
    end
  end
end