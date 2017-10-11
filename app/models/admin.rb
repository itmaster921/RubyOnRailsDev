# Represents company admins
class Admin < ActiveRecord::Base
  include Passport
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :password, confirmation: true

  belongs_to :company

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :admin_ssn, hetu: true, if: 'god?'
  validates :email, presence: true
  validate :one_god, if: 'god? && !company.nil?'

  after_save :make_god, unless: 'company.nil? || god?'

  enum level: [:guest, :cashier, :manager, :god]

  LEVEL_HUMANIZED = {
    'god' => 'Super Admin',
    'manager' => 'Manager',
    'cashier' => 'Employee',
    'guest' => 'N/A'
  }.freeze

  before_save { self.level ||= :god }

  def full_name
    "#{first_name} #{last_name}"
  end

  def level_to_s
    LEVEL_HUMANIZED[level]
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
    errors[:password] << 'can\'t be blank' if password.blank?
    errors[:password_confirmation] << 'can\'t be blank' if password_confirmation.blank?
    errors[:password_confirmation] << 'does not match password' if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def role?(level)
    self.level == level
  end

  # A hack to overcome open() aversion to certain file names
  def randomize_file_name
    extension = File.extname(passport_file_name).downcase
    passport.instance_write(:file_name, "deep-space#{extension}")
  end

  def one_god
    if company.admins.select(&:god?).count > 1
      errors.add('Company', ' can only have one and only one super admin')
    end
  end

  def make_god
    update(level: :god) if company.admins.count == 1
  end
end
