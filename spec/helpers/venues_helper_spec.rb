require 'rails_helper'

describe VenuesHelper do
  describe "minute_of_a_day_to_time" do
    it "should return time during day from minutes" do
      result = minute_of_a_day_to_time 630
      expect(result).to eq("10:30")
    end
  end

  describe "options_for_time_select" do
    it "should return array of time strings" do
      result = options_for_time_select
      expect(result).to be_instance_of Array
      expect(result.size).to eq 34
      expect(result.first).to match /^\d{2}:\d{2}$/
    end
  end
end
