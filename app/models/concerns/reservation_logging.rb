module ReservationLogging
  extend ActiveSupport::Concern

  def write_log
    initial_count = logs.count
    if id_changed?
      create_log_entry :created
    end
    if is_paid_changed? && is_paid
      create_log_entry :paid
    end
    if initial_membership_id_changed? && initial_membership_id
      create_log_entry :resold
    end
    if refunded_changed? && refunded
      create_log_entry :refunded
    end
    if inactive_changed? && inactive ||
        initial_membership_id_changed? && !initial_membership_id && !id_changed?
      create_log_entry :cancelled
    end
    if reselling_changed? && reselling
      create_log_entry :reselling
    end

    if initial_count == logs.reload.count
      create_log_entry :updated
    end
  end

  private

  def create_log_entry(status)
    logs.create status: status, params: log_params
  end

  def log_params
    {
      start_time:       TimeSanitizer.output(start_time).to_s,
      end_time:         TimeSanitizer.output(end_time).to_s,
      court_id:         court_id,
      payment_type:     payment_type,
      is_paid:          is_paid,
      charge_id:        charge_id,
      booking_type:     booking_type,
      price:            price,
      amount_paid:      amount_paid,
      reselling:        reselling,
      user_id:          user_id,
      user_name:        user.try(:full_name),
      user_type:        user.class.name,
      initial_membership_id: initial_membership_id
    }
  end
end
