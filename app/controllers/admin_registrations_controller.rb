class AdminRegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    super do |resource|
      resource.level = :god
      resource.save
    end
  end
end
