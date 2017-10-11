def in_browser(name)
  Capybara.using_session(name) do
    yield
  end
end

def sign_in_as(user)
  visit new_user_session_path
  #page.save_screenshot('screenshot.png')
  within '#form' do
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button I18n.t('shared.login_modal.login')
  end
end

def sign_in_admin(admin)
  visit new_admin_session_path

  within '#new_admin' do
    fill_in "admin[email]", with: admin.email
    fill_in "admin[password]", with: admin.password
    click_button I18n.t('admins.sessions.new.login_button')
  end
end

def search_datetime(date_time)
  visit root_path

  within 'form.search-venue' do
    fill_in 'searchDate', with: TimeSanitizer.output(date_time).strftime('%d/%m/%Y')

    select TimeSanitizer.time_ceil_at(date_time, 30).strftime('%H:%M'), from: "searchTime", visible: false
    find('#searchAvailableVenuesBtn').click
  end
end

def make_booking(time)
  search_datetime(time)
  #page.save_screenshot('screenshot.png')
  within ".venue__times" do
    click_button TimeSanitizer.output(time).strftime('%H:%M')
    sleep 2
  end
  #page.save_screenshot('screenshot2.png')
  find(".modal-booking__courts div[data-id='#{court.id}']").click
  click_button 'selectBookingsBtn'
  sleep 2
  #page.save_screenshot('screenshot3.png')
  click_button 'makeReservationBtn'
  sleep 3
  #page.save_screenshot('screenshot4.png')
end

def add_stripe_card_to_user(user)
  token = Stripe::Token.create( card: { number: "4242424242424242",
                                exp_month: 1,
                                exp_year: 2017,
                                cvc: 314 } )
  user.add_stripe_id(token.id)
end
