# Handles checking venue listing rules
module Listable
  def listable?
    errors.add('List', I18n.t('errors.venue.list.court_empty')) unless courts.count > 0
    errors.add('List', I18n.t('errors.venue.list.phots_empty')) unless photos.count > 0
    errors.add('List', I18n.t('errors.venue.list.days_empty')) unless business_hours_ready?
    pricing_ready?
  end

  private

  def pricing_ready?
    courts.each do |c|
      court_errors = c.pricing_ready?
      court_errors.keys.each do |day|
        day_errors(c, day, court_errors[day])
      end
    end
  end

  def day_errors(c, day, day_errors)
    day_string = I18n.t("errors.venue.list.#{day}")
    day_errors.each do |error|
      errors.add("#{c.court_name} #{day_string}",
                 error)
    end
  end
end
