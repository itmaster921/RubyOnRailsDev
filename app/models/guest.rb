# represents a user that does not have an account with
# us only reservations
class Guest < ActiveRecord::Base
  has_many :reservations, as: :user

  validates :full_name, presence: true
end
