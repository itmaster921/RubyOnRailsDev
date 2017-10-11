def sign_in_for_api_with(user, token: 'SECRETTOKEN')
  allow(AuthToken).to receive(:decode).with(token).and_return({id: user.id})
end
