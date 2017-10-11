class EmailListUserConnector < ActiveRecord::Base
  belongs_to :user
  belongs_to :email_list

  validates :user, :uniqueness => { :scope => :email_list }
end
