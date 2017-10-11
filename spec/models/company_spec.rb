require 'rails_helper'

describe Company do
  context 'outstanding balance' do
    let!(:admin) { create(:admin, :with_company) }
    let!(:company) { admin.company }
    let!(:venue) { create :venue, :with_courts, company: company }
    let!(:court1) { venue.courts.first }
    let!(:court2) { venue.courts.last }
    let!(:user1) { create :user }
    let!(:user2) { create :user }
    let(:start_time) { Time.current.advance(weeks: 2).beginning_of_week.at_noon }

    before do
      create :reservation, user: user1, price: 11.0, court: court1, start_time: start_time
      create :reservation, user: user1, price: 3.0,  court: court1, start_time: start_time + 1.days
      create :reservation, user: user1, price: 7.0,  court: court2, start_time: start_time + 1.days,
                                        is_paid: true, payment_type: :paid, is_billed: true
      create :reservation, user: user1, price: 9.0,  court: court2, start_time: start_time + 2.days,
                                        amount_paid: 4, payment_type: :semi_paid
      create :reservation, user: user1, price: 0.0,  court: court2, start_time: start_time + 4.days,
                                        amount_paid: 10, payment_type: :semi_paid
      create :reservation, user: user1, price: 1.0,  court: court2, start_time: start_time + 3.days

      create :reservation, user: user2, price: 0.0, court: court1, start_time: start_time + 2.days,
                                        amount_paid: 17, payment_type: :semi_paid
    end

    describe '#user_outstanding_balance' do
      it 'should calculate right outstanding balance for user' do
        outstanding_balance = company.user_reservations(user1).map(&:outstanding_balance).sum
        outstanding_balance += company.game_passes.where(user: user1).invoicable.map(&:price).sum

        expect(company.user_outstanding_balance(user1)).to eq outstanding_balance
        expect(company.user_outstanding_balance(user1)).to eq (11 + 3 + 0 + 5 + 0 + 1).to_f
      end

      it 'should calculate right outstanding balance for other user' do
        outstanding_balance = company.user_reservations(user2).map(&:outstanding_balance).sum
        outstanding_balance += company.game_passes.where(user: user2).invoicable.map(&:price).sum

        expect(company.user_outstanding_balance(user2)).to eq outstanding_balance
        expect(company.user_outstanding_balance(user2)).to eq (0.0)
      end
    end

    describe '#outstanding_balances' do
      it 'should calculate right outstanding balance for all users' do
        outstanding_balances = company.outstanding_balances

        expect(outstanding_balances[user1.id]).to eq company.user_outstanding_balance(user1)
        expect(outstanding_balances[user2.id]).to eq company.user_outstanding_balance(user2)
      end
    end
  end

  context 'lifetime(paid) balance' do
    let!(:admin) { create(:admin, :with_company) }
    let!(:company) { admin.company }
    let!(:venue) { create :venue, :with_courts, company: company }
    let!(:court1) { venue.courts.first }
    let!(:court2) { venue.courts.last }
    let!(:user1) { create :user }
    let!(:user2) { create :user }
    let(:start_time) { Time.current.advance(weeks: 2).beginning_of_week.at_noon }

    before do
      create :reservation, user: user1, price: 11.0, court: court1, start_time: start_time
      create :reservation, user: user1, price: 3.0,  court: court1, start_time: start_time + 1.days
      create :reservation, user: user1, price: 7.0,  court: court2, start_time: start_time + 1.days,
                                        amount_paid: 7.0, is_paid: true, payment_type: :paid, is_billed: true
      create :reservation, user: user1, price: 9.0,  court: court2, start_time: start_time + 2.days,
                                        amount_paid: 4.0, payment_type: :semi_paid
      create :reservation, user: user1, price: 0.0,  court: court2, start_time: start_time + 4.days,
                                        amount_paid: 10.0, payment_type: :semi_paid
      create :reservation, user: user1, price: 1.0,  court: court2, start_time: start_time + 3.days

      create :reservation, user: user2, price: 0.0, court: court1, start_time: start_time + 2.days,
                                        amount_paid: 17.0, payment_type: :semi_paid
    end

    describe '#user_lifetime_balance' do
      it 'should calculate right lifetime balance for user' do
        lifetime_balance = company.user_reservations(user1).map(&:price).sum
        lifetime_balance += company.game_passes.where(user: user1).map(&:price).sum

        expect(company.user_lifetime_balance(user1)).to eq lifetime_balance
        expect(company.user_lifetime_balance(user1)).to eq (11 + 3 + 7 + 9 + 0 + 1).to_f
      end

      it 'should calculate right lifetime balance for other user' do
        lifetime_balance = company.user_reservations(user2).map(&:price).sum
        lifetime_balance += company.game_passes.where(user: user2).map(&:price).sum

        expect(company.user_lifetime_balance(user2)).to eq lifetime_balance
        expect(company.user_lifetime_balance(user2)).to eq 0.0
      end
    end

    describe '#lifetime_balances' do
      it 'should calculate right lifetime balance for all users' do
        lifetime_balances = company.lifetime_balances

        expect(lifetime_balances[user1.id]).to eq company.user_lifetime_balance(user1)
        expect(lifetime_balances[user2.id]).to eq company.user_lifetime_balance(user2)
      end
    end
  end
end
