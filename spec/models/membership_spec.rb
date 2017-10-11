require "rails_helper"

describe Membership do

  context "field validations" do
    let(:membership) {FactoryGirl.build(:membership, :with_user, :with_venue)}

    describe "#start_time" do
      context "validate presence" do

        it "should add error when absent" do
          membership.start_time = nil
          expect(membership.valid?).to be_falsey
          expect(membership.errors).to include(:start_time)
        end

        it "should be valid when present" do
          expect(membership.valid?).to be_truthy
          expect(membership.errors).not_to include(:start_time)
        end
      end
    end

    describe "#end_time" do
      context "validate presence" do
        it "should add error when absent" do
          membership.end_time = nil
          expect(membership.valid?).to be_falsey
          expect(membership.errors).to include(:end_time)
        end

        it "should be valid when present" do
          expect(membership.valid?).to be_truthy
          expect(membership.errors).not_to include(:end_time)
        end

        it "should not be greater than start_time" do
          membership.end_time = membership.start_time.advance(days: -1)
          expect(membership.valid?).to be_falsey
          expect(membership.errors).to include(:end_time)
        end
      end
    end

    describe "#price" do
      context "validate presence" do
        it "should add error when absent" do
          membership.price = nil
          expect(membership.valid?).to be_falsey
          expect(membership.errors).to include(:price)
        end

        it "should be valid when present" do
          expect(membership.valid?).to be_truthy
          expect(membership.errors).not_to include(:price)
        end
      end

      it "should be greater or equal to 0" do
        membership.price = -1
        expect(membership.valid?).to be_falsey

        membership.price = 0
        expect(membership.valid?).to be_truthy
      end
    end
  end



  context "associations" do
    let(:membership){FactoryGirl.build(:membership, :with_user, :with_venue)}

    before do
      membership.reservations << FactoryGirl.build(:reservation, court: membership.venue.courts.first, user: membership.user)
      membership.reservations << FactoryGirl.build(:reservation, court: membership.venue.courts.second, user: membership.user)
      membership.save!
    end

    it "should belong to a user" do
      expect(Membership.reflect_on_association(:user).macro).to eq(:belongs_to)
      expect(membership.user).not_to be_nil
    end

    it "should belong to a venue" do
      expect(Membership.reflect_on_association(:venue).macro).to eq(:belongs_to)
      expect(membership.venue).not_to be_nil
    end

    it "should have many reservations" do
      expect(Membership.reflect_on_association(:reservations).macro).to eq(:has_many)
      expect(membership.reservations.length).to eq(2)
    end

    it "should have many membership_connectors" do
      expect(Membership.reflect_on_association(:membership_connectors).macro).to eq(:has_many)
      expect(membership.membership_connectors.length).to eq(2)
    end
  end

  describe "#make_reservations" do
    let(:membership) {FactoryGirl.build(:membership, :with_user, :with_venue)}
    let(:court){membership.venue.courts.first}
    let(:tparams){
      # start_time = DateTime.now.utc.beginning_of_week.next_week.at_noon
      {
        :start_time => membership.start_time,
        :end_time => membership.start_time.advance(hours: 1),
        :membership_start_time => membership.start_time,
        :membership_end_time => membership.end_time
      }
    }

    context "negative tests" do
      it "should not create reservation after membership ends" do
        tparams[:start_time] = membership.end_time.advance(days: 1)

        membership.make_reservations(tparams.dup, court.id)
        expect(membership.reservations.count).to eq(0)
      end

      it "should not create reservations for past dates" do
        tparams[:start_time] = DateTime.now.utc.advance(month: 1).change(hour: 10)

        membership.make_reservations(tparams.dup, court.id)
        expect(membership.reservations.count).to eq(calculate_number_of_reservations(tparams, court))
      end
    end

    context "Positive tests" do
      it "should build reservations" do
        membership.make_reservations(tparams.dup, court.id)
        expect(membership.reservations.length).to be > 0
      end

      context "should build correct number of reservations" do
        weeks = [-1, 0, 1, 2, 3, 4, 5]
        weeks.each do |week|
          it "if start_time is advanced by #{week} week" do
            tparams[:start_time] = tparams[:start_time].advance(weeks: week)
            tparams[:end_time] = tparams[:start_time].advance(hours: 1)
            reservation_count = calculate_number_of_reservations(tparams, court)
            membership.make_reservations(tparams.dup, court.id)
            expect(membership.reservations.length).to eq(reservation_count)
          end
        end

        context "should build reservations with correct timings (whole year)" do
          before do
            membership.end_time = membership.start_time.advance(months: 12, hours: 1)
            tparams[:membership_end_time] = membership.end_time
          end

          it "start_time" do
            membership.make_reservations(tparams.dup, court.id)

            reservation_timings = membership.reservations.map{|r| r.start_time.in_time_zone.strftime("%H:%M") }.uniq
            expect(reservation_timings).to eq([ (tparams[:start_time].in_time_zone.strftime("%H:%M")) ])
          end

          it "end_time" do
            membership.make_reservations(tparams.dup, court.id)

            reservation_timings = membership.reservations.map{|r| r.end_time.in_time_zone.strftime("%H:%M") }.uniq
            expect(reservation_timings).to eq([ (tparams[:end_time].in_time_zone.strftime("%H:%M")) ])
          end

        end
      end
    end


    context "no_overlapping_reservations" do
      context "without ignore_overlapping_reservations attribute" do
        it "should not create overlapping reservations" do
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.not_to raise_error
          initial_reservations = membership.reservations.count

          # make reservations for the same timings
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.to raise_error(ActiveRecord::RecordInvalid)
          expect(membership.reservations.count).not_to be > initial_reservations
        end
      end

      context "with ignore_overlapping_reservations attribute" do
        it "should create non-overlapping reservations without raising error" do
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.not_to raise_error
          initial_reservations = membership.reservations.count

          # make reservations with overlapping timings
          membership.ignore_overlapping_reservations = true
          tparams[:membership_end_time] = tparams[:membership_end_time].advance(months: 1)
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.not_to raise_error
          expect(membership.reservations.count).to be > initial_reservations

        end

        context 'reservation.destroy in #handle_overlapping_reservation' do
          before do
            membership.make_reservations(tparams.dup, court.id)
            membership.save
          end

          it 'should not create membership_connectors for invalid reservations' do
            initial_connectors_count = membership.membership_connectors.count
            # will build and destroy overlapping reservations
            membership.ignore_overlapping_reservations = true
            membership.make_reservations(tparams.dup, court.id)
            membership.save

            expect(membership.membership_connectors.reload.count).to eq initial_connectors_count
          end

          it 'should not delete membership together with invalid reservations' do
            # will build and destroy overlapping reservations
            membership.ignore_overlapping_reservations = true
            membership.make_reservations(tparams.dup, court.id)
            membership.save

            expect(Membership.find_by_id(membership.id)).not_to eq nil
          end
        end
      end
    end

    context "not_on_offday" do
      let(:day_off_start_time) { membership.start_time.utc.advance(weeks: 3).change(hour: 6, minute: 0, second: 0) }
      let(:day_off) { build(:day_off, :with_court, place: court, start_time: day_off_start_time) }
      before do
        tparams[:start_time] = day_off_start_time.change(hour: 10, minute: 0, second: 0)
        tparams[:end_time] = tparams[:start_time].advance(hours:1)
      end

      it "should make reservations without off days and be valid" do
        membership.make_reservations(tparams.dup, court.id)

        expect(membership.valid?).to be_truthy
        expect(membership.reservations.select(&:valid?).length).to eq membership.reservations.length
      end

      it "should not make reservation on off day and be invalid" do
        day_off.save!
        membership.make_reservations(tparams.dup, court.id)

        expect(membership.valid?).to be_falsey
        expect(membership.reservations.select(&:valid?).length).to eq membership.reservations.length - 1
      end
    end

    context "duration_policy" do
      context "duration policy -1 (any)" do
        before do
          court.duration_policy = -1
          court.save!
        end

        [20, 60, 120].each do |duration|
          it "should allow duration of #{duration}" do
            tparams[:end_time] = tparams[:start_time].advance(minutes: duration)
            membership.make_reservations(tparams.dup, court.id)
            expect{membership.save!}.not_to raise_error
            expect(membership.reservations.count).to eq(calculate_number_of_reservations(tparams, court))
          end
        end

      end

      context "fixed duration policy" do
        before do
          court.duration_policy = 60
          court.save!
        end

        it "should not allow duration less than duration policy" do
          tparams[:end_time] = tparams[:start_time].advance(minutes: 30)
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.to raise_error(ActiveRecord::RecordInvalid)
        end

        it "should allow valid duration" do
          tparams[:end_time] = tparams[:start_time].advance(hours: 1)
          membership.make_reservations(tparams.dup, court.id)
          expect{membership.save!}.not_to raise_error
        end
      end

    end

    context "start_time_policy" do
      context "should not apply for members" do
        before do
          tparams[:start_time] = tparams[:start_time].change(min: 10)
          tparams[:end_time] = tparams[:end_time].change(min: 10)
        end

        [:hour_mark, :half_hour_mark].each do |policy, min|
          it "test for #{policy}" do
            court.start_time_policy = policy
            court.save!

            membership.make_reservations(tparams.dup, court.id)
            expect{membership.save!}.not_to raise_error
            expect(membership.reservations.count).to eq(calculate_number_of_reservations(tparams, court))
          end
        end
      end
    end


    context "court_active" do
      it "should not make reservation if inactive" do
        court.active = false
        court.save!

        membership.make_reservations(tparams.dup, court.id)
        expect{membership.save!}.to raise_error(ActiveRecord::RecordInvalid)
        expect(membership.reservations.count).to eq(0)
      end

      it "should make reservation if active" do
        court.active = true
        court.save!

        membership.make_reservations(tparams.dup, court.id)
        expect{membership.save!}.not_to raise_error
        expect(membership.reservations.count).to eq(calculate_number_of_reservations(tparams, court))
      end
    end
  end


  describe "#handle_destroy" do
    let(:membership) { FactoryGirl.create(:membership, :with_user, :with_venue) }
    let(:other_membership) {FactoryGirl.create(:membership, :with_user, :with_venue, user: membership.user, venue: membership.venue) }

    before do
      start_time = membership.start_time.advance(weeks: 3)
      membership.reservations << create(:reservation, court: membership.venue.courts.first,
                                                      user: membership.user,
                                                      start_time: start_time)
      membership.reservations << create(:reservation, court: membership.venue.courts.second,
                                                      user: membership.user,
                                                      start_time: start_time)
      membership.save!

      other_membership.reservations << create(:reservation,
        court: other_membership.venue.courts.second,
        user: other_membership.user,
        start_time: start_time.advance(days: 1))
      other_membership.save!

      membership.handle_destroy
    end

    it "should delete current membership" do
      expect{Membership.find(membership.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should delete associated membership_connectors" do
      expect(MembershipConnector.where(membership_id: membership.id)).to be_empty
    end

    it "should delete all future reservations for current membership" do
      future_reservation_count = membership.reservations.select {|r| r.start_time > Time.now.utc }.count
      expect(future_reservation_count).to eq(0)
    end

    it "should not delete other memberships" do
      expect(other_membership.reservations.count).to eq(1)
    end

    it "should not delete other membership connectors" do
      expect(other_membership.membership_connectors.count).to eq(1)
    end
  end

  describe "#handle_update" do
    let(:membership){FactoryGirl.create(:membership, :with_user, :with_venue)}

    before do
      court = membership.venue.courts.first
      tparams = {
        :start_time => membership.start_time.advance(days: 1),
        :end_time => membership.start_time.advance(days: 1, hours: 2),
        :membership_start_time => membership.start_time,
        :membership_end_time => membership.end_time
      }
      membership.make_reservations(tparams.dup, court.id)
      membership.save!

      # update membership
      @tparams = {
        :membership_start_time => membership.start_time.advance(days: 7),
        :membership_end_time => membership.end_time.advance(days: 7),
        :start_time => tparams[:start_time].advance(weeks: 1, hours: 1),
        :end_time => tparams[:end_time].advance(weeks: 1, hours: 1),
      }
      new_court = membership.venue.courts[1]
      @membership_params = { :court_id => new_court.id, :price => membership.price + 10 }
    end

    it "should return true if success" do
      expect(membership.handle_update(@membership_params.dup, @tparams.dup)).to be_truthy
    end

    it "should update court" do
      expect(membership.handle_update(@membership_params.dup, @tparams.dup)).to be_truthy
      expect(membership.reservations.first.court.id).to eq(@membership_params[:court_id])
    end

    it "should delete existing future reservations and create new ones" do
      expect(membership.handle_update(@membership_params.dup, @tparams.dup)).to be_truthy
      court = Court.find(@membership_params[:court_id])
      expect(membership.reservations.count).to eq(calculate_number_of_reservations(@tparams, court))
    end

    it "should update membership timings" do
      expect(membership.handle_update(@membership_params.dup, @tparams.dup)).to be_truthy

      reservations_start_time = @tparams[:start_time]
      while reservations_start_time < Time.now.utc
        reservations_start_time += 1.weeks
      end
      reservations_end_time = reservations_start_time.advance(hours: 2)

      expect(membership.start_time).to eq(@tparams[:membership_start_time])
      expect(membership.end_time).to eq(@tparams[:membership_end_time])
      expect(membership.reservations.first.start_time).to eq reservations_start_time
      expect(membership.reservations.first.end_time).to eq reservations_end_time
    end
  end

end
