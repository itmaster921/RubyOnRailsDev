require 'rails_helper'

RSpec.describe User, type: :model do
  it "works" do
    user = FactoryGirl.create(:user)
    expect(user).to be_valid
  end

  it "creates a stipe user id" do
    user = FactoryGirl.create(:user)
    token = Stripe::Token.create( card: { number: "4242424242424242",
                                  exp_month: 1,
                                  exp_year: 2017,
                                  cvc: 314 } )
    user.add_stripe_id(token.id)
    expect(user.has_stripe?).to eq(true)
  end

  context 'reservations queries' do
    let!(:membership) { create :membership, :with_user, :with_venue }
    let!(:user1) { membership.user }
    let!(:user2) { create(:user) }
    let!(:court1) { membership.venue.courts.first }
    let!(:court2) { membership.venue.courts.last }
    let!(:time) { membership.start_time.advance(weeks: 3).at_noon }
    let!(:past_time) { membership.start_time.advance(weeks: -1).at_noon }
    let!(:future_reservation1) { create :reservation, user: user1, court: court1, start_time: time }
    let!(:future_reservation2) { create :reservation, user: user2, court: court2, start_time: time }
    let!(:past_reservation1) { create :novalidate_reservation, user: user1, court: court1, start_time: past_time }
    let!(:past_reservation2) { create :novalidate_reservation, user: user2, court: court2, start_time: past_time }
    let!(:future_membership) { create :reservation, user: user1, court: court1, start_time: time + 1.days, booking_type: :membership, membership: membership }
    let!(:past_membership) { create :novalidate_reservation, user: user1, court: court2, start_time: past_time - 1.days, booking_type: :membership, membership: membership }
    let!(:future_reselling) { create :reservation, user: user1, court: court1, reselling: true, start_time: time + 2.days, booking_type: :membership, membership: membership }
    let!(:past_reselling) { create :novalidate_reservation, user: user1, court: court2, reselling: true, start_time: past_time - 2.days, booking_type: :membership, membership: membership }
    let!(:future_resold) { create :reservation, user: user2, court: court1, initial_membership_id: membership.id, start_time: time + 3.days }
    let!(:past_resold) { create :novalidate_reservation, user: user2, court: court2, initial_membership_id: membership.id, start_time: past_time - 3.days }

    describe '#future_reservations' do
      it 'should return only future non recurring reservations owned by this user' do
        expect(user1.future_reservations.to_a).to eq [future_reservation1]
      end
    end

    describe '#past_reservations' do
      it 'should return only past non recurring reservations owned by this user' do
        expect(user1.past_reservations.to_a).to eq [past_reservation1]
      end
    end

    describe '#future_memberships' do
      it 'should return only future recurring reservations owned by this user' do
        expect(user1.future_memberships.to_a.sort_by(&:id)).to eq [future_membership, future_reselling].sort_by(&:id)
      end
    end

    describe '#past_memberships' do
      it 'should return only past recurring reservations owned by this user' do
        expect(user1.past_memberships.to_a.sort_by(&:id)).to eq [past_membership, past_reselling].sort_by(&:id)
      end
    end

    describe '#reselling_memberships' do
      it 'should return only reselling recurring reservations owned by this user' do
        expect(user1.reselling_memberships.to_a.sort_by(&:id)).to eq [future_reselling, past_reselling].sort_by(&:id)
      end
    end

    describe '#resold_memberships' do
      it 'should return only resold recurring reservations initially owned by this user' do
        expect(user1.resold_memberships.to_a.sort_by(&:id)).to eq [future_resold, past_resold].sort_by(&:id)
      end
    end
  end
end
