require "rails_helper"

describe "prices" do
  let (:price) { Price.new }

  describe "start_time=" do
    it "works with date" do
      price.start_time = Time.new(1990, 1, 1, 10, 30, 0)
      expect(price.start_minute_of_a_day).to eq(10*60+30)
    end

    it "works with string" do
      price.start_time = "10:30"
      expect(price.start_minute_of_a_day).to eq(10*60+30)
    end
  end

  describe "end_time=" do
    it "works with date" do
      price.end_time = Time.new(1990, 1, 1, 10, 30, 0)
      expect(price.end_minute_of_a_day).to eq(10*60+30)
    end

    it "works with string" do
      price.end_time = "10:30"
      expect(price.end_minute_of_a_day).to eq(10*60+30)
    end
  end

  describe "#weekdays" do
    let (:price) { create :price, start_time: Time.new(1990, 1, 1, 10, 0, 0), end_time: Time.new(1990, 1, 1, 17, 0, 0), monday: true, tuesday: true}

    it "contains only working days" do
      expect(price.weekdays).to eq([:monday, :tuesday])
    end
  end

  describe "#set_weekdays" do
    let (:price) { create :price, start_time: Time.new(1990, 1, 1, 10, 0, 0), end_time: Time.new(1990, 1, 1, 17, 0, 0), monday: true, tuesday: true}

    it "contains only working days" do
      price.set_weekdays([:tuesday, :wednesday, :thursday])
      expect(price.monday).to be_falsy
      expect(price.tuesday).to be_truthy
      expect(price.wednesday).to be_truthy
      expect(price.thursday).to be_truthy
      expect(price.friday).to be_falsy
      expect(price.saturday).to be_falsy
      expect(price.sunday).to be_falsy
    end
  end

  describe "setting start and end minutes of a day" do
    let! (:price) { create :price, start_time: Time.new(1990, 1, 1, 10, 0, 0), end_time: Time.new(1990, 1, 1, 17, 0, 0), monday: true}

    it "sets start_minute_of_a_day" do
      expect(price.start_minute_of_a_day).to eq(10*60)
    end

    it "sets end_minute_of_a_day" do
      expect(price.end_minute_of_a_day).to eq(17*60)
    end

    describe "#update_start_and_end_minutes_of_a_day" do
      before do
        price.update_start_and_end_minutes_of_a_day(12*60, 17*60 + 30)
      end

      it "updates start_minute_of_a_day" do
        expect(price.start_minute_of_a_day).to eq(12*60)
      end

      it "updates end_minute_of_a_day" do
        expect(price.end_minute_of_a_day).to eq(17*60 + 30)
      end
    end
  end

  describe "pricing conflicts" do
    let (:admin) { create :admin }
    let (:company) { create :company }
    let (:venue) { create :venue, company: company }
    let! (:court1) { create :court, venue: venue }
    let! (:court2) { create :court, venue: venue }
    let! (:price) { create :price, start_time: Time.new(1990, 1, 1, 10, 0, 0), end_time: Time.new(1990, 1, 1, 17, 0, 0), monday: true}
    let!(:divider) { create :divider, price: price, court: court1}

    describe "creation of non-interfering prices" do
      it "will work for non-interfering after" do
        price = create :price, start_time: Time.new(1990, 1, 1, 17, 0, 0), end_time: Time.new(1990, 1, 1, 19, 0, 0), monday: true
        divider = create :divider, price: price, court: court1
        expect(divider.persisted?).to be_truthy
      end

      it "will work for non-interfering before" do
        price = create :price, start_time: Time.new(1990, 1, 1, 7, 0, 0), end_time: Time.new(1990, 1, 1, 10, 0, 0), monday: true
        divider = create :divider, price: price, court: court1
        expect(divider.persisted?).to be_truthy
      end

      it "will work for non-interfering another day" do
        price = create :price, start_time: Time.new(1990, 1, 1, 10, 0, 0), end_time: Time.new(1990, 1, 1, 17, 0, 0), tuesday: true
        divider = create :divider, price: price, court: court1
        expect(divider.persisted?).to be_truthy
      end
    end

    describe "creation of interfering prices" do
      it "will not save for interfering 1" do
        price = create :price, start_time: Time.new(1990, 1, 1, 9, 0, 0), end_time: Time.new(1990, 1, 1, 11, 0, 0), monday: true
        divider = build :divider, price: price, court: court1
        expect(divider.save).to be_falsy
      end

      it "will not save for interfering 2" do
        price = create :price, start_time: Time.new(1990, 1, 1, 11, 0, 0), end_time: Time.new(1990, 1, 1, 16, 0, 0), monday: true
        divider = build :divider, price: price, court: court1
        expect(divider.save).to be_falsy
      end

      it "will not save for interfering 3" do
        price = create :price, start_time: Time.new(1990, 1, 1, 16, 0, 0), end_time: Time.new(1990, 1, 1, 18, 0, 0), monday: true
        divider = build :divider, price: price, court: court1
        expect(divider.save).to be_falsy
      end
    end
  end

  describe "resolving price conflicts" do
    let (:admin) { create :admin }
    let (:company) { create :company }
    let (:venue) { create :venue, company: company }
    let! (:court1) { create :court, venue: venue }
    let! (:court2) { create :court, venue: venue }
    let! (:court3) { create :court, venue: venue }
    let! (:price) { create :price, price: 100, start_minute_of_a_day: 10*60, end_minute_of_a_day: 17*60, monday: true, tuesday: true}
    let! (:price2) { create :price, price: 200, start_minute_of_a_day: 14*60, end_minute_of_a_day: 19*60, monday: true, tuesday: true}
    let! (:price3) { create :price, price: 200, start_minute_of_a_day: 14*60, end_minute_of_a_day: 15*60+30, monday: true, tuesday: true}
    let! (:price4) { create :price, price: 300, start_minute_of_a_day: 14*60, end_minute_of_a_day: 19*60, tuesday: true, wednesday: true}
    let!(:divider) { create :divider, price: price, court: court1}
    let!(:divider2) { create :divider, price: price, court: court2}

    describe "#merge_price" do

      describe "weekdays resolution" do
        before do
          price.merge_price!(price4, court2)
        end
        let(:monday_prices) { court2.prices.where(monday: true) }
        let(:tuesday_prices) { court2.prices.where(tuesday: true) }

        it "creates a price duplicate for just monday" do
          expect(monday_prices.count).to eq(1)
        end

        it "creates and adjusts previous price for tuesday" do
          # one of them is duplicate of original
          # second is our new price
          expect(tuesday_prices.count).to eq(2)
        end

        let(:monday_price) { monday_prices.first }
        describe "monday price duplicate" do
          it "does not have tuesday and wednesday in it" do
            expect(monday_price.tuesday).to be_falsy
            expect(monday_price.wednesday).to be_falsy
          end

          it "has the same start_min and end_min as the original one" do
            expect(monday_price.start_minute_of_a_day).to eq(price.start_minute_of_a_day)
            expect(monday_price.end_minute_of_a_day).to eq(price.end_minute_of_a_day)
          end

          it "has the same price as original" do
            expect(monday_price.price).to eq(price.price)
          end
        end

        let(:original_price_dup) { tuesday_prices.last }
        describe "original price duplicate for tuesday" do
          it "is only for tuesday" do
            expect(original_price_dup.weekdays).to eq([:tuesday])
          end
          it "has the same price as original" do
            expect(original_price_dup.price).to eq(price.price)
          end

          it 'has start time of 10AM' do
            expect(original_price_dup.start_minute_of_a_day).to eq(10 * 60)
          end

          it 'has end time of 2PM' do
            expect(original_price_dup.end_minute_of_a_day).to eq(14 * 60)
          end
        end
      end

      describe 'simple with multiple' do
        before do
          price.merge_price!(price2, court2, court3)
        end

        it 'creates a copy of price1 and attaches price 2' do
          expect(court2.prices.count).to eq(2)
          expect(court3.prices.count).to eq(2)
        end

        it 'detaches price from court2' do
          expect(price.reload.courts.count).to eq(1)
        end
      end

      describe 'simple' do
        before do
          price.merge_price!(price2, court2)
        end

        it 'creates a copy of price1 and attaches price 2' do
          expect(court2.prices.count).to eq(2)
        end

        it 'detaches price from court2' do
          expect(price.reload.courts.count).to eq(1)
        end

        describe 'original price duplicate' do
          let(:dup_price) { Price.last }

          it 'has augmented start and end times' do
            expect(dup_price.price).to eq 100
          end

          it 'sets correct start and end time on dup' do
            expect(dup_price.start_minute_of_a_day).to eq(10 * 60)
            expect(dup_price.end_minute_of_a_day).to eq(14 * 60)
          end
        end
      end

      describe 'middle of interval' do
        before do
          price.merge_price!(price3, court2)
        end

        it 'creates 2 copies of price1 and attaches prices3' do
          expect(court2.prices.count).to eq(3)
        end

        it 'detaches price from court2' do
          expect(price.reload.courts.count).to eq(1)
        end

        let(:dup_prices) { court2.prices.where('price_id != ?', price3) }

        it '2x dup_prices ' do
          expect(dup_prices.count).to eq 2
        end

        describe "original price duplicate 1" do
          let(:dup_price) { dup_prices.first }

          it "has augmented start and end times" do
            expect(dup_price.price).to eq 100
          end

          it "sets correct start and end time on dup" do
            expect(dup_price.start_minute_of_a_day).to eq(10 * 60)
            expect(dup_price.end_minute_of_a_day).to eq(14 * 60)
          end
        end

        describe "original price duplicate 2" do
          let(:dup_price) { dup_prices.last }

          it "has augmented start and end times" do
            expect(dup_price.price).to eq 100
          end

          it "sets correct start and end time on dup" do
            expect(dup_price.start_minute_of_a_day).to eq(15 * 60 + 30)
            expect(dup_price.end_minute_of_a_day).to eq(17 * 60)
          end
        end
      end
    end
  end
end
