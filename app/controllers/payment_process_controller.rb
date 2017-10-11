class PaymentProcessController < ApplicationController
	before_filter :require_user

	include Wicked::Wizard
	steps :select_submission, :input_card_info

	def show
		@order = current_order unless current_order.nil?
		@submissions = Submission.whole_submissions
		case step
		when :select_submission
			@order = current_user.orders.build if current_order.nil?
			@order.save
			@order.order_submissions.build			
			session[:order_id] = @order.id
		when :input_card_info	
			@order ||= current_order
			@order.build_payment if @order.payment.nil?
		end
		render_wizard
	end

	def update
		@order ||= current_order		
		case step
		when :select_submission
			@order.attributes = params[:order]
		when :input_card_info
#			render :text => params.inspect and return

			amount = params[:order][:balance_amount]
			amount_in_cents = amount.to_f*100
			credit_card = ActiveMerchant::Billing::CreditCard.new(
				:number								=>params[:card_number],
				:verification_value		=>params[:cvv_number],
				:month								=>params[:exp_month],
				:year									=>params[:exp_year],
				:first_name						=>params[:order][:shipping_first_name],
				:last_name						=>params[:order][:shipping_last_name]
			)
			if credit_card.valid?
				#gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
				#	:login => ENV['AUTHORIZE_LOGIN_ID'],
				#	:password => ENV['AUTHORIZE_TRANSACTION_KEY'],
				#	:test=>true
				#)
				purchase_options=
				{
	        :ip => request.remote_ip,
	        :billing_address => {	         
	        	:company	=> current_user.company_name,
	          :address1 => params[:order][:shipping_address],
	          :city     => params[:order][:shipping_city],
	          :state    => params[:order][:shipping_state],
	          :country  => params[:order][:shipping_country],
	          :zip      => params[:order][:shipping_zip_code]
	        }
	      }
    
				#response = GATEWAY.authorize(amount_in_cents, credit_card)
				response = GATEWAY.purchase(amount_in_cents, credit_card, purchase_options)
				if response.success?
					@order.token_key = response.params["transaction_id"]
					@order.payment_option = 'card'
					@order.attributes = params[:order]
					if @order.save
						@order.complete(params[:cvv_number])						
						flash[:alert] = 'Thnk you for your submission. You will receive a payment confirmation email shortly.'
					end
				else
					raise StandardError, response.message
				end

			else
				flash[:notice] = credit_card.errors.full_messages.join('. ')
				redirect_to :back and return
			end
			redirect_to root_url and return
		end	
		
		render_wizard @order
	end
	private
		def redirect_to_finish_wizard
			redirect_to root_url, notice: "Tanks you for pay transaction"
		end
end
