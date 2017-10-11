FactoryGirl.define do
  factory :company do
    company_legal_name 'Test Company'
    company_country 'Finland'
    company_business_type 'OY'
    company_tax_id 'FI2381233'
    company_street_address 'Mannerheimintie 5'
    company_zip '00100'
    company_city 'Helsinki'
    company_website 'www.testcompany.com'
    company_phone '+3585094849438'
    company_iban 'GR16 0110 1250 0000 0001 2300 695'
  end
end
