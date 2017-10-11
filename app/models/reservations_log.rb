class ReservationsLog < ActiveRecord::Base
  belongs_to :reservation

  enum status: [:created, :updated, :paid, :refunded, :cancelled, :reselling, :resold]
  store :params, coder: Hash
end
