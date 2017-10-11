# == Schema Information
#
# Table name: order_submissions
#
#  id         								:integer          not null, primary key
#  order_id										:integer
#  submission_id							:integer
#  created_at 								:datetime         not null
#  updated_at 								:datetime         not null

class OrderSubmission < ActiveRecord::Base
  belongs_to :order
  belongs_to :submission
  attr_accessible :submission_id, :order_id
end
