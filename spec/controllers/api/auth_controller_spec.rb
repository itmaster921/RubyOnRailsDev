require 'rails_helper'

describe API::AuthController, type: :controller do
  let(:user)         { create :user, password: 'supersecret123', password_confirmation: 'supersecret123' }
  let(:unconfirmed_user) { create :user, password: 'password', password_confirmation: 'password', confirmed_at: nil }
  let(:valid_params) do
    {
      email: user.email,
      password: 'supersecret123'
    }
  end

  describe "POST authenticate" do
    context "with valid params" do
      before do
        expect(AuthToken).to receive(:encode).with({
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          provider: user.provider,
          uid: user.uid,
          image: user.image,
          phone_number: user.phone_number,
          stripe_id: user.stripe_id,
          street_address: user.street_address,
          zipcode: user.zipcode,
          city: user.city
        }).and_return('abc123')
      end

      it "returns JSON with token and user data" do
        post :authenticate, valid_params
        response_json = JSON.parse(response.body)
        expect(response_json['auth_token']).to eql 'abc123'
      end
    end

    context "with invalid params" do
      before { valid_params[:password] = 'nopenopenope' }

      it "returns JSON with errors" do
        post :authenticate, valid_params
        expect(response.status).to eql 401
        expect(response.body).to eql({ errors: ['Invalid username or password'] }.to_json)
      end
    end

    context 'with unconfirmed user having password' do
      it 'returns JSON with auth_token' do
        post :authenticate, { email: unconfirmed_user.email, password: 'password' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eql 200
      end
    end
  end
end
