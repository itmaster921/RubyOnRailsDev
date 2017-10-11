class InvoiceMailer < ApplicationMailer
  def invoice_email(user, invoice)
    @user = user
    @invoice = invoice
    #file_path = "#{Rails.root.to_s}" + "#{company_invoice_path(@invoice.company, @invoice, format: :pdf)}"
    #attachments["lasku.pdf"] = {:mime_type => 'application/pdf', :content => company_invoice_path(@invoice.company, @invoice, format: :pdf)}
    # @invoice.render_pdf_file(file_path)
    #attachments['invoice.pdf'] = File.read(file_path)
    mail(to: @user.email, subject: "Laskunne yritykseltä #{@invoice.company.company_legal_name}")
  end
end
