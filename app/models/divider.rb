class Divider < ActiveRecord::Base
  belongs_to :price
  belongs_to :court

  validate :check_interval_collision

  def conflict_prices
    return @conflict_prices if @conflict_prices

    map = []
    Price::WEEKDAYS.each do |day|
      map << "prices.#{day.to_s} = true" if price.send(day)
    end
    day_query = map.join(" OR ")

    @conflict_prices = Price.
      where(day_query).
      joins(:dividers).
      where(dividers: {court_id: self.court_id}).
      where("prices.id != ?", self.price_id).
      where(
       "NOT ((? < prices.start_minute_of_a_day AND ? <= prices.start_minute_of_a_day) \
       OR (? >= prices.end_minute_of_a_day AND ? > prices.end_minute_of_a_day))",
       self.price.start_minute_of_a_day, self.price.end_minute_of_a_day,
       self.price.start_minute_of_a_day, self.price.end_minute_of_a_day
      )
  end

  protected

  def check_interval_collision
    if conflict_prices.count != 0
      errors[:base] << "Conflict with prices: #{conflict_prices.map(&:id).join(", ")}"
    end
  end
end
