json.component do
  json.id @custom_invoice_component.id
  json.name @custom_invoice_component.name
  json.vat @custom_invoice_component.vat_to_s
  json.price number_to_currency(@custom_invoice_component.price)
  json.delete_link link_to(t('invoices.drafts_table.delete_link'),
                             invoice_custom_invoice_component_path(@invoice, @custom_invoice_component),
                             data: { remote: true, method: :delete,
                                     confirm: t('invoices.drafts_table.delete_confirm') })
end
json.invoice_id @invoice.id
json.invoice_total @invoice.total
