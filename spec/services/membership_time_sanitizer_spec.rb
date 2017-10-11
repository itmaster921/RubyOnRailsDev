require 'rails_helper'

describe MembershipTimeSanitizer do
  let!(:current_time) { Time.current }
  let(:membership_params) do
    {
      :start_time => "10:00",
      :end_time => "11:00",
      :weekday => "Sunday",
      :start_date => current_time.advance(days: 1).to_s(:date),
      :end_date => current_time.advance(days: 15).to_s(:date)
    }
  end

  describe '#membership_start_time' do
    it 'should parse time from local timezone' do
      gauge = current_time.advance(days: 1).beginning_of_day.change(hour: 10).utc
      sanitizer = MembershipTimeSanitizer.new(membership_params)

      expect(sanitizer.membership_start_time).to eq gauge
    end

    it 'should return time in utc' do
      sanitizer = MembershipTimeSanitizer.new(membership_params)

      expect(sanitizer.membership_start_time.zone).to eq current_time.utc.zone
    end
  end

  describe '#membership_end_time' do
    it 'should parse time from local timezone' do
      gauge = current_time.advance(days: 15).beginning_of_day.change(hour: 11).utc
      sanitizer = MembershipTimeSanitizer.new(membership_params)

      expect(sanitizer.membership_end_time).to eq gauge
    end

    it 'should return time in utc' do
      sanitizer = MembershipTimeSanitizer.new(membership_params)

      expect(sanitizer.membership_end_time.zone).to eq current_time.utc.zone
    end
  end

  context 'reservations time adjusted to weekday' do
    let!(:weekdays) { sorted_daynames }
    let!(:start_date) { current_time.advance(weeks: 2).beginning_of_week }
    let!(:end_date) { start_date.advance(weeks: 2) - 1.days }
    before do
      membership_params[:start_date] = start_date.change(hour: 10).to_s(:date)
      membership_params[:end_date]   = end_date.change(hour: 11).to_s(:date)
    end

    it 'test time weekday should be monday' do
      expect(start_date.strftime('%A')).to eq 'Monday'
    end

    describe '#reservations_start_time' do
      it 'should return start date(shifted for any weekday) with start time' do
        weekdays.each do |weekday|
          membership_params[:weekday] = weekday
          gauge = start_date.change(hour: 10).advance(days: weekdays.index(weekday)).utc
          sanitizer = MembershipTimeSanitizer.new(membership_params)

          expect(sanitizer.reservations_start_time).to eq gauge
        end
      end

      it 'should return start date with start time for invalid weekday' do
        membership_params[:weekday] = 'invalid'
        gauge = start_date.change(hour: 10).utc
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.reservations_start_time).to eq gauge
      end

      it 'should return time in utc' do
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.reservations_start_time.zone).to eq current_time.utc.zone
      end
    end

    describe '#reservations_end_time' do
      it 'should return start date(shifted for any weekday) with end time' do
        weekdays.each do |weekday|
          membership_params[:weekday] = weekday
          gauge = start_date.change(hour: 11).advance(days: weekdays.index(weekday)).utc
          sanitizer = MembershipTimeSanitizer.new(membership_params)

          expect(sanitizer.reservations_end_time).to eq gauge
        end
      end

      it 'should return membership start date with end time for invalid weekday' do
        membership_params[:weekday] = 'invalid'
        gauge = start_date.change(hour: 11).utc
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.reservations_end_time).to eq gauge
      end

      it 'should return time in utc' do
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.reservations_end_time.zone).to eq current_time.utc.zone
      end
    end

    describe '#last_reservation_start_time' do
      it 'should return end date(shifted back for any weekday) with start time' do
        weekdays.each do |weekday|
          membership_params[:weekday] = weekday
          shift = weekdays.index(weekday) - 6
          gauge = end_date.change(hour: 10).advance(days: shift).utc
          sanitizer = MembershipTimeSanitizer.new(membership_params)

          expect(sanitizer.last_reservation_start_time).to eq gauge
        end
      end

      it 'should return end date(shifted back for weekday of start date) with start time for invalid weekday' do
        membership_params[:weekday] = 'invalid'
        gauge = end_date.advance(days: - 6).change(hour: 10).utc
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.last_reservation_start_time).to eq gauge
      end

      it 'should return time in utc' do
        sanitizer = MembershipTimeSanitizer.new(membership_params)

        expect(sanitizer.reservations_end_time.zone).to eq current_time.utc.zone
      end
    end
  end
end

def sorted_daynames
  daynames = Date::DAYNAMES.map { |wday| wday }
  # we want them to start from monday
  if daynames.index(daynames.first) == 0
    daynames << daynames.shift
  end

  daynames.freeze
end
