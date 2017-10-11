require "rails_helper"

describe 'Customers API', type: :request do
  context 'before callbacks' do
    it 'return 401 if not authenticated as admin' do
      get "/api/customers"

      expect(response.status).to eq 401
    end

    it 'returns JSON with error if company has no venue' do
      admin = create(:admin, :with_company)
      sign_in admin

      get "/api/customers"

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.no_venue'))
    end
  end

  describe "GET index" do
    let!(:admin) { create :admin, :with_company }

    before do
      sign_in admin
    end

    context 'customers for current company' do
      let!(:venue) { create :venue, :with_users, :with_courts, user_count: 2, company: admin.company }
      let!(:user1) { venue.users.order(:created_at).first }
      let!(:user2) { venue.users.order(:created_at).last }
      let!(:reservation1)  { create :reservation, user: user1, price: 7.0, court: venue.courts.first }
      let!(:reservation2)  { create :reservation, user: user2, price: 9.0, court: venue.courts.last }
      #other company venue and user with reservation
      let!(:venue2) { create :venue, :with_courts, :with_users, user_count: 1, court_count: 1 }
      let!(:other_company_reservation)  {
        create :reservation, user: venue2.users.first, price: 11.0, court: venue2.courts.first
      }

      it 'returns JSON with users array' do
        get "/api/customers"

        expect(response).to be_success
        expect(json['customers'].is_a?(Array)).to be_truthy
      end

      it 'returns users sorted by created_at' do
        get "/api/customers"

        expect(json['customers'].map { |u| u['id'].to_i }).to eq venue.users.order(:created_at).map(&:id)
      end

      it 'returns users for current company' do
        get "/api/customers"

        expect(json['customers'].count).to eq 2
        expect(json['customers'].first['id']).to eq user1.id
        expect(json['customers'].last['id']).to eq user2.id
      end

      it 'returns correct users data' do
        get "/api/customers"

        expect(extract_data(json['customers'].first)).to eq extract_data(user1)
        expect(extract_data(json['customers'].last)).to eq extract_data(user2)
      end

      it 'returns outstanding balances for current company for each user' do
        get "/api/customers"
        balance1 = admin.company.user_outstanding_balance(user1)
        balance2 = admin.company.user_outstanding_balance(user2)

        expect(json['customers'].first['outstanding_balance']).to eq balance1
        expect(json['customers'].last['outstanding_balance']).to eq balance2
      end

      it 'returns reservations data for current company for each user' do
        get "/api/customers"

        expect(json['customers'].first['reservations_done']).to eq 1
        expect(json['customers'].last['reservations_done']).to eq 1
      end
    end

    context 'pagination' do
      let!(:venue) { create :venue, :with_users, user_count: 20, company: admin.company }
      let!(:users) { venue.users.order(:created_at) }

      it 'defaults per_page to 10' do
        get "/api/customers"

        expect(json['customers'].count).to eq 10
      end

      it 'returns users for first page' do
        get "/api/customers"

        expect(json['customers'].first['id']).to eq users[0].id
        expect(json['customers'].last['id']).to eq users[9].id
      end

      it 'returns users for second page' do
        get "/api/customers", { page: 2 }

        expect(json['customers'].first['id']).to eq users[10].id
        expect(json['customers'].last['id']).to eq users[19].id
      end

      it 'returns third page with per_page users' do
        get "/api/customers", { page: 3, per_page: 3 }

        expect(json['customers'].count).to eq 3
        expect(json['customers'].first['id']).to eq users[6].id
        expect(json['customers'].last['id']).to eq users[8].id
      end

      it 'returns pagination data for current page' do
        get "/api/customers", { page: 3, per_page: 3 }

        expect(json['current_page']).to eq 3
        expect(json['total_pages']).to eq 7
      end
    end

    context 'search' do
      let!(:venue) { create :venue, :with_users, user_count: 2, company: admin.company }
      let!(:search_query) { 'search@que.ry' }
      let! (:user1) { create :user, first_name: search_query, venues: [venue] }
      let! (:user2) { create :user, last_name: search_query, venues: [venue] }
      let! (:user3) { create :user, email: search_query, venues: [venue] }

      before do
        sign_in admin
      end

      it 'returns users for searched query by first_name, last_name or email' do
        get "/api/customers", { search: search_query }

        expect(json['customers'].count).to eq 3
        expect(json['customers'].first['id']).to eq user1.id
        expect(json['customers'].last['id']).to eq user3.id
      end

      it 'returns users for searched query by part of first_name, last_name or email' do
        get "/api/customers", { search: search_query[2..-2] }

        expect(json['customers'].count).to eq 3
        expect(json['customers'].first['id']).to eq user1.id
        expect(json['customers'].last['id']).to eq user3.id
      end

      it 'returns users for searched query by full_name' do
        get "/api/customers", { search: "#{search_query} #{user1.last_name}" }

        expect(json['customers'].count).to eq 1
        expect(json['customers'].first['id']).to eq user1.id
      end

      it 'returns users for searched query by part of full_name' do
        get "/api/customers", { search: "#{search_query} #{user1.last_name}"[2..-2] }

        expect(json['customers'].count).to eq 1
        expect(json['customers'].first['id']).to eq user1.id
      end

      it 'returns users for searched query by phone number' do
        get "/api/customers", { search: "#{user1.phone_number}" }

        expect(json['customers'].count).to eq 1
        expect(json['customers'].first['id']).to eq user1.id
      end

      it 'returns users for searched query by part of phone number' do
        get "/api/customers", { search: "#{user1.phone_number}"[1..-1] }

        expect(json['customers'].count).to eq 1
        expect(json['customers'].first['id']).to eq user1.id
      end

      it 'returns users for current page, per_page and search query' do
        get "/api/customers", { search: search_query, page: 2, per_page: 1 }

        expect(json['customers'].count).to eq 1
        expect(json['customers'].first['id']).to eq user2.id
      end

      it 'returns no users for wrong query' do
        get "/api/customers", { search: "#{search_query}*#{search_query}" }

        expect(json['customers'].count).to eq 0
      end
    end
  end

  describe "GET show" do
    let!(:admin) { create :admin, :with_company }
    let!(:venue) { create :venue, :with_users, :with_courts, court_count: 1, company: admin.company }
    let!(:user)  { venue.users.first }

    before do
      sign_in admin
    end

    it 'returns user as JSON' do
      get "/api/customers/#{user.id}"

      expect(response).to be_success
      expect(json['id']).to eq user.id
      expect(extract_data(json)).to eq extract_data(user)
    end

    it 'returns JSON with error if user not found' do
      get "/api/customers/#{user.id + 1}"

      expect(response.status).to eq 404
      expect(json['errors']).to include(I18n.t('api.customers.user_not_found'))
    end

    context 'many companies' do
      let!(:reservation)  { create :reservation, user: user, price: 7.0, court: venue.courts.first }

      let!(:venue2) { create :venue, :with_courts, court_count: 1 }
      let!(:venue2_conector) { venue2.add_customer(user) }
      let!(:other_company_reservation)  { create :reservation, user: user, price: 7.0, court: venue2.courts.first }

      it 'returns JSON with outstanding_balance for current company' do

        get "/api/customers/#{user.id}"

        expect(response).to be_success
        expect(json['outstanding_balance']).to eq admin.company.user_outstanding_balance(user)
      end

      it 'returns reservations data for current company' do
        get "/api/customers/#{user.id}"

        reservation_date = TimeSanitizer.strftime(reservation.start_time, :date)

        expect(json['reservations_done']).to eq 1
        expect(json['last_reservation']).to eq reservation_date
      end

      it 'returns lifetime value for current company' do
        get "/api/customers/#{user.id}"

        expect(json['lifetime_value']).to eq admin.company.user_lifetime_balance(user)
      end
    end
  end

  describe "POST create" do
    let!(:admin) { create :admin, :with_company }
    let!(:venue) { create :venue, :with_users, company: admin.company }
    let!(:user)  { venue.users.first }
    let!(:params) { valid_params }

    before do
      user.update_attributes(confirmed_at: nil)
      sign_in admin
    end

    context "with valid params" do
      it "creates user" do
        post "/api/customers", params

        expect(response).to be_success
        expect(json['id']).not_to eq nil
        new_user = User.find_by_id(json['id'])
        expect(new_user).not_to eq nil
        expect(new_user).not_to eq user
      end

      it "populates user with data from sent params" do
        post "/api/customers", params

        new_user = User.find_by_id(json['id'])
        expect(extract_data(new_user)).to eq extract_data(params[:customer])
      end

      it "returns new user as JSON" do
        post "/api/customers", params

        new_user = User.find_by_id(json['id'])
        expect(extract_data(json)).to eq extract_data(new_user)
      end

      it "adds user to company" do
        post "/api/customers", params

        user = User.find_by_id(json['id'])

        expect(user.companies).to include(admin.company)
      end
    end

    context "with invalid params" do
      before do
        params[:customer][:first_name] = ''
      end

      it "not creates user" do
        expect {
          post "/api/customers", params
        }.to_not change(User, :count)
      end

      it "returns JSON with errors" do
        post "/api/customers", params

        expect(response.status).to eq 422

        test_user = User.new(params[:customer])
        test_user.valid?
        expect(test_user.errors).to include(:first_name)
        expect(json['errors']).to include(test_user.errors.full_messages.first)
      end
    end

    context 'with already existed email' do
      before do
        params[:customer][:email] = user.email
      end

      it "not creates user" do
        expect {
          post "/api/customers", params
        }.to_not change(User, :count)
      end

      it "returns JSON with errors" do
        post "/api/customers", params

        expect(response.status).to eq 422

        test_user = User.new(params[:customer])
        test_user.valid?
        expect(test_user.errors).to include(:email)
        expect(json['errors']).to include(test_user.errors.full_messages.first)
      end
    end
  end

  describe "PUT update" do
    let!(:admin) { create :admin, :with_company }
    let!(:venue) { create :venue, :with_users, company: admin.company }
    let!(:user)  { venue.users.first }
    let!(:params) { valid_params }

    before do
      User.where(id: user.id).update_all(confirmed_at: nil, uid: nil, encrypted_password: '')
      user.reload
      sign_in admin
    end

    it 'returns JSON with error if user already confirmed' do
      user.update_attributes(confirmed_at: Time.current)

      put "/api/customers/#{user.id}", params

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    it 'returns JSON with error if user has password' do
      User.where(id: user.id).update_all(encrypted_password: "$2a$10$ktWlr3ZV0V6uq1GNWMS83eZZDqEP2BVdvUUlEJbHbS0dcsoWVlo36")

      put "/api/customers/#{user.id}", params

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    it 'returns JSON with error if user has uid' do
      user.update_attributes(uid: 'qwerqwer')

      put "/api/customers/#{user.id}", params

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    context "with valid params" do
      it "updates user and returns OK" do
        put "/api/customers/#{user.id}", params

        expect(response).to be_success
        user.reload
        expect(extract_data(user)).to eq extract_data(params[:customer])
      end
    end

    context "with invalid params" do
      before do
        params[:customer][:first_name] = ''
      end

      it "not updates user" do
        put "/api/customers/#{user.id}", params

        expect(response.status).to eq 422
        user.reload
        expect(extract_data(user)).not_to eq extract_data(params[:customer])
      end

      it 'returns JSON with errors' do
        put "/api/customers/#{user.id}", params

        test_user = User.new(params[:customer])
        test_user.valid?
        expect(test_user.errors).to include(:first_name)
        expect(json['errors']).to include(test_user.errors.full_messages.first)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:admin) { create :admin, :with_company }
    let!(:venue) { create :venue, :with_users, company: admin.company }
    let!(:user)  { venue.users.first }

    before do
      User.where(id: user.id).update_all(confirmed_at: nil, uid: nil, encrypted_password: '')
      user.reload
      sign_in admin
    end

    it 'returns JSON with error if user already confirmed' do
      user.update_attributes(confirmed_at: Time.current)

      delete "/api/customers/#{user.id}"

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    it 'returns JSON with error if user has password' do
      User.where(id: user.id).update_all(encrypted_password: "$2a$10$ktWlr3ZV0V6uq1GNWMS83eZZDqEP2BVdvUUlEJbHbS0dcsoWVlo36")

      delete "/api/customers/#{user.id}"

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    it 'returns JSON with error if user has uid' do
      user.update_attributes(uid: 'qwerqwer')

      delete "/api/customers/#{user.id}"

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.already_confirmed'))
    end

    it 'returns JSON with error if user already shared with other companies' do
      venue2 = create(:venue)
      venue2.add_customer(user)

      delete "/api/customers/#{user.id}"

      expect(response.status).to eq 422
      expect(json['errors']).to include(I18n.t('api.customers.shared_user'))
      expect(User.find_by_id(user.id)).to eq user
    end

    context "can delete" do
      it "deletes user and returns OK" do
        delete "/api/customers/#{user.id}"

        expect(response).to be_success

        expect(User.find_by_id(user.id)).to eq nil
      end
    end

    context "can not delete" do
      it "not deletes user and returns JSON with error" do
        # stub destroy failure
        allow(User).to receive(:find_by_id).with(user.id.to_s).and_return(user)
        allow(user).to receive(:destroy).and_return(false)

        delete "/api/customers/#{user.id}"

        expect(response.status).to eq 422
        expect(json['errors']).to include(I18n.t('api.customers.cant_delete'))
        expect(user.reload).to eq user
      end
    end
  end

  def valid_params
    {
      customer: {
        first_name: FactoryGirl.generate(:first_name),
        last_name: FactoryGirl.generate(:last_name),
        email: FactoryGirl.generate(:email),
        phone_number: "8095672189",
        city: 'Chikagostan',
        street_address: 'Some address 5/6',
        zipcode: '32454',
      }
    }.with_indifferent_access
  end

  # db/json/params user data as array for simplier matching
  def extract_data(user)
    valid_params[:customer].keys.map { |k| user[k.to_s] }
  end
end
