require 'rails_helper'
require 'features/helpers'

feature "reservations_resell", js: true do
  context "put recurring reservation on resell" do
    let!(:membership) { create :membership, :with_user, :with_venue }
    let!(:user1) { membership.user }
    let!(:user2) { create(:user) }
    let!(:reservation) { create :reservation, reselling: false, booking_type: :membership, membership: membership,
                                        user: user1, court: membership.venue.courts.first }

    before do
      membership.venue.update_attribute(:listed, true)
      membership.venue.courts.last.destroy

      in_browser(:one) do
        sign_in_as(user1)
      end

      in_browser(:two) do
        sign_in_as(user2)
      end
    end

    it 'should be only one active court for search' do
      expect(membership.venue.courts.count).to eq 1
      expect(membership.venue.courts.first).to eq reservation.court
    end

    it "user1 should have recurring reservation and user2 will not see in search" do
      expect(user1.reservations.first).to eq reservation

      in_browser(:two) do
        search_datetime(reservation.start_time)

        expect(page).to have_content(reservation.court.venue.venue_name.upcase)
        expect(find(".venue__times")).not_to have_content(TimeSanitizer.output(reservation.start_time).strftime('%H:%M'))
      end
    end

    it "user1 should set reservation on resell and user2 will see it in search" do
      in_browser(:one) do
        visit user_path(user1)
        expect(page.status_code).to eq 200
        click_link I18n.t('users.show.my_recurring_reservations')
        click_link I18n.t('users.show.resell_reservation_link')

        expect(reservation.reload.reselling).to be_truthy
        expect(page).to have_content(I18n.t('users.show.withdraw_resell_reservation_link'))
      end

      in_browser(:two) do
        search_datetime(reservation.start_time)

        expect(page).to have_content(reservation.court.venue.venue_name.upcase)
        expect(find(".venue__times")).to have_content(TimeSanitizer.output(reservation.start_time).strftime('%H:%M'))
      end
    end
  end

  context "booking of reselling reservation" do
    let!(:membership) { create :membership, :with_user, :with_venue }
    let!(:user1) { membership.user }
    let!(:user2) { create(:user) }
    let!(:court) { membership.venue.courts.first }
    let!(:reservation) { create :reservation, reselling: true, booking_type: :membership, membership: membership,
                                        user: user1, court: court }

    before do
      membership.venue.update_attribute(:listed, true)
      membership.venue.courts.last.destroy
      add_stripe_card_to_user(user2)

      in_browser(:one) do
        sign_in_as(user1)
      end

      in_browser(:two) do
        sign_in_as(user2)
      end
    end

    it 'should be able to make paid booking and take over resell' do
      in_browser(:two) do
        search_datetime(reservation.start_time)

        within ".venue__times" do
          click_button TimeSanitizer.output(reservation.start_time).strftime('%H:%M')
          sleep 1
        end

        expect(page).to have_content(I18n.t('shared.booking_modal.available_on'))

        find(".modal-booking__courts div[data-id='#{court.id}']").click
        click_button 'selectBookingsBtn'
        sleep 1

        expect(page).to have_content(I18n.t('shared.payment_modal.title').upcase)

        click_button 'makeReservationBtn'
        sleep 1

        expect(page).to have_content(I18n.t('shared.booking_success_modal.title').upcase)
      end

      expect(user2.reservations.reload.count).to eq 1
      expect(user1.reservations.reload.count).to eq 0
      expect(reservation.reload.reselling).to be_falsey
    end

    it 'should be able to cancel paid booking and return resell to initial owner' do
      in_browser(:two) do
        make_booking(reservation.start_time)
        visit user_path(user2)
        expect(page.status_code).to eq 200
        click_link I18n.t('users.show.cancel_reservation_link')
      end

      expect(user2.reservations.reload.count).to eq 0
      expect(user1.reservations.reload.count).to eq 1
      expect(reservation.reload.reselling).to be_truthy
    end

    it 'should be able to book cancelled reservation again' do
      in_browser(:two) do
        make_booking(reservation.start_time)
        visit user_path(user2)
        expect(page.status_code).to eq 200
        click_link I18n.t('users.show.cancel_reservation_link')
        make_booking(reservation.start_time)
      end

      expect(user2.reservations.reload.count).to eq 1
      expect(user1.reservations.reload.count).to eq 0
      expect(reservation.reload.reselling).to be_falsey
    end
  end
end
#page.save_screenshot('screenshot.png')
