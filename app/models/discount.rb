# Represents a discount that can be offered to customers.
class Discount < ActiveRecord::Base
  has_many :users, through: :discount_connections
  has_many :discount_connections, dependent: :destroy
  belongs_to :venue

  validates :method, presence: { message: 'Discount type cant be blank' }
  validates :name, presence: true
  validates :value,
            presence: true,
            numericality: { only_integer: true,
                            message: 'must be a number' }

  validate :correct_percentage

  enum method: [:percentage, :fixed]

  def correct_percentage
    if percentage? && !(0..100).cover?(value)
      errors.add('Percentage', 'must be between 0 and 100')
    end
  end

  def apply(original_price)
    price = if percentage?
              original_price * (1.0 - value / 100.0)
            else
              [original_price - value, 0].max
            end
    round ? price.round : price
  end
end
