require 'rails_helper'

describe AuthToken do
  describe '.encode(payload, ttl_in_minutes)' do
    let(:payload) do
      {
        user: { name: 'Thor', email: 'thors.hammer@example.com' }
      }
    end

    subject { AuthToken.encode(payload) }

    context 'with no ttl provided' do
      let (:expected_payload) { payload.merge({ exp: AuthToken::DEFAULT_TTL.minutes.from_now.to_i }) }

      it 'encodes the payload using the application secret_key_base with default ttl' do
        expect(JWT).to receive(:encode).with(expected_payload, Rails.application.secrets.secret_key_base)
        subject
      end
    end

    context 'with ttl provided' do
      let (:ttl)              { 60 }
      let (:expected_payload) { payload.merge({ exp: ttl.minutes.from_now.to_i }) }
      subject                 { AuthToken.encode(payload, ttl) }

      it 'encodes the payload using the application secret_key_base with provided ttl' do
        expect(JWT).to receive(:encode).with(expected_payload, Rails.application.secrets.secret_key_base)
        subject
      end
    end
  end
end
