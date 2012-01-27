require 'rspec'
require 'spec_helper'
require 'models/item'
 
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
    it "should return an empty hash if comparing identical items" do
      @item.diff(@item.dup).should == {}
    end
    
    it "should return an empty hash if just the @_id property is different" do
      @item2 = Item.new
      @item._id.should_not == @item2._id
      @item.diff(@item2).should == {}
    end
    
    it "should return a hash of differences between 2 Items" do
      @item2 = Item.new
      @item.house = "Commons"
      @item2.house = "Lords"
      @item.diff(@item2).should == {"@house" => "Lords"}
    end
  end
end