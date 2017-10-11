require 'erb'

class Invoice < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  belongs_to :company
  belongs_to :user
  has_many :invoice_components, dependent: :destroy
  has_many :custom_invoice_components, dependent: :destroy
  has_many :reservations, through: :invoice_components

  before_create :calculate_total
  validates_presence_of :total, on: :update

  scope :drafts, -> { where(is_draft: true) }
  scope :unpaid, -> { where(is_draft: false, is_paid: false) }
  scope :paid, -> { where(is_draft: false, is_paid: true) }


  def self.create_for_company_and_reservations(company, reservations, user)
    invoice = self.create(company: company, user: user, reference_number: FIViite.random(length: 10).paper_format, invoice_components: reservations.map do |reservation|
      InvoiceComponent.new(
        reservation: reservation,
        price: reservation.outstanding_balance,
        start_time: reservation.start_time, end_time: reservation.end_time)
    end)

    invoice.reload
  end

  def calculate_total
    self.total = invoice_components.map(&:price).sum +
                  custom_invoice_components.map(&:price).sum
  end

  def calculate_total!
    self.calculate_total
    self.save!
  end

  def send!
    transaction do
      invoice_components.map(&:bill!)
      custom_invoice_components.map(&:bill!)

      self.update_attributes(is_draft: false, billing_time: TimeSanitizer.input(DateTime.now.to_s))
      send_email
    end
  end

  def send_email
    InvoiceMailer.invoice_email(self.user, self).deliver_later!
  end

  def render_pdf_file(file_path='/tmp/1.pdf')
    @invoice = self
    @company = self.company
    template = File.read(Rails.root.to_s + '/app/views/invoices/_invoice.pdf.erb')
    erb = ERB.new(template)
    b = binding
    html = erb.result(b)
    pdf = WickedPdf.new.pdf_from_string(html)
    File.open(file_path, 'wb') do |file|
      file << pdf
    end
  end

  def charge(token)
    self.transaction do
      Stripe::Charge.create(
        amount: self.total.to_int * 100,
        currency: 'usd',
        source: token,
        customer: self.user.stripe_id,
        description: "#{self.company.company_legal_name} invoice #{self.id}",
        destination: self.company.stripe_user_id
      )
      self.invoice_components.map(&:charged!)
      self.custom_invoice_components.map(&:charged!)
    end
  end

  def self.generate_invoice_excel(company, invoices, admin, from, to)
    Axlsx::Package.new do |p|
      currency = company.currency || I18n.t('number.currency.format.unit')
      p.workbook.styles.fonts.first.name = 'Calibri'
      p.workbook.styles.fonts.first.sz = 12
      header_style = p.workbook.styles.add_style(b: true)

      p.workbook.add_worksheet(name: "Sheet1") do |sheet|
        sheet.add_row([company.company_legal_name], style: header_style)
        sheet.add_row(['Invoice report'], style: header_style)
        sheet.add_row
        period = [from, to].map{|t| t.strftime('%d.%m.%Y')}.join(' - ')
        sheet.add_row(["Invoice period", period], style: [header_style, nil])
        sheet.add_row(["Number of Invoice", invoices.count], style: [header_style, nil])
        sheet.add_row(["Printed on:", TimeSanitizer.output(Time.now).strftime("%d.%m.%Y at %I.%M%p")], style: [header_style, nil])
        sheet.add_row(["By:", admin.full_name], style: [header_style, nil])
        sheet.add_row

        headings = [
          'Invoice reference number', "Total (#{currency})", "VAT (#{currency})",
          "Due date",
          "Billing date",
          "Customer name", "Email address", "Billing address"
        ]

        sheet.add_row(headings, style: header_style)

        invoices.each do |invoice|
          user = invoice.user

          sheet.add_row (
            [
              invoice.reference_number, invoice.total, invoice.calculate_total_vat,
              invoice.get_due_date,
              (TimeSanitizer.output(invoice.billing_time).strftime('%d/%m/%Y') if invoice.billing_time),
              user.try(:full_name), user.try(:email), user.get_billing_address
            ]
          )
        end

      end

    end
  end

  def calculate_total_vat
    invoice_components.includes(reservation: [:court]).map(&:reservation).map(&:calculate_vat).sum +
      custom_invoice_components.map(&:calculate_vat).sum
  end

  def get_due_date
    TimeSanitizer.output(Time.now.advance(weeks: 2)).strftime('%d/%m/%Y')
  end

  def self.mark_paid(invoice_ids)
    invoices = Invoice.where(id: invoice_ids)
    invoice_components = InvoiceComponent.where(invoice: invoices)
    custom_invoice_components = CustomInvoiceComponent.where(invoice: invoices)
    reservations = Reservation.where(id: invoice_components.map(&:reservation_id))

    count = invoices.update_all(is_paid: true)
    invoice_components.update_all(is_paid: true)
    custom_invoice_components.update_all(is_paid: true)
    reservations.update_all("is_paid = true, amount_paid = price")
    count
  end
end
