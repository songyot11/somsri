Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :skip => [:registrations]

  get 'changelog', to: 'home#changelog'
  get "/menu" => "menu#index"
  get "/somsri_invoice" => "menu#landing_invoice"
  get "/somsri_payroll" => "menu#landing_payroll"
  get "/somsri_rollcall" => "menu#landing_rollcall"
  get "/main" => "menu#landing_main"

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
    post 'archive'
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
    post 'archive'
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
    end
  end
  get '/student_report' => "students#student_report"
  get "/invoice_years" => "invoices#invoice_years"
  get "/invoice_semesters" => "invoices#invoice_semesters"
  get "/invoice_grouping" => "invoices#invoice_grouping"

  resources :report_roll_calls, only: [] do
    collection do
      get 'report'
      get 'date_in_month'
      get 'lists'
      get 'months'
    end
  end

  devise_scope :user do
    get "/sign_in" => "devise/sessions#new"
  end
  comfy_route :cms, :path => '/homepage', :sitemap => false
  comfy_route :cms_admin, :path => '/cms_admin'
  root to: 'home#index'
end
