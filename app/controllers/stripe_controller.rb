class StripeController < ApplicationController
  def managed
    current_company = current_admin.company
    connector = StripeManaged.new( current_company )
    account = connector.create_account!(current_company,
                                          current_admin,
                                          params[:tos] == 'on',
                                          request.remote_ip)
    if account
      flash[:notice] = "Managed Stripe account created! <a target='_blank' rel='platform-account' href='https://dashboard.stripe.com/test/applications/users/#{account.id}'>View in dashboard &raquo;</a>"
    else
      flash[:error] = "Unable to create Stripe account!"
    end
    redirect_to company_path( current_company )
  end

  def add_card
    token = params[:stripeToken]
    user = User.find(params[:user_id])
    if user.has_stripe?
      user.add_card(token)
    else
      user.add_stripe_id(token)
    end

    tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
    tracker.track(
      user.id,
      "Credit Card added by User",
       {
        time_from_signup: (Time.now - Time.parse(user.created_at.to_s)).round,
      }
    )

    render partial: 'users/credit_cards',
           status: :ok,
           locals: { cards: user.cards }
  end
end
