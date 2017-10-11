class StripeManaged < Struct.new( :user )

  ALLOWED = [ 'US', 'FI' ]
  COUNTRIES = [
    { name: 'United States', code: 'US' },
    { name: 'Finland', code: 'FI' },
  ]
  def create_account!(company, admin, tos_accepted, ip)
    return nil unless tos_accepted
    country_code, currency = country_info(company.company_country)

    @account = Stripe::Account.create(
      stripe_account_info(company, country_code, currency, ip, admin)
    )
    update_company_account(@account) if @account
    @account
  end

  def update_account!( params: nil )
    if params
      if params[:bank_account_token]
        account.bank_account = params[:bank_account_token]
        account.save
      end

      if params[:legal_entity]
        # clean up dob fields
        params[:legal_entity][:dob] = {
          year: params[:legal_entity].delete('dob(1i)'),
          month: params[:legal_entity].delete('dob(2i)'),
          day: params[:legal_entity].delete('dob(3i)')
        }

        # update legal_entity hash from the params
        params[:legal_entity].entries.each do |key, value|
          if [ :address, :dob ].include? key.to_sym
            value.entries.each do |akey, avalue|
              next if avalue.blank?
              # Rails.logger.error "#{akey} - #{avalue.inspect}"
              account.legal_entity[key] ||= {}
              account.legal_entity[key][akey] = avalue
            end
          else
            next if value.blank?
            # Rails.logger.error "#{key} - #{value.inspect}"
            account.legal_entity[key] = value
          end
        end

        # copy 'address' as 'personal_address'
        pa = account.legal_entity['address'].dup.to_h
        account.legal_entity['personal_address'] = pa

        account.save
      end
    end

    user.update_attributes(
      stripe_account_status: account_status
    )
  end

  def legal_entity
    account.legal_entity
  end

  def needs?( field )
    user.stripe_account_status['fields_needed'].grep( Regexp.new( /#{field}/i ) ).any?
  end

  def supported_bank_account_countries
    country_codes = case account.country
                    when 'US' then %w{ US }
                    when 'FI' then %w{ FI }
                    end
    COUNTRIES.select do |country|
      country[:code].in? country_codes
    end
  end

  protected

  def account_status
    {
      details_submitted: account.details_submitted,
      charges_enabled: account.charges_enabled,
      transfers_enabled: account.transfers_enabled,
      fields_needed: account.verification.fields_needed,
      due_by: account.verification.due_by
    }
  end

  def account
    @account ||= Stripe::Account.retrieve(user.stripe_user_id)
  end

  def country_info(country)
    case country
    when 'Finland'
      %w(FI eur)
    when 'United States', 'USA'
      %w(USA eur)
    end
  end

  def stripe_account_info(company, country_code, currency, ip, admin)
    {
      managed: true,
      country: country_code,
      business_name: company.company_legal_name,
      business_url: company.company_website,
      external_account: {
        object: 'bank_account',
        account_number: company.company_iban,
        country: country_code,
        currency: currency,
        account_holder_name: company.company_legal_name,
        account_holder_type: 'company'
      },
      legal_entity: {
        additional_owners: nil,
        dob: {
          day: admin.admin_birth_day,
          month: admin.admin_birth_month,
          year: admin.admin_birth_year
        },
        first_name: admin.first_name,
        last_name: admin.last_name,
        personal_address: {
          city: company.company_city,
          postal_code: company.company_zip,
          line1: company.company_street_address
        },
        address: {
          city: company.company_city,
          country: country_code,
          line1: company.company_street_address,
          postal_code: company.company_zip
        },
        business_name: company.company_legal_name,
        business_vat_id: company.company_tax_id,
        business_tax_id: company.company_tax_id,
        phone_number: company.company_phone,
        type: 'company'
      },
      tos_acceptance: {
        ip: ip,
        date: Time.now.to_i
      }
    }
  end

  def update_company_account(stripe_account)
    user.update_attributes(
      currency: stripe_account.default_currency,
      stripe_account_type: 'managed',
      stripe_user_id: stripe_account.id,
      secret_key: stripe_account.keys.secret,
      publishable_key: stripe_account.keys.publishable,
      stripe_account_status: account_status
    )
  end
end
