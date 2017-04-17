Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :skip => [:registrations]

  unauthenticated :user do
    devise_scope :user do
      get "/" => "devise/sessions#new"
    end
  end

  get "/" => "home#index"
  root to: 'home#index'
  get 'changelog', to: 'home#changelog'
  get "/menu" => "menu#index"
  get "/somsri_invoice" => "menu#landing_invoice"
  get "/somsri_payroll" => "menu#landing_payroll"
  get "/somsri_rollcall" => "menu#landing_rollcall"

  resources :payrolls, only: [:index, :update, :create] do
    collection do
      get "effective_dates"
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
    collection do
      get 'slips'
    end
    member do
      get 'slip'
      get 'payrolls'
      get 'calculate_deduction'
      patch 'upload_photo'
    end
    post 'restore'
    delete 'real_destroy'
  end

  resources :individuals, only: [:create, :update, :destroy, :index]


  resources :invoices do
    member do
      get "slip"
      patch "cancel"
    end
  end

  resources :parents do
    post 'restore'
    delete 'real_destroy'
    member do
      patch 'upload_photo'
    end
  end
  resources :grades
  resources :daily_reports
  resources :students do
    delete 'real_destroy'
    post 'restore'
    post 'graduate'
    post 'resign'
    member do
      patch 'upload_photo'
    end
  end
  resources :abilities, only: [:index]
  get "/auth_api" => "home#auth_api"
  get "/report" => "roll_calls#report"
  get "/report_month" => "roll_calls#report_month"
  get "/info" =>"students#info"
  resources :roll_calls, only: [:create, :index]
  resources :students, only: [:index, :show] do
    collection do
      get 'get_roll_calls'
      # get 'invoice_total_amount'
    end
  end
  get "/invoice_total_amount" => "students#invoice_total_amount"

  resources :report_roll_calls, only: [] do
    collection do
      get 'report'
      get 'date_in_month'
      get 'lists'
      get 'months'
    end
  end

end
