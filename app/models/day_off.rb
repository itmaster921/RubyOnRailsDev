# represents a holiday
class DayOff < ActiveRecord::Base
  belongs_to :place, polymorphic: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :place, presence: :true
  validate :dates_valid, if: 'start_time && end_time'

  def dates_valid
    if end_time < start_time
      errors.add(:end_time, 'incorrect date range selected')
    end
  end

  # @OUTPUT
  def jsonify
    {
      id: id,
      start: TimeSanitizer.output(start_time),
      end: TimeSanitizer.output(end_time),
      title: 'Off Time'
    }
  end

  def covers?(start_time, end_time)
    holiday = (self.start_time + 1.second..self.end_time - 1.second)
    reservation = (start_time + 1.second..end_time - 1.second)
    reservation.overlaps?(holiday)
  end
end
