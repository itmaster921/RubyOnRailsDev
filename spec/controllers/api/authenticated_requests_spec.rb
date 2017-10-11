require 'rails_helper'

class API::FakeResourcesController < API::BaseController
  before_action :authenticate_request!

  def index
    render json: {}, status: :ok
  end
end

UNAUTHORIZED_JSON_RESPONSE = {errors: [I18n.t('api.authentication.unauthorized')]}.to_json
TIMEOUT_JSON_RESPONSE      = {errors: [I18n.t('api.authentication.timeout')]}.to_json

describe API::FakeResourcesController, type: :controller do
  let!(:user)      { create :user }
  let(:auth_token) { 'superawesometoken' }

  before do
    Rails.application.routes.draw do
      namespace :api do
        get 'fake_resources' => 'fake_resources#index'
      end
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context 'with authenticated requests' do
    subject { get :index }
    before  { request.headers.merge!({ "Authorization" => "Bearer #{auth_token}" }) }

    context 'using a valid auth token' do
      before { allow(AuthToken).to receive(:decode).and_return({ id: user.id }) }

      it "stores the current user" do
        subject
        expect(response.status).to eql 200
        expect(assigns(:current_user)).to eql user
      end

      context 'but no user exists with the decoded user_id' do
        before { user.destroy }
        it "returns JSON with an unauthorized error message" do
          subject
          expect(response.status).to eql 401
          expect(response.body).to eql(UNAUTHORIZED_JSON_RESPONSE)
        end
      end
    end

    context 'using an expired token' do
      before { allow(AuthToken).to receive(:decode).and_raise(JWT::ExpiredSignature.new) }
      it "returns JSON with an auth timeout error message" do
        subject
          expect(response.status).to eql 419
        expect(response.body).to eql(TIMEOUT_JSON_RESPONSE)
      end
    end

    context 'using a token that cannot be claimed yet' do
      before { allow(AuthToken).to receive(:decode).and_raise(JWT::ImmatureSignature.new) }
      it "returns JSON with an auth timeout error message" do
        subject
        expect(response.status).to eql 419
        expect(response.body).to eql(TIMEOUT_JSON_RESPONSE)
      end
    end

    context 'and fails to validate the token' do
      before { allow(AuthToken).to receive(:decode).and_raise(JWT::VerificationError.new) }
      it "returns JSON with an unauthorized error message" do
        subject
        expect(response.status).to eql 401
        expect(response.body).to eql(UNAUTHORIZED_JSON_RESPONSE)
      end
    end

    context 'and fails to decode the token' do
      before { allow(AuthToken).to receive(:decode).and_raise(JWT::DecodeError.new) }
      it "returns JSON with an unauthorized error message" do
        subject
        expect(response.status).to eql 401
        expect(response.body).to eql(UNAUTHORIZED_JSON_RESPONSE)
      end
    end

    context 'with no Authorization request header' do
      before { request.headers.merge!({'Authorization' => ''}) }
      it "returns JSON with an unauthorized error message" do
        subject
        expect(response.status).to eql 401
        expect(response.body).to eql(UNAUTHORIZED_JSON_RESPONSE)
      end
    end
  end
end
