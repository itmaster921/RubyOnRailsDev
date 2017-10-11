module VenueGenerateXls
  def generate_xlsx(reservations, from, to, admin)
    Axlsx::Package.new do |p|
      currency = company.currency || I18n.t('number.currency.format.unit')
      p.workbook.styles.fonts.first.name = 'Calibri'
      p.workbook.styles.fonts.first.sz = 12
      header_style = p.workbook.styles.add_style(b: true)
      footer_style = p.workbook.styles.add_style(b: true, border: {style: :thin, color: 'FF000000', edges: [:top]})

      p.workbook.add_worksheet(name: "Chronological") do |sheet|
        sheet.add_row([venue_name], style: header_style)
        sheet.add_row(['Sales report'], style: header_style)
        sheet.add_row

        period = [from, to].map{|t| t.strftime('%d.%m.%Y')}.join(' - ')
        sheet.add_row(["Period", period], style: [header_style, nil])
        sheet.add_row(["Printed on:", TimeSanitizer.output(Time.now).strftime("%d.%m.%Y at %I.%M%p")], style: [header_style, nil])
        sheet.add_row(["By:", admin.full_name], style: [header_style, nil])
        sheet.add_row

        headings = [
          'Date', "Start Time", "End Time",
          "Total price (#{currency})", "Price without VAT (#{currency})", "VAT (#{currency})",
          'Code', 'Customer Name', 'Customer Email', 'Customer Phone Number', 'Payment status', "Amount Paid (#{currency})",
          'Payment method (Online/ At the venue/ To be invoiced/ No info)', "Outstanding Payment (#{currency})", 'Notes'
        ]
        sheet.add_row(headings, style: header_style)
        reservations.each do |r|
          price_without_vat = ( r.price / (1 + company.get_vat_decimal) ).round(2)
          vat = r.price - price_without_vat
          sheet.add_row (
            [
              TimeSanitizer.output(r.start_time).strftime('%d/%m/%Y'), TimeSanitizer.output(r.start_time).strftime("%H:%M"), TimeSanitizer.output(r.end_time).strftime("%H:%M"),
              r.price, price_without_vat, vat,
              r.court.sport, r.user.try(:full_name), r.user.try(:email), r.user.try(:phone_number), r.payment_type.humanize, r.get_amount_paid,
              r.get_payment_method, r.outstanding_balance, r.note
            ]
          )
        end

        reservations_per_user = {}
        reservations.each do |r|
          (reservations_per_user[r.user] ||= []) << r
        end

        p.workbook.add_worksheet(name: "Per Customer") do |sheet|
          headings_user = ["First", "Last", "Email", "Customer Phone Number"]
          headings_resv = ["Date", "Total Price (#{currency})", "Price without VAT (#{currency})", "VAT (#{currency})",
            "Code", "Amount paid (#{currency})", "Payment method (Online/ At the venue/ To be invoiced/ No info)",
            "Outstanding balance (#{currency})", "Recurring reservation (yes/no)", "Notes"]
          reservations_per_user.each do |u, resvs|
            (1..2).each { sheet.add_row }
            sheet.add_row headings_user, style: header_style
            sheet.add_row [(u.try(:first_name) || u.try(:full_name) ), u.try(:last_name), u.try(:email), u.try(:phone_number)]

            offset = [nil]*headings_user.size
            sheet.add_row offset + headings_resv, style: header_style

            user_payments = {total_price: 0, amount_paid: 0}
            resvs.each do |r|
              price_without_vat = ( r.price / (1 + company.get_vat_decimal) ).round(2)
              vat = r.price - price_without_vat
              sheet.add_row (
                offset +
                [
                  TimeSanitizer.output(r.start_time).strftime('%d/%m/%Y'), r.price, price_without_vat, vat,
                  r.court.sport, r.get_amount_paid, r.get_payment_method,
                  r.outstanding_balance, r.membership? ? 'Yes' : 'No', r.note
                ]
              )

              user_payments[:total_price] += r.price
              user_payments[:amount_paid] += r.get_amount_paid
            end

            values = [
              "TOTAL", user_payments[:total_price], *[nil]*3, user_payments[:amount_paid], nil,
              user_payments[:total_price] - user_payments[:amount_paid]
            ]
            sheet.add_row(offset + values, style: [nil] * offset.length + [footer_style] * values.size)
          end
        end
      end
    end
  end
end
