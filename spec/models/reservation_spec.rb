require "rails_helper"

describe Reservation do
  context "creation and validations" do
    let(:reservation) { build :reservation }

    it "should save default reservation" do
      r = create :reservation

      expect(r.persisted?).to be_truthy
    end

    describe "#user" do
      context "validate presence" do
        it "should add error when absent" do
          reservation.user = nil

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:user)
        end

        it "should be valid when present" do
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:user)
        end
      end
    end

    describe "#court" do
      context "validate presence" do
        it "should add error when absent" do
          reservation.court = nil

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:court)
        end

        it "should be valid when present" do
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:court)
        end
      end
    end

    describe "#price" do
      context "validate presence" do
        it "should add error when absent" do
          reservation.price = nil

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:price)
        end

        it "should be valid when present" do
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:price)
        end
      end

      context "validate value" do
        it "should be numerical" do
          reservation.price = 'a'

          expect(reservation.valid?).to be_falsey
        end

        it "should be greater or equal to 0" do
          reservation.price = -1

          expect(reservation.valid?).to be_falsey

          reservation.price = 0

          expect(reservation.valid?).to be_truthy
        end
      end
    end

    describe "#start_time" do
      context "validate presence" do
        it "should add error when absent" do
          reservation.start_time = nil

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:start_time)
        end

        it "should be valid when present" do
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end
    end

    describe "#end_time" do
      context "validate presence" do
        it "should add error when absent" do
          reservation.end_time = nil

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:end_time)
        end

        it "should be valid when present" do
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:end_time)
        end

        it "should not be greater than start_time" do
          reservation.end_time = reservation.start_time.advance(days: -1)

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:end_time)
        end
      end
    end

    describe "#in_the_future" do
      before do
        allow(Time).to receive(:current).and_return(Time.current.at_noon)
      end

      context "for user" do
        it "should add error when in the past" do
          reservation = build :reservation, start_time: Time.current.advance(seconds: -1).utc

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:start_time)
        end

        it "should be valid when in the future" do
          reservation = build :reservation, start_time: Time.current.advance(seconds: 1).utc

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end

      context "for admin" do
        it "should be valid when in the past" do
          reservation = build :reservation, start_time: Time.current.advance(seconds: -1).utc, booking_type: :admin

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end

        it "should be valid when in the future" do
          reservation = build :reservation, start_time: Time.current.advance(seconds: 1).utc, booking_type: :admin

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end
    end

    describe "#no_overlapping_reservations (#overlapped?)" do
      let(:reserved) { create :reservation }
      let(:reservation) { build :reservation, court: reserved.court }

      context "overlapping reservation" do
        it "should add error when has overlapped start" do
          reservation.start_time = reserved.start_time + 50.minutes
          reservation.end_time   = reserved.end_time + 50.minutes

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:overlapping_reservation)
        end

        it "should add error when has overlapped end" do
          reservation.start_time = reserved.start_time - 50.minutes
          reservation.end_time   = reserved.end_time - 50.minutes

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:overlapping_reservation)
        end

        it "should add error when wrapped by longer reservation" do
          reservation.start_time = reserved.start_time + 15.minutes
          reservation.end_time   = reserved.end_time - 15.minutes

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:overlapping_reservation)
        end

        it "should add error when wrapping shorter reservation" do
          reservation.start_time = reserved.start_time - 30.minutes
          reservation.end_time   = reserved.end_time + 30.minutes

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:overlapping_reservation)
        end
      end

      context "adjacent and near reservation" do
        it "should be valid when touching reserved end" do
          reservation.start_time = reserved.end_time
          reservation.end_time   = reserved.end_time + 60.minutes

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end

        it "should be valid when touching reserved start" do
          reservation.start_time = reserved.start_time - 60.minutes
          reservation.end_time   = reserved.start_time

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end

        it "should be valid when not overlapped by earlier reservation" do
          reservation.start_time = reserved.end_time + 30.minutes
          reservation.end_time   = reserved.end_time + 90.minutes

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end

        it "should be valid when not overlapped by later reservation" do
          reservation.start_time = reserved.start_time - 90.minutes
          reservation.end_time   = reserved.start_time - 30.minutes

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end

      context "reservation with overlapping time but not overlapping params" do
        it "should be valid when overlapping reservation from different court" do
          reservation.start_time = reserved.start_time
          reservation.end_time   = reserved.end_time
          reservation.court = create(:court)

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end

        it "should be valid when overlapping itself" do
          expect(reserved.valid?).to be_truthy
          expect(reserved.errors).not_to include(:start_time)
        end
      end
    end

    describe "#not_on_offday" do
      let!(:day_off_start_time) { DateTime.now.in_time_zone.advance(weeks: 1).change(hour: 6, minute: 0, second: 0) }

      context "validate closed court on offday" do
        let!(:day_off) { create :day_off, :with_court, start_time: day_off_start_time }
        let!(:reservation) { build :reservation, court: day_off.place }

        it "should add error when court closed on offday" do
          reservation.start_time = day_off_start_time.change(hour: 10, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:Court)
        end

        it "should be valid when court not on offday" do
          reservation.start_time = day_off_start_time.advance(days: 2).change(hour: 10, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:Court)
        end
      end

      context "validate closed venue on offday" do
        let!(:day_off) { create :day_off, :with_venue, start_time: day_off_start_time }
        let!(:court) { create :court, venue: day_off.place }
        let!(:reservation) { build :reservation, court: court }

        it "should add error when venue closed on offday" do
          reservation.start_time = day_off_start_time.change(hour: 10, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:Court)
        end

        it "should be valid when venue not on offday" do
          reservation.start_time = day_off_start_time.advance(days: 2).change(hour: 10, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:Court)
        end
      end

      context "validate venue closed time" do
        let(:day) { DateTime.now.in_time_zone.advance(weeks: 1) }
        let(:opening_hour) { reservation.court.venue.opening_local(day).hour }
        let(:closing_hour) { reservation.court.venue.closing_local(day).hour }

        it "should add error if too early" do
          reservation.start_time = day.change(hour: opening_hour - 1, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:Court)
        end

        it "should add error if too late" do
          reservation.start_time = day.change(hour: closing_hour, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:Court)
        end

        it "should be valid if within time" do
          reservation.start_time = day.change(hour: opening_hour + 1, minute: 0, second: 0)
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.end_time.hour).to be < closing_hour
          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:Court)
        end
      end
    end

    describe "#duration_policy" do
      let(:court) { create :court, duration_policy: :two_hour }
      let(:reservation) { build :reservation, court: court }

      context "validate reseration duration" do
        it "should add error when duration lesser than court policy" do
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:duration_policy)
        end

        it "should be valid when duration equal than court policy" do
          reservation.end_time   = reservation.start_time + 2.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:duration_policy)
        end

        it "should be valid when duration greater than court policy" do
          reservation.end_time   = reservation.start_time + 3.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:duration_policy)
        end
      end
    end

    describe "#start_time_policy" do
      context "validate court any time policy" do
        let(:court) { create :court, start_time_policy: :any_start_time }
        let(:reservation) { build :reservation, court: court }

        it "should be valid when start at odd time" do
          reservation.start_time = reservation.start_time + 13.minutes
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end

      context "validate court hour policy" do
        let(:court) { create :court, start_time_policy: :hour_mark }
        let(:reservation) { build :reservation, court: court }

        it "should add error when start time not at start of hour" do
          reservation.start_time = reservation.start_time.at_noon + 30.minutes
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:start_time)
        end

        it "should be valid when start time at start of hour" do
          reservation.start_time = reservation.start_time.at_noon
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end

      context "validate court half hour policy" do
        let(:court) { create :court, start_time_policy: :half_hour_mark }
        let(:reservation) { build :reservation, court: court }

        it "should add error when start time not at half of hour" do
          reservation.start_time = reservation.start_time.at_noon
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:start_time)
        end

        it "should be valid when start time at half of hour" do
          reservation.start_time = reservation.start_time.at_noon + 30.minutes
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end
    end

    describe "#date_limit_policy" do
      let(:reservation) { build :reservation, start_time: DateTime.now.in_time_zone.change(hour: 12, minute: 0, second: 0) }
      let(:days) { reservation.court.venue.booking_ahead_limit }

      context "validate vanue booking ahead date limit" do
        it "should add error when date after booking_ahead_limit" do
          reservation.start_time   = reservation.start_time + (days + 1).days
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:start_time)
        end

        it "should be valid when date before booking_ahead_limit" do
          reservation.start_time   = reservation.start_time + (days - 1).days
          reservation.end_time   = reservation.start_time + 1.hours

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:start_time)
        end
      end
    end

    describe "#court_active" do
      context "validate if court is open" do
        it 'should add error when court is closed(not active)' do
          reservation.court.update_attribute(:active, false)

          expect(reservation.valid?).to be_falsey
          expect(reservation.errors).to include(:court)
        end

        it 'should be valid when court is open' do
          reservation.court.update_attribute(:active, true)

          expect(reservation.valid?).to be_truthy
          expect(reservation.errors).not_to include(:court)
        end
      end
    end
  end

  describe "#overlapping?" do
    let(:reservation) { build :reservation }

    context "reservation overlapping starts..ends time" do
      it "should be true when overlapping starts" do
        result = reservation.overlapping?(reservation.start_time + 50.minutes, reservation.end_time + 50.minutes)

        expect(result).to be_truthy
      end

      it "should be true when overlapping ends" do
        result = reservation.overlapping?(reservation.start_time - 50.minutes, reservation.end_time - 50.minutes)

        expect(result).to be_truthy
      end

      it "should be true when wrapped by starts..ends" do
        result = reservation.overlapping?(reservation.start_time - 10.minutes, reservation.end_time + 10.minutes)

        expect(result).to be_truthy
      end

      it "should be true when wrapping starts..ends" do
        result = reservation.overlapping?(reservation.start_time + 10.minutes, reservation.end_time - 10.minutes)

        expect(result).to be_truthy
      end
    end

    context "reservation not overlapping adjacent and near time" do
      it "should be false when touching ends" do
        result = reservation.overlapping?(reservation.start_time - 60.minutes, reservation.start_time)

        expect(result).to be_falsey
      end

      it "should be false when touching starts" do
        result = reservation.overlapping?(reservation.end_time, reservation.end_time + 60.minutes)

        expect(result).to be_falsey
      end

      it "should be false when not overlapping and later" do
        result = reservation.overlapping?(reservation.start_time - 70.minutes, reservation.start_time - 10.minutes)

        expect(result).to be_falsey
      end

      it "should be false when not overlapping and earlier" do
        result = reservation.overlapping?(reservation.end_time + 10.minutes, reservation.end_time + 70.minutes)

        expect(result).to be_falsey
      end
    end
  end

  context "reservations resell" do
    let(:reservation) { build :reservation, reselling: true }

    describe "#overlapping?" do
      it 'should be false when reselling and matching time' do
        result = reservation.overlapping?(reservation.start_time, reservation.end_time)

        expect(result).to be_falsey
      end

      it 'should be true when reselling and not matching time' do
        result = reservation.overlapping?(reservation.start_time, reservation.end_time - 1.minute)

        expect(result).to be_truthy
      end
    end

    describe "#take_matching_resell" do
      let(:membership) { create :membership, :with_user, :with_venue}
      let(:resell) { create :reservation, reselling: true, booking_type: :membership, membership: membership,
                                          user: membership.user, court: membership.venue.courts.first }
      let(:booking) { build :reservation, court: resell.court, start_time: resell.start_time,
          end_time: resell.end_time, price: resell.price + 7 }

      context "find matching resell" do
        it 'should find reselling reservation with matching time and court' do
          expect(booking.take_matching_resell.id).to eq resell.id
        end

        it 'should return self when reselling reservation with not matching time' do
          booking.start_time = resell.start_time + 1.minute

          expect(booking.take_matching_resell).to eq booking
        end

        it 'should return self when reselling reservation with not matching court' do
          booking.court = create :court

          expect(booking.take_matching_resell).to eq booking
        end

        it 'should return self when usual reservation with matching time ' do
          non_resell = create :reservation
          booking = build :reservation, court: non_resell.court
          booking.start_time = non_resell.start_time
          booking.end_time = non_resell.end_time

          expect(booking.take_matching_resell).to eq booking
        end
      end

      context "assign params to takeover ownership" do
        it 'should set :user to new user' do
          expect(booking.user.id).not_to eq resell.user.id
          expect(booking.take_matching_resell.user).to eq booking.user
        end
      end

      context "assign params to make reservation resold and reversible" do
        it 'should set initial membership to previous membership' do
          initial_membership = Membership.find(booking.take_matching_resell.initial_membership_id)
          expect(initial_membership).to eq resell.membership
        end

        it 'should be able to find previous user through initial_membership' do
          initial_membership = Membership.find(booking.take_matching_resell.initial_membership_id)
          expect(initial_membership.user).to eq resell.user
        end
      end

      context "assign params to make resell like usual reservation" do
        it 'should set booking price' do
          expect(booking.price).not_to eq resell.price
          expect(booking.take_matching_resell.price).to eq booking.price
        end

        it 'should set online booking type' do
          expect(booking.take_matching_resell.booking_type).to eq :online.to_s
        end

        it 'should set reselling to false' do
          expect(booking.take_matching_resell.reselling).to be_falsey
        end
      end

      context "valid reservation with assigned attributes" do
        it 'should save taken resell without errors' do
          expect{booking.take_matching_resell.save!}.not_to raise_error
        end

        it 'should delete membership_connector after saved' do
          new_reservation = booking.take_matching_resell
          new_reservation.save!
          new_reservation.reload
          expect(new_reservation.membership).to eq nil
        end

        it 'should not delete membership_connector until saved' do
          new_reservation = booking.take_matching_resell
          new_reservation.reload
          expect(new_reservation.membership).not_to eq nil
        end

        it 'should not delete membership' do
          new_reservation = booking.take_matching_resell
          new_reservation.save!
          expect{Membership.find(new_reservation.initial_membership_id)}.not_to raise_error
        end
      end
    end

    describe '#resell_to_user' do
      let(:membership) { create :membership, :with_user, :with_venue}
      let(:resell) { create :reservation, reselling: true, booking_type: :membership, membership: membership,
                                          user: membership.user, court: membership.venue.courts.first }
      let(:new_owner) { create :user }

      context "deny invalid input" do
        it 'should return false if not reselling' do
          resell.reselling = false
          expect(resell.resell_to_user(new_owner)).to be_falsey
        end

        it 'should return false if not recurring' do
          resell.membership = nil

          expect(resell.resell_to_user(new_owner)).to be_falsey
        end

        it 'should return false if resold' do
          resell.initial_membership_id = resell.membership.id

          expect(resell.resell_to_user(new_owner)).to be_falsey
        end

        it 'should return false if new owner is blank' do
          expect(resell.resell_to_user(nil)).to be_falsey
        end

        it 'should return false if new owner is not User' do
          expect(resell.resell_to_user(Reservation.new())).to be_falsey
        end
      end

      context "assign params to takeover ownership" do
        it 'should set :user to new user' do
          resell.resell_to_user(new_owner)
          expect(resell.user).to eq new_owner
        end

        it 'should be saved' do
          expect(resell.resell_to_user(new_owner)).to be_truthy
          expect(resell.reload.user).to eq new_owner
        end
      end

      context "assign params to make reservation resold and reversible" do
        it 'should set initial membership to previous membership' do
          initial_membership = resell.membership
          resell.resell_to_user(new_owner)

          expect(resell.initial_membership_id).to eq initial_membership.id
        end
      end

      context "assign params to make resell like usual reservation" do
        it 'should set online booking type' do
          resell.resell_to_user(new_owner)
          expect(resell.booking_type).to eq :online.to_s
        end

        it 'should set reselling to false' do
          resell.resell_to_user(new_owner)
          expect(resell.reselling).to be_falsey
        end

        it 'should delete membership_connector' do
          resell.resell_to_user(new_owner)
          resell.reload
          expect(resell.membership).to eq nil
        end

        it 'should not delete membership' do
          resell.resell_to_user(new_owner)

          expect{Membership.find(resell.initial_membership_id)}.not_to raise_error
        end
      end
    end

    describe "#pass_back_to_initial_owner" do
      let(:membership) { create :membership, :with_user, :with_venue}
      let(:resell) { create :reservation, reselling: true, booking_type: :membership, membership: membership,
                                          user: membership.user, court: membership.venue.courts.first }
      let(:booking) { build :reservation, court: resell.court, start_time: resell.start_time,
          end_time: resell.end_time, price: resell.price + 7 }
      let(:reservation) { booking.take_matching_resell }

      before do
        reservation.save
        reservation.reload
      end

      context "pass back ownership" do
        it 'should set user to initial user' do
          expect(reservation.user).not_to eq membership.user

          reservation.pass_back_to_initial_owner

          expect(reservation.user).to eq membership.user
        end
      end

      context "lift resold status" do
        it 'should set initial_membership to nil' do
          reservation.pass_back_to_initial_owner

          expect(reservation.initial_membership_id).to be_nil
        end

        it 'should connect to initial membership' do
          reservation.pass_back_to_initial_owner

          expect(reservation.membership).to eq membership
        end
      end

      context "restore reservation to original resell" do
        it 'should set price to membership price' do
          price = reservation.price
          reservation.pass_back_to_initial_owner

          expect(reservation.price).not_to eq price
          expect(reservation.price).to eq membership.price
        end

        it 'should set booking_type to membership' do
          reservation.pass_back_to_initial_owner

          expect(reservation.booking_type).to eq :membership.to_s
        end

        it 'should set refunded to false' do
          reservation.pass_back_to_initial_owner

          expect(reservation.refunded).to be_falsey
        end

        it 'should set reselling to true' do
          reservation.pass_back_to_initial_owner

          expect(reservation.reselling).to be_truthy
        end
      end
    end
  end
end
