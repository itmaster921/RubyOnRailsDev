require 'rails_helper'

RSpec.describe PhotosController, type: :controller do

  before(:all) do
      @admin = FactoryGirl.create(:admin)
      @file = mock_file_upload("test.jpg", "image/jpeg")
      company = Company.new(FactoryGirl.attributes_for(:company))
      hours = {
        opening: {},
        closing: {}
      }
      venue = Venue.new(FactoryGirl.attributes_for(:venue), hours: hours)
      venue.update(company: company)
  end

  describe "PATCH update" do
    it "creates a new photo on upload" do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in @admin
      image = {"0": @file}
      count = Photo.count
      req = {venue_id: Venue.first.id, image: image}
      patch :create, req
      expect(Photo.count).to eq(count + 1)
    end
  end

  after(:all) do
    Photo.delete_all
    Venue.delete_all
    Company.delete_all
    Admin.delete_all
  end

end
