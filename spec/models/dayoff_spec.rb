require 'rails_helper'

RSpec.describe DayOff, type: :model do
  before(:all) do
    @dayoff = FactoryGirl.build(:day_off, :with_venue)
  end

  it 'starts valid' do
    expect(@dayoff).to be_valid
  end

  it 'has a start_time' do
    @dayoff.start_time = nil
    expect(@dayoff).not_to be_valid
    @dayoff.start_time = Time.zone.now.utc
  end

  it 'has an end_date' do
    @dayoff.end_time = nil
    expect(@dayoff).not_to be_valid
    @dayoff.end_time = Time.zone.now.utc + 2.days
  end

  it 'has valid range' do
    @dayoff.start_time = Time.zone.now.utc + 1.day
    @dayoff.end_time = Time.zone.now.utc - 1.day
    expect(@dayoff).not_to be_valid
  end

  it 'can handle one day ranges' do
    @dayoff.start_time = Time.zone.now.utc
    @dayoff.end_time = Time.zone.now.utc + 1.hour
    expect(@dayoff).to be_valid
  end

  after(:all) do
    DayOff.delete_all
    Venue.delete_all
    Company.delete_all
    Admin.delete_all
  end
end
