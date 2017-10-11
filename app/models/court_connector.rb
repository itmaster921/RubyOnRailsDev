class CourtConnector < ActiveRecord::Base
  belongs_to :court
  belongs_to :shared_court, class_name: 'Court'

  validates_uniqueness_of :shared_court_id, scope: [:court_id]
  validate :no_self_sharing

  after_create :create_reciprocal_association
  after_destroy :destroy_reciprocal_association

  def no_self_sharing
    if court_id == shared_court_id
      errors.add(:shared_court, "Sharing with same court not allowed")
    end
  end

  def create_reciprocal_association
    CourtConnector.create(court: shared_court, shared_court: court)
  end

  def destroy_reciprocal_association
    CourtConnector.delete_all(court_id: shared_court_id, shared_court_id: court_id)
  end

  # Deletes all court sharing for a court.
  # Have to use this method since court.shared_courts = [] won't
  # invoke after_destroy callback
  def self.remove_connectors_for_court(court_id)
    table = arel_table

    where(
      table[:court_id].eq(court_id)
      .or(table[:shared_court_id].eq(court_id))
    ).delete_all
    # where('court_id=? OR shared_court_id=?', court_id, court_id).delete_all
  end
end
