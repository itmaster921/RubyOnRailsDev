# == Schema Information
#
# Table name: payments
#
#  id           		:integer					not null,  primary key, auto_increment
#  user_id  				:integer
#  order_id					:integer
#  transaction_id  	:string
#  refund_id			 	:string
#  price_subtotal		:string
#  price_tax       	:string
#  price_refund			:string
#  price_total 			:string
#  ccard_last4 			:string
#  status				  	:string
#  first_name				:string
#  last_name				:string
#  street_address		:string
#  city           	:string
#  region          	:string	
#  post_code            	:string
#  country        	:string
#  created_at 			:datetime         not null
#  updated_at 			:datetime         not null

class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  attr_accessible :ccard_last4, :city, :country, :first_name, :last_name, :post_code, :price_refund, 
  								:price_subtotal, :price_tax, :price_total, :refund_id, :region, :status, :street_address, 
  								:transaction_id

end
