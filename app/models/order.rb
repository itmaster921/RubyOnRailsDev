# == Schema Information
#
# Table name: orders
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  balance_amount             :string
#  payment_option             :string
#  shipping_first_name        :string
#  shipping_last_name         :string
#  shipping_address           :string
#  shipping_optional_address  :string
#  shipping_city              :string
#  shipping_state             :string
#  shipping_zip_code          :string
#  shipping_country           :string
#  shipping_method            :string
#  email                      :string
#  token_key                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null

class Order < ActiveRecord::Base
  belongs_to :user 
  attr_accessible :balance_amount, :email, :token_key, :payment_option, :shipping_address, :shipping_city, 
                  :shipping_country, :shipping_first_name, :shipping_last_name, :shipping_method, 
                  :shipping_optional_address, :shipping_state, :shipping_zip_code, 
                  :order_submissions_attributes, :payment_attributes

  has_many :order_submissions,    :dependent => :destroy
  has_many :submissions, :through => :order_submissions
  has_one :payment,               :dependent => :destroy

  accepts_nested_attributes_for :order_submissions, :allow_destroy=>true, :reject_if => proc{ |a| a['submission_id'] == '-1' }
  accepts_nested_attributes_for :payment, :allow_destroy=>true, :reject_if => :all_blank
  
  
  def complete(cvv_number)
    payment_transaction = self.build_payment
    payment_transaction.user_id = self.user_id
    payment_transaction.ccard_last4 = cvv_number
    payment_transaction.first_name = self.shipping_first_name
    payment_transaction.last_name = self.shipping_last_name
    payment_transaction.price_subtotal = self.balance_amount    
    payment_transaction.street_address = self.shipping_address
    payment_transaction.status = self.shipping_state
    payment_transaction.city = self.shipping_city    
    payment_transaction.region = self.shipping_zip_code 
    payment_transaction.country = self.shipping_country
    payment_transaction.transaction_id = self.token_key
    payment_transaction.save
    self.submissions.each do |submission|
      submission.status = Submission::STATUS_KINDS[:complete]
      submission.save
    end
  end

  def purchase
    response = GATEWAY.purchase(price_in_cents, credit_card, purchase_options)
    transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
    cart.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end
  
  def price_in_cents
    (cart.total_price*100).round
  end

  private  
    def purchase_options
      {
        :ip => ip_address,
        :billing_address => {
          :name     => "Ryan Bates",
          :address1 => "123 Main St.",
          :city     => "New York",
          :state    => "NY",
          :country  => "US",
          :zip      => "10001"
        }
      }
    end
    
    def validate_card
      unless credit_card.valid?
        credit_card.errors.full_messages.each do |message|
          errors.add_to_base message
        end
      end
    end
    
    def credit_card
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
        :type               => card_type,
        :number             => card_number,
        :verification_value => card_verification,
        :month              => card_expires_on.month,
        :year               => card_expires_on.year,
        :first_name         => first_name,
        :last_name          => last_name
      )
    end
end
