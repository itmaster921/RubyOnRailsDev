module Passport
  extend ActiveSupport::Concern

  def save_passport(file)
    file_path = write_file(file)
    stripe_file = Stripe::FileUpload.create({ purpose: 'identity_document',
                                              file: File.new(file_path) },
                                            stripe_account: company.stripe_user_id)

    account = Stripe::Account.retrieve(company.stripe_user_id)
    account.legal_entity.verification.document = stripe_file.id
    account.legal_entity.additional_owners = nil
    account.save
    remove_file(file_path)
  end

  private

  def write_file(file)
    file_path = Rails.root.join('tmp', file.original_filename)
    dir_path = Rails.root.join('tmp')
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    File.open(file_path, 'wb') do |newfile|
      newfile.write(file.read)
    end
    file_path
  end

  def remove_file(file)
    File.delete(file)
  end
end
