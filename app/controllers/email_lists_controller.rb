# email related actions
class EmailListsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_venue, only: [:index, :show, :create, :search, :custom_mail]

  def index
    @email_lists = @venue.email_lists
    respond_to do |format|
      format.html { render partial: "email_lists/index" }
      format.json { render json: @email_lists.as_json }
    end
  end

  def show
    @email_list = EmailList.includes(:users).find(params[:id])
    render partial: "email_lists/email_list"
  end

  def create
    @email_list = @venue.email_lists.new(email_list_params)
    if @email_list.save
      render json: {
        email_list: @email_list,
        message: "Email list '#{@email_list.name}' List created."
      }
    else
      render json: { errors: @email_list.errors.full_messages },
        status: 422
    end
  end

  def update
    @email_list = EmailList.find(params[:id])
    if @email_list.update_attributes(email_list_params)
      render json: {
        email_list: @email_list,
        message: t('.success')
      }
    else
      render json: { errors: @email_list.errors.full_messages },
        status: 422
    end
  end

  def remove_users
    @email_list = EmailList.find(params[:email_list_id])
    @email_list.users.delete(*params[:users])
    render json: {'message': t('.success')}
  end

  # List of venue users not in the email list
  def off_list_users
    @email_list = EmailList.find(params[:email_list_id])
    render json: @email_list.off_list_users
  end

  def add_users
    @email_list = EmailList.find(params[:email_list_id])
    @email_list.add_users(params[:users])
    render json: { 'message': t('.success') }
  end

  def destroy
    @email_list = EmailList.find(params[:id])
    render json: {
      'email_list': @email_list.destroy,
      'message': t('.success')
    }
  end

  def custom_mail
    mail_params = custom_mail_params
    # TODO move fetching emails to the background job as well
    email_lists = mail_params[:to_groups]
    mail_params[:to] = EmailList.get_user_emails(email_lists)
    mail_params[:to].concat(mail_params[:to_users]).uniq
    if mail_params[:to].blank?
      respond_to do |format|
        format.js do
          render json: {errors: t('.no_recipient')},
            status: 422
        end
      end
    else
      CustomMailWorker.perform_async(mail_params, @venue.id)
      send_copy_custom_mail(mail_params, @venue.id) if mail_params[:send_copy]
      respond_to do |format|
        format.js { render json: {message: t('.success')} }
      end
    end
  end

  private

  # send copy (sample) mail to current_admin
  def send_copy_custom_mail(mail_params, venue_id)
    mail_params[:to] = current_admin.email
    mail_params[:subject] += ' <Copy>'
    CustomMailer.custom_mail(mail_params, venue_id).deliver_later
  end

  def email_list_params
    params.require(:email_list).permit(:name)
  end

  # TODO use a separate custom_mail model for validation
  def custom_mail_params
    params[:custom_mail] = JSON.parse(params[:custom_mail])
    mail_params = params.require(:custom_mail).permit(:body, :subject, :from, :send_copy, :to_users, :to_groups => [])
    mail_params[:to_users] = mail_params[:to_users].split(',').map(&:strip)
    mail_params[:header_image_path] = params[:header_image].try(:path)
    mail_params
  end

  def set_venue
    @venue = Venue.find(params[:venue_id])
  end
end
