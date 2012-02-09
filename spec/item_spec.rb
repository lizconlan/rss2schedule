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
    before :each do
      @item2 = Item.new
    end
    
    it "should return a hash of differences between 2 Items" do
      @item.house = "Commons"
      @item2.house = "Lords"
      @item.diff(@item2).should == {:@house => "Lords"}
    end
    
    it "should return an empty hash if comparing identical items" do
      @item.diff(@item.dup).should == {}
    end
    
    it "should return an empty hash if just the @_id property is different" do
      @item._id.should_not == @item2._id
      @item.diff(@item2).should == {}
    end
    
    it "should return an empty hash if the @created_at property is different" do
      @item.created_at = Time.now
      @item2.created_at = Time.now-100000
      @item.created_at.should_not == @item2.created_at
      @item.diff(@item2).should == {}
    end
    
    it "should return an empty hash if the @updated_at property is different" do
      @item.updated_at = Time.now
      @item2.updated_at = Time.now-100000
      @item.updated_at.should_not == @item2.updated_at
      @item.diff(@item2).should == {}
    end
    
    it "should return an empty hash if the @_revisions property is different" do
      @item2.revisions = [{@item_type => "Business"}]
      @item.diff(@item2).should == {}
    end
  end
  
  describe "store" do
    before do
      Item.any_instance.stub(:save)
    end
    
    it "should save the Item if there is no previous record" do
      Item.should_receive(:find_by_event_id).and_return(nil)
      @item.should_receive(:save)
      @item.store
    end
    
    it "should do nothing if an existing record is identical" do
      found_item = Item.new
      Item.should_receive(:find_by_event_id).and_return(found_item)
      found_item.should_receive(:diff).with(@item).and_return({})
      @item.should_not_receive(:save)
      found_item.should_not_receive(:save)
      @item.store
    end
    
    describe "when it differs from a matching stored record" do
      before :each do
        @found_item = Item.new
        @found_item.stub(:save)
        @item.stub(:save)
        @item.end_time = "21:00:00"
        @found_item.end_time = "20:00:00"
        Item.should_receive(:find_by_event_id).and_return(@found_item)
      end
      
      it "should update the existing record" do
        @found_item.should_receive(:end_time=).with("21:00:00")
        @found_item.should_receive(:save)
        @item.store
      end
      
      it "should create a new Revision" do
        revision = Revision.new
        Revision.should_receive(:new).and_return(revision)
        @found_item.should_receive(:diff).with(@item).and_return({:@end_time=>"20:00:00"})
        revision.should_receive(:diff=).with({:@end_time => "20:00:00"})
        
        @item.store
        @found_item.revisions.first.should eql revision
      end
    end
  end
end