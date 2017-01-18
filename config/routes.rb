Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]

  unauthenticated :user do
    devise_scope :user do
      get "/" => "devise/sessions#new"
    end
  end

  get "/" => "home#index"

  resources :payrolls, only: [:index, :update] do
    collection do
      get "/:year/:month", action: 'payroll'
      get 'social_insurance_pdf'
    end
  end

  resources :settings, only: [:index] do
    collection do
      patch "/", action: 'update_current_user'
      patch 'update_password'
    end
  end

  resources :employees, only: [:index, :create, :show, :update, :destroy]  do
    member do
      get 'slip'
      get 'payrolls'
    end
  end
end
