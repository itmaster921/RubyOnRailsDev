# Default initializers for all tests


Geocoder.configure(:lookup => :test)
Geocoder::Lookup::Test.set_default_stub (
  [
    {
      'latitude'     => 60.175405,
      'longitude'    => 24.914562,
      'address'      => 'Mannerheimintie 5, Helsinki, 00100',
      'state'        => 'Helsinki',
      'state_code'   => 'HL',
      'country'      => 'Finland',
      'country_code' => 'FI'
    }
  ]
)
