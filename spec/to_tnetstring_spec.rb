require 'spec_helper'

describe TNetstring do
  it "dumps an integer" do
    12345.to_tnetstring.should == '5:12345#'
  end

  it "dumps an empty string" do
    "".to_tnetstring.should == '0:,'
  end

  it "dumps a string" do
   "this is cool".to_tnetstring.should == '12:this is cool,'
  end

#  it "dumps to an empty array" do
#    [].to_tnetstring.should == '0:]'
#  end
#
#  it "dumps an arbitrary array of ints and strings" do
#    [12345, 67890, 'xxxxx'].to_tnetstring.should == '24:5:12345#5:67890#5:xxxxx,]'
#  end
#
#  it "dumps to an empty hash" do
#    {}.to_tnetstring.should == '0:}'
#  end
#
#  it "dumps an arbitrary hash of ints, strings, and arrays" do
#    {"hello" => [12345678901, 'this']}.to_tnetstring.should == '34:5:hello,22:11:12345678901#4:this,]}'
#  end
#
  it "dumps a null" do
    nil.to_tnetstring.should == '0:~'
  end

  it "dumps a boolean" do
    false.to_tnetstring.should == '5:false!'
  end
end
