# User methods for handling credit cards
module CreditCards
  extend ActiveSupport::Concern
  def cards
    Stripe::Customer.retrieve(stripe_id).sources if stripe_id
  end

  def add_card(token)
    customer = Stripe::Customer.retrieve(stripe_id)
    customer.sources.create(source: token)
  end

  def default_card
    Stripe::Customer.retrieve(stripe_id).default_source if stripe_id
  end
end
