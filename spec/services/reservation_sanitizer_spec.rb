require 'rails_helper'
#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe ReservationSanitizer do
  describe '#create_reservations' do
    let!(:user) { create :user }
    let!(:venue) { create :venue, :with_courts }
    let!(:params) do
      {
        duration: 60,
        date: Time.current.advance(days: 1).to_s(:date),
        pay: '',
        card: '',
        bookings: [
                    {
                      start_time: Time.current.advance(days: 1).at_noon.to_s,
                      id: venue.courts.first.id,
                    }
                  ].to_json
      }
    end

    context 'create valid reservations' do
      it 'should return created reservations' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations).not_to eq nil
        expect(reservations.sort_by(&:id)).to eq Reservation.all.to_a.sort_by(&:id)
      end

      it 'should belong to user' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.user).to eq user
      end

      it 'should connect user to venue' do
        ReservationSanitizer.new(user, params).create_reservations

        expect(VenueUserConnector.all.count).to eq 1
        expect(VenueUserConnector.first.user).to eq user
        expect(VenueUserConnector.first.venue).to eq venue
      end

      it 'should use start_time' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.start_time).to eq Time.current.advance(days: 1).at_noon
      end

      it 'should calculate end time with duration' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.end_time).to eq Time.current.advance(days: 1).at_noon + 60.minutes
      end

      it 'should belong to court' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.court).to eq venue.courts.first
      end

      it 'should set online booking type' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.booking_type).to eq 'online'
      end

      it 'should set unpaid payment type' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations.first.payment_type).to eq 'unpaid'
      end

      context 'price and discount' do
        let(:court) { venue.courts.first }
        let(:start_time) { Time.current.advance(days: 1).at_noon }

        it 'should calculate price without discount' do
          reservations = ReservationSanitizer.new(user, params).create_reservations
          price = court.price_at(start_time, start_time + 60.minutes, nil)

          expect(reservations.first.price).to eq price
        end

        it 'should calculate price with discount' do
          discount = create(:discount, venue: venue)
          user.discounts << discount

          reservations = ReservationSanitizer.new(user, params).create_reservations
          price = court.price_at(start_time, start_time + 60.minutes, discount)

          expect(reservations.first.price).to eq price
        end
      end

      context 'multiple reservations' do
        it 'should create reservations with same time but different courts' do
          params[:bookings] = [
            {start_time: Time.current.advance(days: 1).at_noon.to_s,
              id: venue.courts.first.id},
            {start_time: Time.current.advance(days: 1).at_noon.to_s,
              id: venue.courts.last.id},
          ].to_json

          reservations = ReservationSanitizer.new(user, params).create_reservations

          expect(reservations).not_to eq nil
          expect(Reservation.all.count).to eq 2
        end

        it 'should create reservations with different time but same court' do
          params[:bookings] = [
            {start_time: Time.current.at_noon.advance(days: 1).to_s,
              id: venue.courts.first.id},
            {start_time: Time.current.at_noon.advance(days: 1, hours: 1).to_s,
              id: venue.courts.first.id},
          ].to_json

          reservations = ReservationSanitizer.new(user, params).create_reservations

          expect(reservations).not_to eq nil
          expect(Reservation.all.count).to eq 2
        end

        it 'should not create duplicating user-venue connections' do
          params[:bookings] = [
            {start_time: Time.current.at_noon.advance(days: 1).to_s,
              id: venue.courts.first.id},
            {start_time: Time.current.at_noon.advance(days: 1, hours: 1).to_s,
              id: venue.courts.first.id},
          ].to_json

          ReservationSanitizer.new(user, params).create_reservations

          expect(VenueUserConnector.all.count).to eq 1
        end
      end
    end

    context 'invalid reservations' do
      before do
        params[:bookings] = [
          { # valid
            start_time: Time.current.advance(days: 1).at_noon.to_s,
            id: venue.courts.first.id},
          { # invalid
            start_time: Time.current.advance(days: -1).at_noon.to_s,
            id: venue.courts.first.id},
        ].to_json
      end

      it 'should return nil if any reservation is invalid' do
        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations).to eq nil
      end

      it 'should not create any reservations' do
        ReservationSanitizer.new(user, params).create_reservations

        expect(Reservation.all.count).to eq 0
      end

      it 'should not create any reservations or connectors if have overlapping reservations' do
        params[:bookings] = [
          {start_time: Time.current.advance(days: 1).at_noon.to_s,
            id: venue.courts.first.id},
          {start_time: Time.current.advance(days: 1).at_noon.to_s,
            id: venue.courts.first.id},
        ].to_json

        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations).to eq nil
        expect(Reservation.all.count).to eq 0
        expect(VenueUserConnector.all.count).to eq 0
      end

      it 'should handle invalid court' do
        params[:bookings] = [
          {start_time: Time.current.advance(days: 1).at_noon.to_s,
            id: ''},
          {start_time: Time.current.advance(days: 2).at_noon.to_s,
            id: ''},
        ].to_json

        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations).to eq nil
        expect(Reservation.all.count).to eq 0
      end

      it 'should handle invalid time' do
        params[:bookings] = [
          {start_time: '',
            id: venue.courts.first.id},
          {start_time: '',
            id: venue.courts.first.id},
        ].to_json

        reservations = ReservationSanitizer.new(user, params).create_reservations

        expect(reservations).to eq nil
        expect(Reservation.all.count).to eq 0
      end

      context "date limit policy" do
        let(:start_time) { Time.current.at_noon }

        it "should be invalid when date after booking_ahead_limit" do
          params[:bookings] = [
            {start_time: start_time.advance(days: venue.booking_ahead_limit).to_s,
              id: venue.courts.first.id}
          ].to_json

          reservations = ReservationSanitizer.new(user, params).create_reservations

          expect(reservations).to eq nil
          expect(Reservation.all.count).to eq 0
        end

        it "should be valid when date before booking_ahead_limit" do
          params[:bookings] = [
            {start_time: start_time.advance(days: venue.booking_ahead_limit - 1).to_s,
              id: venue.courts.first.id}
          ].to_json

          reservations = ReservationSanitizer.new(user, params).create_reservations

          expect(reservations).not_to eq nil
          expect(Reservation.all.count).to eq 1
        end
      end
    end

    context 'paid reservations' do
      before do
        user.add_stripe_id(stripe_token.id)
        params[:pay] = 'true'
        params[:card] = user.cards.first.id
      end
    end
  end

  def stripe_token
    Stripe::Token.create( card: {
                            number: "4242424242424242",
                            exp_month: 1,
                            exp_year: 2017,
                            cvc: 314 }
                        )
  end
end
