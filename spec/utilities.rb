# This file has to be required in rails_helper.rb
# helper methods to be used in all rspec files

def mock_file_upload(filename, type)
  mock_path = Rails.root.join('spec', 'mockdata', filename)
  return ActionDispatch::Http::UploadedFile.new(:tempfile => File.new(mock_path , :type => type, :filename => filename))
end
