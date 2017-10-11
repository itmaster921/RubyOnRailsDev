# Handles checking courts pricing for conflicts
module Conflicts
  extend ActiveSupport::Concern

  def update_or_find_conflicts(price_params, court_ids)
    assign_attributes(price_params)
    return commmit_update([]) if court_ids.empty?
    courts = Court.find(court_ids)
    divs = courts.map { |c| Divider.new(price: self, court: c) }
    conflicts = collect_conflicts(divs)
    if conflicts.empty?
      commit_update(divs)
    else
      [nil, conflicts]
    end
  end

  private

  def commit_update(divs)
    Price.transaction do
      dividers.destroy_all
      save!
      divs.each(&:save!)
    end
    [nil, nil]
  rescue
    [errors.full_messages, nil]
  end

  def collect_conflicts(divs)
    divs.reject(&:valid?).map(&:conflict_prices).flatten.uniq
  end
end
