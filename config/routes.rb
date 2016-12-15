Rails.application.routes.draw do
  # devise_for :users
  #
  # unauthenticated :user do
  #   devise_scope :user do
  #     get "/" => "devise/sessions#new"
  #   end
  # end

  get "/" => "home#index"
  resources :reports, only: :index do
    collection do
      get 'payroll', path: "/:year/:month"
      get 'months'
    end
  end
end
