class User < ActiveRecord::Base
  include CreditCards
  has_many :reservations, as: :user
  has_many :memberships
  has_many :venue_user_connectors, dependent: :destroy
  has_many :venues, through: :venue_user_connectors
  has_many :companies, through: :venues
  has_many :invoices
  has_many :discounts, through: :discount_connections
  has_many :discount_connections, dependent: :destroy
  has_many :email_list_user_connectors, dependent: :destroy
  has_many :email_lists, through: :email_list_user_connectors
  has_many :game_passes, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true

  after_update :resend_confirmation

  # credit:
  # https://github.com/plataformatec/devise/wiki/How-To:-Find-a-user-when-you-have-their-credentials
  def self.authenticate(email, password)
    user = User.find_for_authentication(email: email)
    (user && user.valid_password?(password)) ? user : nil
  end

  def tz
    # TimeZone[self.timezone] || Time.zone
    Time.zone # TODO: change me to ActiveSupport::TimeZone with actual user timezone in the future
  end

  def outstanding_balance(company=nil)
    return 0.0 if !company.present?
    reservation_balance = company.reservations.where(user:self).where(is_billed: false).where(is_paid: false).sum(:price)
    game_pass_balance = company.game_passes.where(user:self).where(is_billed: false).where(is_paid: false).sum(:price)

    reservation_balance.to_f + game_pass_balance.to_f
  end

  def has_stripe?
    return self.stripe_id != nil
  end

  def has_game_pass?(venue)
    if self.game_passes.where(venue_id:venue.id).present?
      return true
    else
      return false
    end
  end

  def add_stripe_id(token)
    customer = Stripe::Customer.create(
      source: token,
      description: "mywebsite User"
    )
    self.update(stripe_id: customer.id)
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def get_billing_address
    street_address.to_s + ' ' + zipcode.to_s + ' ' + city.to_s
  end

  # return discount or nil
  def discount_for(venue_id)
    @discounts_by_venue ||= discounts.group_by(&:venue_id)
    @discounts_by_venue[venue_id] ? @discounts_by_venue[venue_id].first : nil
  end

  def self.from_omniauth(auth)
    user_by_email = User.where(email: auth.info.email).first

    if user_by_email
      return user_by_email
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.image = auth.info.image
        user.password = Devise.friendly_token[0,20]
      end
    end
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
    errors[:password] << "can't be blank" if password.blank?
    errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def venue_discount(venue)
    discounts.find { |discount| discount.venue == venue }
  end

  def mixpanel_params
    {
      '$email'           => email,
      '$created'         => created_at,
      '$first_name'      => first_name,
      '$last_name'       => last_name,
      'id'               => id,
      'sign_in_count'    => sign_in_count,
      'last_sign_in'     => current_sign_in_at
    }
  end

  def future_reservations
    reservations.non_recurring.future
  end

  def past_reservations
    reservations.non_recurring.past
  end

  def future_memberships
    reservations.recurring.future
  end

  def past_memberships
    reservations.recurring.past
  end

  def reselling_memberships
    reservations.recurring.reselling
  end

  def resold_memberships
    Reservation.where(initial_membership_id: memberships.map(&:id))
  end

  def assign_discount(discount)
    old_discount = discounts.find_by(venue_id: discount.venue_id)
    discounts.delete(old_discount.id) if old_discount
    discounts << discount
  end

  def unconfirmed?
    !confirmed?
  end

  def self.find_or_create_by_id(user_params)
    if user_params[:user_id]
      User.find(user_params[:user_id])
    else
      User.find_or_create_by(email: user_params[:email]) do |user|
        user.assign_attributes(user_params.permit(:first_name, :last_name,
                                                  :email, :phone_number, :city,
                                                  :street_address, :zipcode))
        user.skip_confirmation_notification!
      end
    end
  end

  def self.search(query)
    query = query.to_s.strip
    if query.present?
      query = "%#{query}%"
      full_name = Arel::Nodes::NamedFunction.new(
        'concat',
        [arel_table[:first_name],
        Arel::Nodes.build_quoted(' '),
        arel_table[:last_name]]
      )
      phone = Arel::Nodes::NamedFunction.new(
        "CAST",
        [arel_table[:phone_number].as("TEXT")]
      )
      where(full_name.matches(query)
              .or(arel_table[:email].matches(query))
              .or(phone.matches(query)))
    else
      all
    end
  end

  def resend_confirmation
    if email_changed? && unconfirmed? && !encrypted_password.present?
      ConfirmationMailer.confirmation_instructions(
        self,
        self.confirmation_token,
        {},
        self.venues.first
      ).deliver_later
    end
  end
end
