Rails.application.routes.draw do
  devise_for :users

  unauthenticated :user do
    devise_scope :user do
      get "/" => "devise/sessions#new"
    end
  end

  get "/" => "home#index"
end
