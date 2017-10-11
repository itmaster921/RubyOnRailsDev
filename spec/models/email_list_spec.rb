require 'rails_helper'

describe EmailList do

  context "associations" do
    it "should belong to a venue" do
      expect(EmailList.reflect_on_association(:venue).macro).to eq(:belongs_to)
    end

    it "should have many users" do
      expect(EmailList.reflect_on_association(:users).macro).to eq(:has_many)
    end
  end

  context "field validations" do
    let!(:email_list) { FactoryGirl.build(:email_list, :with_venue) }
    let!(:venue){ email_list.venue }

    describe "#name" do
      context "validate presence" do
        it "should add error when absent" do
          email_list.name = ""
          expect(email_list.valid?).to be_falsy
          expect(email_list.errors).to include(:name)
        end

        it "should be valid when present" do
          expect(email_list.valid?).to be_truthy
          expect(email_list.errors).not_to include(:name)
        end
      end

      context "uniqueness" do
        let!(:email_list_2) { FactoryGirl.create(:email_list, :with_venue, venue: venue) }

        it "should add error when duplicate name" do
          email_list.name = email_list_2.name
          expect(email_list.valid?).to be_falsy
          expect(email_list.errors).to include(:name)
        end
      end
    end

    describe "#users" do
      let!(:user) {FactoryGirl.create(:user) }
      context "unique users?" do
        it "shouldn't allow duplicate users" do
          email_list.users << [user] * 2
          expect(email_list.valid?).to be_falsy
          expect(email_list.errors).to include(:users)
        end
      end
    end
  end

  describe "#add_users" do
    let!(:email_list) { FactoryGirl.create(:email_list, :with_users) }
    let!(:user_list) { FactoryGirl.create_list(:user, 3) }

    it "should add new users" do
      user_ids = user_list.map(&:id)
      original_user_count = email_list.users.count
      email_list.add_users(user_ids)

      expect(email_list.users.count).to eq(original_user_count + user_list.count)
    end

    it "should not add duplicate users" do
      user_ids = user_list.map(&:id)
      user_ids.push(email_list.users.first.id)
      user_ids.push(user_list.first.id)
      original_user_count = email_list.users.count
      email_list.add_users(user_ids)

      expect(email_list.users.count).to eq(original_user_count + user_list.count)
    end
  end

  describe "#off_list_users" do
    let!(:email_list) { FactoryGirl.create(:email_list, :with_users, :with_venue) }
    let!(:venue) { email_list.venue }
    let!(:user_list) {
      users = FactoryGirl.create_list(:user, 5, :with_venues, venues: [venue])
      venue.reload
      users
    }

    it "should return users of the venue not in the email list" do
      count = user_list.count
      result = email_list.off_list_users
      expect(result.count).to eq(count)
    end
  end

  describe "#get_user_emails" do
    let!(:user_count) { 2 }
    let!(:email_list_array) { FactoryGirl.create_list(:email_list, 5, :with_users, user_count: user_count) }

    it "should return users array" do
      result = EmailList.get_user_emails(email_list_array.map(&:id))
      expect(result.count).to eq(email_list_array.count * user_count)
      expect(result).to eq(User.all.pluck(:email))
    end
  end
end
