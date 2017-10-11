require 'sidekiq/web'

Rails.application.routes.draw do

  get 'venues/:id/view' => 'venues#view', as: :venue_view
  post 'venues/:id/available' => 'venues#available', as: :venue_available
  get 'venues/:id/make_reservation' => 'venues#make_reservation',
      as: :venue_make_reservationget
  post 'venues/:id/make_reservation' => 'venues#make_reservation',
       as: :venue_make_reservation

  get 'venues/:id/make_unpaid_reservation' => 'venues#make_unpaid_reservation',
      as: :venue_make_unpaid_reservationget
  post 'venues/:id/make_unpaid_reservation' => 'venues#make_unpaid_reservation',
       as: :venue_make_unpaid_reservation

  get 'venues/:id/court_price_at' => 'venues#court_price_at',
      as: :court_price_at
  get 'venues/:id/manage_venue' => 'venues#courts_and_prices',
      as: :courts_and_prices

  post '/search' => 'pages#search', as: :search
  get '/search' => 'pages#search', as: :searchget

  get "search_venues" => "search#show", as: :search_venues
  get 'venues/:id/cancelled_reservations' => 'venues#cancelled_reservations', as: :venue_cancelled_reservations



  get 'venues/:id/memberships' => 'venues#memberships', as: :memberships

  get 'users/:id/invoices' => 'users#invoices', as: :user_invoices

  root 'pages#home'

  get '/search' => 'pages#search'
  post '/search' => 'pages#search'

  namespace :api do
    post 'authenticate' => 'auth#authenticate'
    get "sort_by_sport" => "venues#sort_by_sport"
    resources :users, only: [:create, :update] do
      get 'game_pass_check'

      collection do
        post :confirm_account
        post :reset_password
        get :email_check
      end
    end
    resources :companies, only: [] do
      post 'send_support_email'
    end
    get 'search' => 'venues#search'
    get 'all_sport_names' => 'venues#all_sport_names'
    resources :cards, only: [:create, :index]
    resources :reservations, only: [:create, :index, :destroy]
    resources :subscriptions, only: [:index]
    resources :venues, only: [:show, :index] do
      get 'users'
      get 'utilization_rate'
      get 'available_courts'
    end
    resources :game_passes, only: [:index, :show, :create, :update, :destroy] do
      collection do
        get :court_sports
        get :court_types
        get :templates
        get :available
      end
    end

    resources :customers, only: [:index, :show, :create, :update, :destroy]
  end

  post '/connect/managed' => 'stripe#managed', as: 'stripe_managed'

  devise_for :admins,
             controllers: { confirmations: 'confirmations' }

  devise_for  :users,
              path: '',
              path_names: { sign_in: 'login',
                            sign_out: 'logout',
                            edit: 'profile' },
              controllers: { omniauth_callbacks: 'omniauth_callbacks',
                             registrations: 'registrations',
                             confirmations: 'confirmations' }

  devise_scope :user do
    patch '/users/confirm' => 'confirmations#confirm',
          as: :user_confirm
    patch 'users/update_password' => 'registrations#update_password'
  end

  devise_scope :admin do
    patch '/admins/confirm' => 'confirmations#confirm',
          as: :admin_confirm
    authenticate :admin, lambda { |admin| admin.god? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  resources :users, only: [:show] do
    post 'add_card' => 'stripe#add_card', as: :add_card
    post 'card_reminder'
    post 'assign_discount', as: :assign_discount
    get  'recurring_reservations', on: :member
  end

  resources :companies do
    resources :admins, expect: [:new, :show]
    get :reports
    post :create_report
    get :report
    resources :invoices do
      collection do
        post :create_drafts
        post :send_all
        post :mark_paid
        post :destroy_all
        post :create_report
      end
    end
    get 'revenue' => 'dashboard#revenue', as: :revenue
    get 'resv' => 'dashboard#resv'
    member do
      post 'import_customers'
      get  'customers_csv_template'
    end
  end
  resources :invoices, only: [:show] do
    resources :invoice_components
    resources :custom_invoice_components
  end

  get 'companies/:id/customers' => 'companies#customers', as: :company_customers
  get 'venues/:id/map_users' => 'venues#map_users', as: :map_users

  resources :memberships, only: [:create] do
    collection do
      post :import
      get :csv_template
    end
  end

  resources :venues do
    resources :game_passes
    resources :prices, except: [:index, :new, :edit] do
      member do
        post :merge_conflicts
      end
    end
    resources :courts do
    end
    resources :reservations do
      get 'new_cart', on: :collection
      get  'resell_to_user_form', on: :member
      post 'resell_to_user', on: :member
    end
    resources :memberships, except: [:new, :edit, :update]
    get 'memberships/:id/convert_to_cc' => 'memberships#convert_to_cc', as: :convert_to_cc
    post 'memberships/:id' => 'memberships#update'
    get 'offdays'
    resources :day_off, only: [:create, :destroy]
    get 'court_modal/:id' => 'venues#court_modal', as: :court_modal
    get 'price_modal/:id' => 'venues#price_modal', as: :price_modal
    get 'closing_hours'
    get 'booking_ahead_limit'
    get 'active_courts'
    post 'change_listed' => 'venues#change_listed', as: :change_listed
    member do
      get 'reports'
      post 'booking_sales_report'
      get 'available_court_indexes'
    end
    resources :discounts, except: [:new]
    get 'manage_discounts', as: :manage_discounts
    get 'edit_emails'
    post 'update_emails'
    resources :photos, only: [:create, :destroy] do
      post 'make_primary'
    end
    resources :email_lists do
      post 'remove_users'
      post 'add_users'
      get 'off_list_users'
    end
  end

  post '/custom_mail(.:format)' => 'email_lists#custom_mail'
  get 'reservations/:id/cancel' => 'reservations#refund', as: :reservation_refund
  get 'reservations/:id/cancel_reservation' => 'reservations#cancel', as: :reservation_cancel
  get 'reservations/:id/resell' => 'reservations#resell', as: :reservation_resell
  get 'reservations/:id/show_log' => 'reservations#show_log', as: :reservation_show_log
  get '/privacypolicy', :to => redirect('/privacypolicy.html')
  get '/termsofuse', :to => redirect('/termsofuse.html')
end
