Rails.application.routes.draw do
  devise_for :users, :skip => [:passwords, :registrations]

  # unauthenticated :user do
  #   devise_scope :user do
  #     get "/" => "devise/sessions#new"
  #   end
  # end

  get "/" => "home#index"
  resources :reports, only: [:index, :update] do
    collection do
      get 'payroll', path: "/:year/:month"
    end
  end

  resources :employees, only: [:index, :create, :show, :update, :destroy]  do
    member do
      get 'slip'
      get 'payrolls'
    end
  end
end
