class CustomInvoiceComponent < ActiveRecord::Base
  DEFAULT_VAT_DECIMALS = [BigDecimal.new('0'), BigDecimal.new('0.10'), BigDecimal.new('0.14'), BigDecimal.new('0.24')]

  belongs_to :invoice

  validates :price, :name, :vat_decimal, presence: true

  def calculate_vat
    price - calculate_price_without_vat
  end

  def calculate_price_without_vat
    (price / (1 + vat_decimal)).round(2)
  end

  def vat_to_s
    "#{vat_decimal * 100}%"
  end

  def bill!
    self.update_attributes(is_billed: true)
  end

  def charged!
    self.update_attributes(is_billed: true, is_paid: true)
  end
end
