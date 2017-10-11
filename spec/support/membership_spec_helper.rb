shared_examples "set_venue" do
  it "should assign @venue" do
    expect(assigns(:venue)).to eq venue
  end
end


shared_examples "update membership" do
  it "should redirect to memberships_path(venue)" do
    expect(response).to redirect_to(memberships_path(venue))
  end

  it "should set success message" do
    expect(flash[:notice]).to be_present
  end

  it "should not create new membership" do
    expect(Membership.count).to eq(1)
  end

  it "should update membership attributes" do
    membership.reload
    mhash = params_hash[:membership]
    expect(membership.start_time).to eq(Time.zone.parse(mhash[:start_date] + " " + mhash[:start_time]).utc)
    expect(membership.end_time).to eq(Time.zone.parse(mhash[:end_date] + " " + mhash[:end_time]).utc)
    expect(membership.price).to eq(mhash[:price])
  end

  it "should update the reservations" do
    mhash = params_hash[:membership]
    tparams = {
      :start_time => Time.zone.parse(mhash[:start_date] + " " + mhash[:start_time]).utc,
      :end_time => Time.zone.parse(mhash[:start_date] + " " + mhash[:end_time]).utc,
      :membership_start_time => Time.zone.parse(mhash[:start_date] + " " + mhash[:start_time]).utc,
      :membership_end_time => Time.zone.parse(mhash[:end_date] + " " + mhash[:end_time]).utc
    }
    expect(membership.reservations.count).to eq(calculate_number_of_reservations(tparams, court))
    expect(membership.reservations.first.court.id).to eq(mhash[:court_id])
  end
end

def calculate_number_of_reservations(tparams, court)
  t = tparams.dup
  count = 0
  while (t[:end_time] <= t[:membership_end_time])
    if reservable?(t, court)
      count += 1
    end
    t[:start_time] = t[:start_time].advance(weeks: 1)
    t[:end_time] = t[:end_time].advance(weeks: 1)
  end
  count
end

def reservable?(tparams, court)
  booking_duration = (tparams[:end_time] - tparams[:start_time])*24*60 # in minutes
  min_duration = Court.duration_policies[court.duration_policy]
  valid_duration = (booking_duration >= min_duration) && (booking_duration % min_duration == 0)

  (tparams[:start_time] >= court.created_at) &&
  (tparams[:start_time] >= tparams[:membership_start_time]) &&
  court.venue.in_business?(tparams[:start_time], tparams[:end_time]) &&
  (court.working?(tparams[:start_time], tparams[:end_time])) &&
  valid_duration
end
