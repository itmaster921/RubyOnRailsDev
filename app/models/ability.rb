# Define admin level abilites
class Ability
  include CanCan::Ability

  def initialize(admin)
    admin ||= Admin.new

    case admin.level
    when 'god' then god_permissions
    when 'manager' then manager_permissions
    when 'cashier' then cashier_permissions
    when 'guest' then guest_permissions
    end
  end

  private

  def god_permissions
    can :manage, :all
  end

  def manager_permissions
    can :manage, :all
    cannot :manage, Admin
    cannot [:read, :create, :update, :destory], Company
  end

  def cashier_permissions
    can [:customers, :invoices, :reports], Company
    can :manage_discounts, Venue
    can :read, :all
    cannot :read, Company
    can :manage, Reservation
  end

  def guest_permissions
    cannot :manage, :all
  end
end
