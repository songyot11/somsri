Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :skip => [:registrations]
  # devise_for :employees, path: 'employees', :skip => [:registrations]

  get 'changelog', to: 'home#changelog'
  get "/menu" => "menu#index"
  get "/somsri_invoice" => "menu#landing_invoice"
  get "/somsri_payroll" => "menu#landing_payroll"
  get "/somsri_rollcall" => "menu#landing_rollcall" 
  get "/somsri" => "menu#landing_somsri"
  get "/main" => "menu#landing_main"
  get "/language" => "home#language"
  get "/locale" => "home#locale"
  get 'holiday.ics' => 'holidays#share'

  resources :users, only: [] do
    collection do
      get "me"
      get "site_config"
    end
  end

  resources :users, only: [] do
    collection do
      get "me"
      get "role_employees"
      get "site_config"
    end
  end

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

  resources :expenses, only: [:index, :create, :destroy, :show, :update] do
    member do
      patch 'upload_photo'
    end
    collection do
      get "check_setting"
      get "report_by_tag"
      get "report_by_payment"
    end
  end
  resources :expense_tags, only: [:index] do
    collection do
      post 'save'
    end
  end
  resources :skills, only: [:index, :create]
  resources :employees, only: [:index, :create, :show, :update, :destroy]  do
    resources :employee_skills, except: %i[show new edit]

    collection do
      get 'me'
      get 'slips'
      post 'create_by_name'
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

  resources :site_configs, only: [:index]
  resources :vacation_settings
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
    collection do
      get 'get_autocomplete'
    end
    member do
      patch 'upload_photo'
    end
  end
  resources :grades
  resources :classrooms do
    collection do
      get 'classroom_list'
      patch 'student_promote'
    end
    member do
      get 'teacher_list'
      get 'student_list'
      patch 'update_list'
      get 'teacher_without_classroom'
      get 'student_without_classroom'
    end
  end
  resources :daily_reports
  resources :students do
    delete 'real_destroy'
    delete 'destroy'
    member do
      post 'resign'
      post 'graduate'
      patch 'upload_photo'
    end
    collection do
      post 'restore'
      post 'create_by_name'
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

  resources :alumnis do
    collection do
      get 'years'
      get 'status'
    end
  end

  resources :quotations do
    member do
      get "bill"
    end
  end

  resources :banks
  resources :vacations, only: [:index, :create, :destroy] do
    collection do
      get 'dashboard'
    end
    member do
      get 'approve'
      get 'reject'
    end
  end

  resources :vacation_configs, only: [:index] do
  end

  resources :vacation_leave_rules, only: [:index, :update] do
  end

  resources :holidays, only: [:index, :create, :destroy] do
  end

  devise_scope :user do
    get "/sign_in" => "devise/sessions#new"
  end
  comfy_route :cms, :path => '/homepage', :sitemap => false
  comfy_route :cms_admin, :path => '/cms_admin'
  root to: 'home#index'

  resources :inventories do
    resources :categories
  end

  resources :inventory_requests do
    collection do
    end

    member do
      put 'approve'
      put 'reject'
      put 'pending'
      put 'accept'
      put 'purchasing'
      put 'done'
      put 'assigned'
      put 'delete_inventory'
      put 'wait'
      put 'repair'
    end

    # POST: /inventories_requests/:inventories_request_id/manage_inventories_requests
    resources :manage_inventories_requests
  end

  resources :suppliers

  resources :inventory_repairs do 
    collection do
    end
    # [:repair_notification, :confirm_accept, :rejected ,:sent_repair, :repairs_completed, :dispatch_to_employees]
    member do
      put 'repair_notification'
      put 'confirm_accept'  
      put 'rejected'
      put 'sent_repair'
      put 'repairs_completed'
      put 'dispatch_to_employees'
    end

    # POST: /inventories_repairs/:inventories_repair_id/manage_inventory_repair
    resources :manage_inventory_repairs
  end

  resources :candidates 
end
