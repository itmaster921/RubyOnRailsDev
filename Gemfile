source 'https://rubygems.org'
ruby '2.3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'font-awesome-rails'
gem 'pg'
gem 'rails_12factor', group: :production
gem 'sass-rails', '~> 5.0.4'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
# This gem needs to be specified before both devise and any amniauth gem
# See here for details: https://github.com/bkeepers/dotenv#note-on-load-order
gem 'dotenv-rails', :groups => [:development, :test]
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'mixpanel-ruby'
gem 'toastr-rails'
gem 'react-rails'
gem 'i18n-js', '>= 3.0.0.rc11'
gem 'paperclip',
    git: 'https://github.com/thoughtbot/paperclip',
    ref: '523bd46c768226893f23889079a7aa9c73b57d68'

gem 'geocoder'
gem 'jquery-rails'
gem 'figaro'
gem 'aws-sdk'
gem 'clockpicker-rails'
gem 'bootstrap-datepicker-rails'
gem 'rspec-rails', group: [:test]
gem 'factory_girl_rails', group: [:test]
gem 'icalendar'
gem 'stripe'
gem 'groupdate'
gem 'viitenumero'
gem 'rack-cors'
gem 'jwt'

gem 'chart-js-rails'

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'owlcarousel2-rails'

gem 'mailcatcher', group: :development
gem 'rails-latex'

gem 'iban-tools'
gem 'henkilotunnus'

gem 'cancancan'
gem 'activemerchant'

gem 'remotipart'
gem 'byebug'

gem 'react-bootstrap-rails'
gem 'axios_rails', '~> 0.14.0'

gem 'smarter_csv', '~> 1.1.1'

# for data entry
gem 'simple_xlsx_reader'

# generate xlsx reports
gem 'axlsx'
gem 'rubyzip', '< 1.0.0'

# Load will_paginate before elasticsearch gems.
gem 'will_paginate', '~> 3.1'

# Elasticsearch
gem 'elasticsearch-model', '~> 0.1.8'
gem 'elasticsearch-rails', '~> 0.1.8'

# Image compression
gem 'sprockets-image_compressor'

# sidekiq
gem 'sidekiq', '4.2.6'

# sidekiq uses sinatra for web interface
gem 'sinatra'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'shut_up_assets', '~> 2.0.2'
  gem 'letter_opener', '~> 1.4.1'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'database_cleaner'
end

group :doc do
  gem 'sdoc', require: false
end
