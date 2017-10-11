require 'rails_helper'
require 'features/helpers'

feature "feature helpers", js: true do
  describe "#sign_in_as" do
    let!(:user) { create(:user) }

    it 'should sign in as user' do
      sign_in_as(user)

      expect(find("#main-landing-navbar")).to have_content(user.first_name)
    end
  end

  describe "#in_browser" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    it 'should sign in as different users in dfferent sessions' do
      in_browser(:one) do
        sign_in_as(user1)
      end

      in_browser(:two) do
        sign_in_as(user2)
      end

      in_browser(:one) do
        expect(page.status_code).to eq 200
        expect(find("#main-landing-navbar")).to have_content(user1.first_name)
      end

      in_browser(:two) do
        expect(page.status_code).to eq 200
        expect(find("#main-landing-navbar")).to have_content(user2.first_name)
      end
    end
  end

  describe "#search_datetime" do
    let!(:time) { 2.days.since.at_noon }

    it 'should open search and have correct date set' do
      search_datetime(time)

      expect(page.status_code).to eq 200
      expect(current_path).to eq search_path
      expect(find("form.search-venue #searchDate").value).to eq TimeSanitizer.output(time).strftime('%d/%m/%Y')
    end
  end

  describe "#make_booking" do
    let!(:venue) { create :venue, :with_courts, court_count: 1 }
    let!(:user) { create(:user) }
    let!(:court) { venue.courts.first }
    let!(:reservation) { build :reservation }

    before do
      venue.update_attribute(:listed, true)
      add_stripe_card_to_user(user)
    end

    it 'should be able to make paid booking' do
      sign_in_as(user)
      make_booking(reservation.start_time)

      expect(user.reservations.reload.count).to eq 1
    end
  end
end
