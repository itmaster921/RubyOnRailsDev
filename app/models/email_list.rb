# Represents a mailing group of users
class EmailList < ActiveRecord::Base
  belongs_to :venue
  has_many :email_list_user_connectors, dependent: :destroy
  has_many :users, through: :email_list_user_connectors

  validates :name, presence: true, uniqueness: { scope: :venue }
  validate :unique_users?

  def add_users(user_ids)
    new_users = User.where(id: user_ids)
    new_users = new_users - users
    users.append(new_users)
  end

  # returns list of venue users on included in the email list
  def off_list_users
    off_list_users = venue.users - users
    off_list_users.uniq!
    off_list_users.map do |user|
      user.as_json(only: [:id, :first_name, :last_name, :email])
    end
  end

  # return user emails for provided email_list_ids array
  def self.get_user_emails(email_list_ids)
    user_ids = EmailListUserConnector.where(email_list_id: email_list_ids).pluck(:user_id).uniq
    emails = User.where(id: user_ids).pluck(:email)
  end

  private
  def unique_users?
    if users.length != users.uniq.length
      errors.add(:users, "duplicate users not allowed")
    end
  end
end
