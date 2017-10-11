# need to access private method #session_pool
module Capybara
  def self.custom_session_names
    session_pool.keys.map { |k| k.to_s.split(':').try(:[], 1) }.compact
  end
end
