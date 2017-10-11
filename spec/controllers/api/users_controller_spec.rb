require "rails_helper"


describe API::UsersController, type: :controller do
  let(:user)         { build_stubbed(:user) }
  let(:unconfirmed_user) { create :user, password: 'password', password_confirmation: 'password', confirmed_at: nil }
  let(:confirmed_user) { create :user, password: 'password', password_confirmation: 'password' }
  let(:empty_password_user) { create :user, encrypted_password: '', confirmed_at: nil }
  let(:valid_params) { user.attributes }


  describe "Email Check" do 
    before { user = User.create(email: 'email@check.com', first_name: 'Test', last_name: 'Test') }
    context "with valid email" do
      it "will find user and return 200" do
        get :email_check, { email: 'email@check.com' }
        response_body = JSON.parse(response.body.to_s)
        expect(response.status).to eql 200
        expect(response_body['message']).to eql I18n.t('api.users.email_check.success')
      end
    end

    context "with invalid email" do
        it "will return 422 and an error message" do
          get :email_check, { email: 'email@google' }
          response_body = JSON.parse(response.body.to_s)
          expect(response.status).to eql 422
          expect(response_body['message']).to eql I18n.t('api.users.email_check.error')
        end
    end

    context "with no email param" do
        it "will return 422 and message that email is missing" do
          get :email_check
          response_body = JSON.parse(response.body.to_s)
          expect(response.status).to eql 422
          expect(response_body['message']).to eql I18n.t('api.users.email_check.email_required')
        end
    end
  end
  describe "POST create" do
    context "with valid params" do
      it "creates user and returns as JSON" do
        user_count = User.count
        # we need to stub User.to_json to avoid time discrepencies with created_at/updated_at
        allow_any_instance_of(User).to receive(:to_json).and_return(valid_params.to_json)
        expect(AuthToken).to receive(:encode).with(valid_params).and_return('abc123')
        post :create, { user: valid_params }.to_json
        expect(User.last.email).to eql user.email
        expect(User.count).to eql user_count + 1
        expect(response.body).to eql({ auth_token: 'abc123' }.to_json)
      end
    end

    context "with invalid params" do
      before { valid_params.delete('email') }

      it "creates user and returns as JSON" do
        user_count = User.count
        post :create, { user: valid_params }
        expect(response.status).to eql 422
        expect(User.count).to eql user_count
      end
    end

    context 'with already existed email' do
      it 'returns JSON with errors' do
        post :create, { email: unconfirmed_user.email }
        response_body = JSON.parse(response.body)

        expect(response.status).to eql 422
        expect(response_body['error']).to eql('already_exists')
      end
    end

    context 'with unconfirmed user' do
      it 'returns JSON with errors' do
        post :create, { email: empty_password_user.email }
        response_body = JSON.parse(response.body)

        expect(response.status).to eql 422
        expect(response_body['error']).to eql('unconfirmed_account')
      end
    end
  end

  describe 'POST confirm account' do
    context 'with missing email parameter' do
      it 'does not send account confirmation instructions' do
        post :confirm_account
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 422
        expect(response_body['message']).to eql I18n.t('api.users.confirm_account.email_required')
      end
    end

    context 'with correct email parameter' do
      it 'send confirmation instructions to the email' do
        post :confirm_account, { user: { email: 'test4@test.com' } }.to_json
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 200
        expect(response_body['message']).to eql I18n.t('api.users.confirm_account.success')
      end
    end
  end

  describe 'POST reset password instructions' do
    context 'with invalid email parameter' do
      it 'does not send confirmation instructions' do
        post :reset_password, { email: 'invalid_email' }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 404
      end
    end

    context 'with correct email parameter' do
      it 'send confirmation instructions to the email' do
        user = User.create(email: 'test2@test.com', first_name: 'Test', last_name: 'Test')
        post :reset_password, { email: 'test2@test.com' }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 200
        expect(response_body['message']).to eql I18n.t('api.users.reset_password_email')
      end
    end
  end

  describe 'PUT update' do
    before { request.headers.merge!({ 'Authorization' => 'Bearer SECRETTOKEN' }) }

    context 'with unauthorized user' do
      it 'does not update user and returns as JSON' do
        expect(AuthToken).to receive(:decode).with('SECRETTOKEN').and_return({id: 12345678})
        put :update, { id: user.id }, { user: { first_name: 'FirstName' } }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 401
        expect(response_body['errors']).to eql [I18n.t('api.authentication.unauthorized')]
      end
    end

    context 'with valid parameters' do
      it 'updates the user and returns as JSON' do
        user = User.create(email: 'test1@test.com', first_name: 'Test', last_name: 'Test')
        expect(AuthToken).to receive(:decode).with('SECRETTOKEN').and_return({id: user.id})
        put :update, { id: user.id }, { user: { first_name: 'FirstName' } }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 200
        expect(response_body['message']).to eql I18n.t('api.users.profile_updated')
      end
    end
  end

  describe 'PUT update password' do
    before { request.headers.merge!({ 'Authorization' => 'Bearer SECRETTOKEN' }) }
    before { sign_in_for_api_with(confirmed_user, token: 'SECRETTOKEN') }

    context 'with incorrect current_password' do
      it 'does not update the user password' do
        request.env['RAW_POST_DATA'] = { user: { current_password: 'hello', password: 'password' } }.to_json
        put :update, { id: confirmed_user.id, type: 'password' }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 422
        expect(response_body['message']).to eql ["Current password #{I18n.t('activerecord.errors.models.user.attributes.current_password.invalid')}"]
      end
    end

    context 'with incorrect password' do
      it 'does not update the user password' do
        request.env['RAW_POST_DATA'] = { user: { current_password: 'password', password: 'abc' } }.to_json
        put :update, { id: confirmed_user.id, type: 'password' }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 422
        expect(response_body['message']).to eql ["Password #{I18n.t('activerecord.errors.models.user.attributes.password.too_short')}"]
      end
    end

    context 'with correct password and current_password' do
      it 'does not update the user password' do
        request.env['RAW_POST_DATA'] = { user: { current_password: 'password', password: 'newpassword' } }.to_json
        put :update, { id: confirmed_user.id, type: 'password' }
        response_body = JSON.parse(response.body.to_s)

        expect(response.status).to eql 200
        expect(response_body['message']).to eql I18n.t('api.users.password_updated')
      end
    end
  end
end
