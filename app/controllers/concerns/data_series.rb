module DataSeries
  extend ActiveSupport::Concern

  def self.make_trans_series(data, grouping)
    data = map_trans_series(data)
    data = case
           when grouping == "day"
             data.group_by_minute {|d| d[:date]}
           when grouping == "month"
             data.group_by_day {|d| d[:date]}
           when grouping == "year"
             data.group_by_month { |d| d[:date] }
           end
    data = group_trans_series(data)
  end

  def self.make_resv_series(data, grouping)
    data = case
           when grouping == "day"
             data.group_by_minute {|d| Time.at(d[:created])}
           when grouping == "month"
             data.group_by_day {|d| Time.at(d.created)}
           when grouping == "year"
             data.group_by_month { |d| Time.at(d.created) }
           end
    data = group_resv_series(data)
  end

  private

  def self.map_trans_series(data)
    data = data.map do |trans|
      {
        value: trans.amount,
        date: Time.at(trans.created)
      }
    end
  end

  def self.group_trans_series(data)
    data.map do |date, values|
      value = 0
      values.each { |v| value += v[:value] }
        [
          date.to_i * 1000,
          value / 100
        ]
    end
  end

  def self.group_resv_series(data)
    data.map do |date, values|
        [
          date.to_i * 1000,
          values.count
        ]
    end
  end

end
