class MembershipConnector < ActiveRecord::Base
  belongs_to :membership
  belongs_to :reservation
end
