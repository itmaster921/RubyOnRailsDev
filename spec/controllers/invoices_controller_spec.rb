require 'rails_helper'

describe InvoicesController do
  let!(:venue) { FactoryGirl.create(:venue) }
  let!(:company) { venue.company }
  let!(:court) { FactoryGirl.create(:court, venue: venue)}
  let!(:user) {
    user = FactoryGirl.create(:user)
    user.venues.append(venue)
    user
  }
  let!(:reservation) { FactoryGirl.create(:reservation, user: user, court: court)}
  let!(:invoice) { Invoice.create_for_company_and_reservations(company, [reservation], user) }
  let!(:admin) { FactoryGirl.create(:admin) }

  before do
    ActionMailer::Base.deliveries.clear
    invoice.send!
  end

  describe "POST create_report" do
    before do
      sign_in admin
      params = { company_id: company.id, report: {from: Date.yesterday, to: Date.today}}
      post :create_report, params
    end

    it "should respond with success 200" do
      expect(response).to be_success
    end

    it "should download excel file" do
      expect(response.header['Content-Type']).to eq('application/xlsx')
    end
  end

  describe "POST mark_paid" do
    before do
      sign_in admin
      params = { company_id: company.id, selected_ids: [invoice.id]}
      post :mark_paid, params
    end

    it "should mark paid selected invoies" do
      expect(flash[:notice]).to be_present
      expect(invoice.reload.is_paid).to be_truthy
      expect(invoice.invoice_components.first.is_paid).to be_truthy
      expect(reservation.reload.is_paid).to be_truthy
      expect(reservation.reload.amount_paid).to eq(reservation.price)
    end
  end
end
