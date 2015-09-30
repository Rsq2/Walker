require 'spec_helper'

describe Entry do
  before :each do
    @instance = Entry.new "55 Test Dr."
end

describe '#new' do
  it "takes one parameter, initializes an empty array attribute" do
    expect(@instance).to be_an_instance_of(Entry)
  end
end

describe '#address' do
  it "returns an address" do
    expect(@instance.instance_variable_get(:@address)).to eql("55 Test Dr.")
  end
end

describe '#steps' do
  it "returns an empty array" do
    expect(@instance.instance_variable_get(:@steps)).to match_array []
  end
end
end
