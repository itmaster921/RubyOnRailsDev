class InvoiceComponent < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :reservation
  delegate :court, to: :reservation, allow_nil: true
  delegate :user, to: :reservation, allow_nil: true
  delegate :court_name, to: :court

  def start_time
    self.reservation.start_time
  end

  def end_time
    self.reservation.end_time
  end

  def bill!
    transaction do
      self.reservation.update_attributes(is_billed: true)
      self.update_attributes(is_billed: true)
    end
  end

  def charged!
    self.update_attributes(is_billed: true, is_paid: true)
  end
end
