namespace :db do
  desc 'Convert resell initial_owner to initial_membership.'
  task convert_resell_initial_owner: :environment do
    all_resold = Reservation.where.not(initial_membership_id: nil).includes(:membership)
    User.transaction do |variable|
      all_resold.find_each do |r|
        r.initial_membership_id = r.membership.id
        r.membership = nil
        r.save
      end
    end
  end
end
