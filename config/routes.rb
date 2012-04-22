OrgSite::Application.routes.draw do

  resources :tags

  match '/calendar(/:year(/:month))' => 'calendar#index', :as => :calendar, :constraints => {:year => /\d{4}/, :month => /\d{1,2}/}

  resources :dashboards

  resources :posts

  resources :events

  resources :lists
  
  resources :items

  resources :reminders

  resources :users do
  	resources :reminders
  	resources :lists
    resources :events do
      member do
        get :invite, :confirm, :decline
      end
    end
    resources :tags

    member do
      get :following, :followers, :dashboard, :add_friend, :statistics, :confirm, :edit_permissions, :ban, :unban, :retrieve_password
      put :permissions_update, :send_password
    end
  end
  
  resources :sessions, :only => [:new, :create, :destroy]
  resources :relationships, :only => [:create, :destroy, :update]
  
  match '/signup',  :to => 'users#new'
  match '/password_recovery', :to => 'users#retrieve_password'
  match '/recover', :to => 'users#send_password'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  match '/dashboard'           => 'users#dashboard',            :as => :dashboard,      :via => "get"
  match '/profile'             => 'users#show',                 :as => :user_profile,   :via => "get"
  match 'reminder/destroy'     => 'reminders#destroy_reminder', :as => :destroy
  match 'list/destroy'         => 'lists#destroy_list',         :as => :destroy
  match 'item/destroy'         => 'items#destroy_item',         :as => :destroy
  match '/events/:id/delete'   => 'events#destroy_event',       :as => :delete_event
  match '/events/:id/confirm'  => 'events#confirm_event',       :as => :confirm_event
  match '/posts/:id/delete'    => 'posts#destroy_post',         :as => :delete_post
  match '/users/:name/events'  => 'events#index',               :as => :display_events, :via => "get"
  match 'user/destroy'         => 'users#destroy_user',         :as => :destroy


  root :to => 'users#dashboard'


end
