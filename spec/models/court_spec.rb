require 'rails_helper'

describe Court do
  before(:all) do
    @venue = FactoryGirl.create(:venue)
  end

  after(:all) do
    @venue.destroy
  end

  context "Court Sharing" do
    let!(:tennis_court_1) { FactoryGirl.create(:court, sport_name: :tennis, venue: @venue) }
    let!(:squash_court_1) { FactoryGirl.create(:court, sport_name: :squash, venue: @venue) }
    let!(:squash_court_2) { FactoryGirl.create(:court, sport_name: :squash, venue: @venue) }

    context "create shared courts and reservations" do
      before do
        tennis_court_1.shared_courts << squash_court_1
        tennis_court_1.shared_courts << squash_court_2
      end

      it "should create shared_courts" do
        expect(tennis_court_1.shared_courts.to_a).to eq [squash_court_1, squash_court_2]
      end

      it "should create reciprocal shared_court relationship" do
        expect(squash_court_1.shared_courts.to_a).to eq [tennis_court_1]
        expect(squash_court_2.shared_courts.to_a).to eq [tennis_court_1]
        expect(CourtConnector.count).to eq(4)
      end

      it "should not allow sharing with same court" do
        expect {tennis_court_1.shared_courts << tennis_court_1}.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "overlapping reservations" do
        let!(:tennis_court_1_reservation){FactoryGirl.create(:reservation, court: tennis_court_1)}

        it "should not allow shared court overlapping reservation" do
          tennis_court_1.shared_courts.each do |court|
            squash_court_1_reservation = FactoryGirl.build(:reservation,
              court: court,
              start_time: tennis_court_1_reservation.start_time)

            expect(squash_court_1_reservation.valid?).to be_falsy
            expect(squash_court_1_reservation.errors).to include(:overlapping_reservation)
          end
        end
      end
    end

    context "Remove court sharing" do
      before do
        tennis_court_1.shared_courts << squash_court_1
        tennis_court_1.shared_courts << squash_court_2
        tennis_court_1.shared_courts.destroy(squash_court_1)
      end

      it "should remove reciprocal shared court" do
        expect(tennis_court_1.shared_courts).not_to include(squash_court_1)
        expect(squash_court_1.shared_courts).not_to include(tennis_court_1)
      end
    end
  end

  context 'Price for timeslot' do
    let!(:court) { create :court }
    let!(:start_time) { Time.current.advance(weeks: 2).beginning_of_week.at_noon }
    let!(:end_time) { start_time + 120.minutes }

    describe '#has_price?' do
      it 'should return true if price fully covers timeslot' do
        price = create(:price, start_time: start_time - 1.minutes, end_time: end_time + 1.minutes, monday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_truthy
      end

      it 'should return false if price fully covers timeslot but other weekday' do
        price = create(:price, start_time: start_time - 1.minutes, end_time: end_time + 1.minutes, tuesday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_falsy
      end

      it 'should return true if price exactly covers timeslot' do
        price = create(:price, start_time: start_time, end_time: end_time, monday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_truthy
      end

      it 'should return true if 3 prices cover timeslot back to back' do
        price1 = create(:price, start_time: start_time, end_time: start_time + 60.minutes, monday: true)
        create(:divider, price: price1, court: court)
        price2 = create(:price, start_time: start_time + 61.minutes, end_time: start_time + 90.minutes, monday: true)
        create(:divider, price: price2, court: court)
        price3 = create(:price, start_time: start_time + 91.minutes, end_time: end_time, monday: true)
        create(:divider, price: price3, court: court)

        expect(court.has_price?(start_time, end_time)).to be_truthy
      end

      it 'should return false if price not covers at all' do
        price = create(:price, start_time: start_time + 1.minutes, end_time: end_time - 1.minutes, monday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_falsy
      end

      it 'should return false if price not covers beginning' do
        price = create(:price, start_time: start_time + 1.minutes, end_time: end_time, monday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_falsy
      end

      it 'should return false if price not covers ending' do
        price = create(:price, start_time: start_time, end_time: end_time - 1.minutes, monday: true)
        create(:divider, price: price, court: court)

        expect(court.has_price?(start_time, end_time)).to be_falsy
      end

      it 'should return false if 2 prices not cover middle' do
        price1 = create(:price, start_time: start_time, end_time: start_time + 59.minutes, monday: true)
        create(:divider, price: price1, court: court)
        price2 = create(:price, start_time: end_time - 59.minutes, end_time: end_time, monday: true)
        create(:divider, price: price2, court: court)

        expect(court.has_price?(start_time, end_time)).to be_falsy
      end
    end

    describe '#price_at' do
      it 'should correctly sum applied prices for hour mark timeslots' do
        price1 = create(:price, price: 10, start_time: start_time, end_time: start_time + 60.minutes, monday: true)
        create(:divider, price: price1, court: court)
        price2 = create(:price, price: 20, start_time: start_time + 60.minutes, end_time: start_time + 180.minutes, monday: true)
        create(:divider, price: price2, court: court)

        expect(court.price_at(start_time, start_time + 60.minutes )).to eq price1.price
        expect(court.price_at(start_time, start_time + 120.minutes)).to eq (price1.price + price2.price)
        expect(court.price_at(start_time, start_time + 180.minutes)).to eq (price1.price + price2.price * 2)
        expect(court.price_at(start_time + 60.minutes , start_time + 120.minutes)).to eq price2.price
        expect(court.price_at(start_time + 120.minutes , start_time + 180.minutes)).to eq price2.price
      end

      it 'should correctly sum applied prices for halfhour mark timeslots' do
        price1 = create(:price, price: 10, start_time: start_time - 60.minutes, end_time: start_time + 60.minutes, monday: true)
        create(:divider, price: price1, court: court)
        price2 = create(:price, price: 20, start_time: start_time + 60.minutes, end_time: start_time + 280.minutes, monday: true)
        create(:divider, price: price2, court: court)

        expect(court.price_at(start_time - 30.minutes, start_time + 90.minutes )).to eq (price1.price*1.5 + price2.price*0.5)
        expect(court.price_at(start_time + 30.minutes, start_time + 90.minutes )).to eq (price1.price*0.5 + price2.price*0.5)
        expect(court.price_at(start_time + 30.minutes, start_time + 150.minutes)).to eq (price1.price*0.5 + price2.price*1.5)
      end

      it 'should apply discount if given' do
        price1 = create(:price, price: 10, start_time: start_time, end_time: start_time + 60.minutes, monday: true)
        create(:divider, price: price1, court: court)
        discount = build(:discount, venue: court.venue)

        expect(court.price_at(start_time, start_time + 60.minutes, discount)).to eq (price1.price / 2)
      end
    end
  end
end
