require 'rails_helper'

RSpec.describe Venue, type: :model do
  before(:all) do
    @venue = FactoryGirl.build(:venue)
  end

  after(:all) do
    Company.delete_all
    Admin.delete_all
  end

  it "should generate lat/long from address" do
    @venue.latitude = nil
    @venue.longitude = nil
    @venue.save
    expect(@venue.latitude).not_to eq(nil)
    expect(@venue.longitude).not_to eq(nil)
  end

  it "should wait for address change" do
    @venue.longitude = nil
    @venue.latitude = nil
    @venue.valid?
    expect(@venue.latitude).to eq(nil)
    expect(@venue.longitude).to eq(nil)
  end
end
