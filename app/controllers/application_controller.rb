class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def after_sign_in_path_for(resource)
    sign_in_url = new_user_session_url
    stored_location_for(resource) ||
      if resource.is_a?(Admin)
        if resource.company && can?(:read, Company)
          resource.company
        elsif !resource.company
          new_company_path
        elsif resource.company.venues.empty?
          new_venue_path
        else
          venue_view_path(resource.company.venues.first)
        end
      else
        if request.referer == sign_in_url
          super
        elsif request.referer.present? && (request.referer.include? "confirmation")
          root_path
        elsif request.referer.present? && (request.referer.include? "reset")
          root_path
        else
          request.env['omniauth.origin'] || stored_location_for(resource) || request.referer || root_path
        end
      end
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin)
  end

  def set_locale
    @en_url = fix_url_locale('en')
    @fi_url = fix_url_locale('fi')
		if params[:locale]
			session[:locale] = params[:locale]
		end
		I18n.locale = session[:locale] || I18n.default_locale
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name << :admin_birth_day << :admin_birth_month << :admin_birth_year << :admin_ssn
    devise_parameter_sanitizer.for(:account_update) << :first_name << :last_name << :phone_number << :email << :password << :password_confirmation << :current_password << :street_address << :zipcode << :city
  end

  def fix_url_locale(locale)
    url = request.original_url
    if url.include? 'locale'
      url.gsub(/locale=../, "locale=#{locale}")
    else
      url + (url.include?('?') ? '&' : '?') + "locale=#{locale}"
    end
  end
end
