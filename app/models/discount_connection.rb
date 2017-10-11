class DiscountConnection < ActiveRecord::Base
  belongs_to :discount
  belongs_to :user
end
