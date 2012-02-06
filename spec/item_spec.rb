require 'rspec'
require './spec/spec_helper'
require './models/item'
 
describe Item do
  before :each do      
    @item = Item.new
  end
  
  describe "new" do
    it "creates an Item" do
      @item.should be_an_instance_of Item
    end
  end
  
  describe "diff" do
    it "should return a hash of differences between 2 Items" do
      @item2 = Item.new
      @item.house = "Commons"
      @item2.house = "Lords"
      @item.diff(@item2).should == {:@house => "Lords"}
    end
    
    it "should return an empty hash if comparing identical items" do
      @item.diff(@item.dup).should == {}
    end
    
    it "should return an empty hash if just the @_id property is different" do
      @item2 = Item.new
      @item._id.should_not == @item2._id
      @item.diff(@item2).should == {}
    end
  end
  
  describe "store" do
    before do
      Item.any_instance.stub(:save)
    end
    
    it "should save the Item if there is no previous record" do
      Item.should_receive(:find_by_date_and_house_and_title).and_return(nil)
      @item.should_receive(:save)
      @item.store
    end
    
    it "should do nothing if an existing record is identical" do
      item2 = Item.new
      Item.should_receive(:find_by_date_and_house_and_title).and_return(item2)
      @item.should_not_receive(:save)
      @item.store
    end
    
    describe "when it differs from a matching stored record" do
      before :each do
        @item2 = Item.new
        @item.end_time = "21:00:00"
        @item2.end_time = "20:00:00"
        Item.should_receive(:find_by_date_and_house_and_title).and_return(@item2)
      end
      
      it "should update the existing record" do
        @item2.should_receive(:end_time=).with("21:00:00")
        @item2.should_receive(:save)
        @item.store
      end
      
      it "should create a new Revision" do
        revision = Revision.new
        Revision.should_receive(:new).and_return(revision)
        revision.should_receive(:diff=).with({:@end_time => "20:00:00"})
        @item.store
        @item.revisions.first.should eql revision
      end
    end
  end
end