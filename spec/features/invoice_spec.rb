require 'rails_helper'
require 'features/helpers'

feature "invoices", js: true do
  let!(:admin) { create(:admin, :with_company) }
  let!(:company) { admin.company }
  let!(:venue) { create :venue, :with_courts, company: company }
  let!(:court1) { venue.courts.first }
  let!(:court2) { venue.courts.last }
  let!(:user1) { create :user }
  let!(:user2) { create :user }
  let(:start_time) { Time.current.advance(weeks: 2).beginning_of_week.at_noon }

  before do
    venue.users << user1 << user2
    venue.save

    sign_in_admin(admin)
  end

  it 'should be able to open invoices page' do
    visit company_invoices_path(company)
    expect(page.status_code).to eq 200
    expect(page).to have_content(I18n.t('invoices.index.invoices'))
    expect(page).to have_content(I18n.t('invoices.invoice_list.drafts'))
  end

  describe 'create invoice draft' do
    before do
      create :reservation, user: user1, price: 11.0, court: court1, start_time: start_time
      create :reservation, user: user1, price: 3.0,  court: court1, start_time: start_time + 1.days
      create :reservation, user: user1, price: 7.0,  court: court2, start_time: start_time + 1.days,
                                        is_paid: true, payment_type: :paid, is_billed: true
      create :reservation, user: user1, price: 9.0,  court: court2, start_time: start_time + 2.days,
                                        amount_paid: 4, payment_type: :semi_paid
      create :reservation, user: user1, price: 1.0,  court: court2, start_time: start_time + 3.days

      create :reservation, user: user2, price: 13.0, court: court1, start_time: start_time + 2.days

      visit company_invoices_path(company)
      click_link I18n.t('invoices.index.create_invoices')
    end

    context 'users list' do
      it 'should open "Create invoices" tab' do
        expect(find('.tab-pane.active')).to have_content(I18n.t('invoices.create_invoices.header'))
      end

      it 'should list all users with full outstanding balances' do
        expect(page).to have_content(user1.full_name)
        expect(page).to have_content(user1.email)
        expect(page).to have_content(company.user_outstanding_balance(user1))

        expect(page).to have_content(user2.full_name)
        expect(page).to have_content(user2.email)
        expect(page).to have_content(company.user_outstanding_balance(user2))
      end
    end

    context 'selected user has unpaid reservations for selected time' do
      before do
        fill_in "start_date", with: (start_time + 1.days).to_s(:date)
        fill_in "end_date", with: (start_time + 2.days).to_s(:date)
        find("input[type='checkbox'][name='user_ids[]'][value='#{user1.id}']").click

        click_button I18n.t('invoices.create_invoices.submit_button')
      end

      it 'should create invoice only for selected user' do
        expect(Invoice.count).to eq 1
        expect(Invoice.first.user).to eq user1
        expect(Invoice.first.is_draft).to be_truthy
      end

      it 'should create invoice components for unpaid reservations within selected time' do
        expect(Invoice.first.invoice_components.count).to eq 2
        # unique prices used
        expect(Invoice.first.reservations.map(&:price).sort).to eq [3.0, 9.0].sort
      end

      it 'should set right amount for payment in the invoice' do
        Invoice.first.invoice_components.each do |invoice_component|
          reservation = invoice_component.reservation
          expect(invoice_component.price).to eq reservation.outstanding_balance
        end
      end
    end

    context 'selected user does not have unpaid reservations for selected time' do
      before do
        fill_in "start_date", with: (start_time).to_s(:date)
        fill_in "end_date", with: (start_time + 1.days).to_s(:date)
        find("input[type='checkbox'][value='#{user2.id}']").click

        click_button I18n.t('invoices.create_invoices.submit_button')
      end

      it 'should not create invoice' do
        expect(Invoice.count).to eq 0
      end
    end
  end

  describe 'send invoice draft' do
    before do
      create :reservation, user: user1, price: 11.0, court: court1, start_time: start_time
      create :reservation, user: user1, price: 20.0, court: court2, start_time: start_time,
                                        amount_paid: 7, payment_type: :semi_paid

      visit company_invoices_path(company)
      click_link I18n.t('invoices.index.create_invoices')
      fill_in "start_date", with: (start_time).to_s(:date)
      fill_in "end_date", with: (start_time + 1.days).to_s(:date)
      find("input[type='checkbox'][name='user_ids[]'][value='#{user1.id}']").click
      click_button I18n.t('invoices.create_invoices.submit_button')
      click_link I18n.t('invoices.invoice_list.drafts')
    end

    it 'should list created invoices' do
      expect(page).to have_content(user1.email)
      expect(page).to have_content(Invoice.first.total)
    end

    it 'should unset is_draft for invoice, and set is_billed for invoice_components and reservations' do
      find("input[type='checkbox'][name='invoice_ids'][value='#{user1.id}']").click
      click_link I18n.t('invoices.drafts_table.send_link')

      expect(page).to have_selector(".toast-info")
      expect(Invoice.first.is_draft).to be_falsey
      expect(Invoice.first.invoice_components.first.is_billed).to be_truthy
      expect(Invoice.first.invoice_components.first.reservation.is_billed).to be_truthy
    end


    context 'create custom invoice component' do
      before do
        find("tr[data-id='#{Invoice.first.id}']").click
        find('#add-custom-invoice-component').click
        fill_in "custom_invoice_component[name]", with: 'custom_component1'
        fill_in "custom_invoice_component[price]", with: 17
        select '10.0%', from: 'custom_invoice_component[vat_decimal]'
      end

      it 'should create custom component' do
        click_button I18n.t('invoices.custom_invoice_component_form.create')
        sleep 3

        expect(Invoice.first.custom_invoice_components.count).to eq 1
        expect(page).to have_content('custom_component1')
      end

      it 'should calculate invoice total with custom component price' do
        fill_in "custom_invoice_component[price]", with: 17
        click_button I18n.t('invoices.custom_invoice_component_form.create')
        sleep 3

        invoiced_outstanding_balance = Invoice.first.reservations.map(&:outstanding_balance).sum

        expect(Invoice.first.total).to eq invoiced_outstanding_balance + 17
        expect(Invoice.first.total).to eq 11 + (20 - 7) + 17
      end

      it 'should calculate invoice total with negative custom component price(discount)' do
        fill_in "custom_invoice_component[price]", with: -17
        click_button I18n.t('invoices.custom_invoice_component_form.create')
        sleep 3

        invoiced_outstanding_balance = Invoice.first.reservations.map(&:outstanding_balance).sum

        expect(Invoice.first.total).to eq invoiced_outstanding_balance - 17
        expect(Invoice.first.total).to eq 11 + (20 - 7) - 17
      end
    end
  end

  describe 'mark sent invoice as paid' do
    before do
      create :reservation, user: user1, price: 11.0, court: court1, start_time: start_time
      create :reservation, user: user1, price: 13.0, court: court2, start_time: start_time

      visit company_invoices_path(company)
      click_link I18n.t('invoices.index.create_invoices')
      fill_in "start_date", with: (start_time).to_s(:date)
      fill_in "end_date", with: (start_time + 1.days).to_s(:date)
      find("input[type='checkbox'][name='user_ids[]'][value='#{user1.id}']").click
      click_button I18n.t('invoices.create_invoices.submit_button')
      find("input[type='checkbox'][name='invoice_ids'][value='#{user1.id}']").click
      click_link I18n.t('invoices.drafts_table.send_link')

      click_link I18n.t('invoices.invoice_list.updaid')
      find("input[type='checkbox'][name='invoice_ids'][value='#{user1.id}']").click
      click_link I18n.t('invoices.invoice_list.mark_paid_link')
    end

    it 'should set is_paid for invoice and invoice_components' do
      expect(Invoice.first.is_paid).to be_truthy
      expect(Invoice.first.invoice_components.first.is_paid).to be_truthy
    end

    it 'should set is_paid, and set amount_paid to price for reservations' do
      reservation = Invoice.first.invoice_components.first.reservation.reload
      expect(reservation.is_paid).to be_truthy
      expect(reservation.amount_paid).to eq reservation.price
    end
  end
end
