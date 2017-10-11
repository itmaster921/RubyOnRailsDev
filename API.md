# API Documentation

This page includes our API documentation and styleguide on how to write your API documentation.

Please pay attention to how you write it as it will be vital for others working to clearly understand how it works. 
Especially in cases where the other person might be a frontend developer with no knowledge of our backend.

## Table of Contents
  1. [Style Guide](#style-guide)
  1. [Authentication](#authentication)
    1. [Login API](#login-api)
    1. [Register API](#register-api)
    1. [Update Profile API](#update-profile-api)
    1. [Reset Password API](#reset-password-api)
    1. [Confirm Account API](#confirm-account-api)
    1. [Email Check API](#email-check-api)
  1. [Customers](#customers)
    1. [Index API](#customers-index)
    1. [Show API](#customers-show)
    1. [Create API](#customers-create)
    1. [Update API](#customers-update)
    1. [Delete API](#customers-delete)

# Style Guide

When creating API Documentation for your API Endpoint it should include the following things:

* URL for the Endpoint
* Method of Endpoint (POST/PUT/GET/DELETE)/PATCH)
* Request Body
* Success Response
* Error Response including status code and content and causes for these

Abiding these simple rules will keep our API Documentation clean and easy to use for everyone.

Yay!

# Authentication

Listed below are Authentication related API endpoints

# Login API
  Returns json data.

* **URL**

  /api/authenticate?email={email_ID}&password={UserPassword}

* **Method:**

  `POST`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ auth_token: "ENCODED_AUTH_TOKEN" }`

* **Error Response:**

  If username or password are incorrect:

  * **Code:** 403 UNAUTHORIZED <br />
    **Content:** `{ error : 'Invalid username or password' }`

  OR

  If user is not confirmed and password is blank:

  * **Code:** 422 <br />
    **Content:** `{ error: 'unconfirmed_account', message: 'User is already created but not confirmed' }`


# Register API
  Returns json data.

* **URL**

  /api/users

* **Method:**

  `POST`

*  **Request Body**

```
{
  "user": {
    "email": "allama.iqbal@gmail.com",
    "password": "SECRET_KEY",
    "password_confirmation": "SECRET_KEY",
    "first_name": "Allama",
    "last_name": "Iqbal",
    "phone_number": "00923366521421",
    "street_address": "15",
    "zipcode": 56000,
    "city": "Islamabad"
  }
}
```

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ auth_token: "ENCODED_AUTH_TOKEN" }`

* **Error Response:**

  If user is not confirmed and password is blank:

  * **Code:** 422 <br />
    **Content:** `{ error: 'unconfirmed_account', message: 'User is already created but not confirmed' }`

  OR

  If user is not confirmed and password is present:

  * **Code:** 422 <br />
    **Content:** `{ error: 'already_exists', message: 'Email already exists' }`


# Update Profile API
  Returns json data.

* **URL**

  /api/users/{user_id}

* **Method:**

  `PUT`

*  **Request Body**

  ```
  { "user":
    {"email": "test@gmail.com",
    "first_name": "Test1",
    "last_name": "Test1",
    "phone_number": "00923366521421",
    "street_address": "15",
    "zipcode": 56000,
    "city": "Lahore" }
  }
  ```

* **Success Response:**

  if password and current_password are provided in the request body:

  * **Code:** 200 <br />
    **Content:** `{ message: "Password updated successfully" }`

  OR

  if password and current_password are not provided in the request body:

  * **Code:** 200 <br />
    **Content:** `{ message: "User profile updated successfully" }`

* **Error Response:**

  if `current_password` is incorrect:

  * **Code:** 422 <br />
    **Content:** `{ error : "Current password is not valid" }`

  if `password` length is short:

  * **Code:** 422 <br />
    **Content:** `{ error : "Password is too short" }`

  OR

  * **Code:** 401 UNAUTHORIZED <br />
    **Content:** `{ error : "You are not currently logged in." }`


# Reset Password API
Returns json data.

* **URL**

  /api/users/reset_password?email={email_ID}

* **Method:**

  `POST`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ message: "Reset password email sent successfully" }`

* **Error Response:**

  * **Code:** 404 <br />
    **Content:** `{ error : user.errors.full_messages.join(', ') }`


# Confirm Account API
Returns json data.

* **URL**

  /api/users/confirm_account

* **Method:**

  `POST`

*  **Request Body**

```
{
  "user": {
    "email": "test@test.com"
  }
}
```

* **Success Response:**

  * **Code:** 200 <br />
    **Content:** `{ message: "Confirmation email sent successfully" }`

* **Error Response:**

  * **Code:** 422 <br />
    **Content:** `{ error : "Email parameter is required" }`

  OR

  * **Code:** 422 <br />
    **Content:** `{ error : "Confirmation email could not be sent" }`

# Email Check API

End point for Mobile Devices in Login to check if there is an user with given email address. Returns a json message.

## URL

```
  /api/users/email_check
```

## Method

`GET`

## Request Body
```
  {
    "email": "check@email.com"
  }
```

## Success Response

* Code 200
* Content `{ message: "Account found with given email" }`

## Error Response

With an invalid email param or no user account found

* Code 422
* Content `{ message: "No account found with given email" }`

With no email given

* Code 422
* Content `{ message: "Email parameter is required" }`


# Customers

Listed below are Customers CRUD API endpoints.<br />
This API requires authenticated admin and created venue.


## Index API

Returns json data.<br />
Accepts optional parameters: `search, page, per_page`<br />
`page` defaults to `1`<br />
`per_page` defaults to `10`<br />
`seartch` defaults to `''`<br />

* **URL**

  /api/customers?search={query}&page=2&per_page=10

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:**

```
    {
      customers: [
        {
          id:                   17,
          first_name:           'name',
          last_name:            'lastname',
          email:                'example@mail.test',
          phone_number:         '1123456789',
          city:                 'Boston',
          street_address:       'Some address 4',
          zipcode:              '12345',
          outstanding_balance:  13.3,
          reservations_done:    25,
          last_reservation:     '25/10/2016',
          lifetime_value:       276.4,
        },
        ...
      ]
    }
```

* **Error Response:**

  If venue not created:

  * **Code:** 422 <br />
    **Content:** `{ errors: ["Company doesn't have any venue yet"] }`


## Show API
  Returns json data.

* **URL**

  /api/customers/3

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 <br />
    **Content:**

```
    {
      id:                   17,
      first_name:           'name',
      last_name:            'lastname',
      email:                'example@mail.test',
      phone_number:         '1123456789',
      city:                 'Boston',
      street_address:       'Some address 4',
      zipcode:              '12345',
      outstanding_balance:  13.5,
      reservations_done:    7,
      last_reservation:     '25/10/2016',
      lifetime_value:       134.1,
    }
```

* **Error Response:**
  If venue not created:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Company doesn't have any venue yet"] }`

  If customer not found:
  * **Code:** 404 <br />
    **Content:** `{ errors: ["Customer not found"] }`


## Create API
  Returns json data.

* **URL**

  /api/customers

* **Method:**

  `POST`

*  **Request Body**

```
  {
    "customer": {
      first_name:           'new user name',
      last_name:            'lastname',
      email:                'example@mail.test',
      phone_number:         '1123456789',
      city:                 'Boston',
      street_address:       'Some address 4',
      zipcode:              '12345',
    }
  }
```

* **Success Response:**

  * **Code:** 200 <br />
    **Content:**

```
    {
      id:                   17,
      first_name:           'new user name',
      last_name:            'lastname',
      email:                'example@mail.test',
      phone_number:         '1123456789',
      city:                 'Boston',
      street_address:       'Some address 4',
      zipcode:              '12345',
      outstanding_balance:  0,
      reservations:         []
    }
```

* **Error Response:**
  If venue not created:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Company doesn't have any venue yet"] }`

  If validation errors:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["First name can't be blank", ...] }`


## Update API
  Returns json data.

* **URL**

  /api/customers/3

* **Method:**

  `PUT`

*  **Request Body**

```
  {
    "customer": {
      first_name:           'new user name',
      last_name:            'lastname',
      email:                'example@mail.test',
      phone_number:         '1123456789',
      city:                 'Boston',
      street_address:       'Some address 4',
      zipcode:              '12345',
    }
  }
```

* **Success Response:**

  * **Code:** 200 <br />
    **No content**

* **Error Response:**
  If customer not found:
  * **Code:** 404 <br />
    **Content:** `{ errors: ["Customer not found"] }`

  If customer already confirmed:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Can't modify already confirmed customer"] }`

  If venue not created:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Company doesn't have any venue yet"] }`

  If validation errors:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["First name cant be blank", ...] }`


## Delete API
  Returns json data.

* **URL**

  /api/customers/3

* **Method:**

  `DELETE`

* **Success Response:**

  * **Code:** 200 <br />
    **No content**

* **Error Response:**
  If customer not found:
  * **Code:** 404 <br />
    **Content:** `{ errors: ["Customer not found"] }`

  If customer already confirmed:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Can't modify already confirmed customer"] }`

  If venue not created:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Company doesn't have any venue yet"] }`

  If customer related to other company:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Can't modify customer with relation to other companies"] }`

  If failed to delete:
  * **Code:** 422 <br />
    **Content:** `{ errors: ["Can't delete customer"] }`
