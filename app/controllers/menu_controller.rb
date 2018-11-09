class MenuController < ApplicationController
  authorize_resource :class => :menu

  def index
    params[:locale] = "en"
  end

  def landing_payroll
    authorize! :manage, Payroll
    render "menu/angular_view", layout: "application_payroll"
  end

  def landing_invoice
    authorize! :manage, Invoice
    render "menu/angular_view", layout: "application_invoice"
  end

  def landing_rollcall
    render "menu/angular_view", layout: "application_rollcall"
  end

  def landing_main
    render "menu/angular_view", layout: "application_main"
  end

  def landing_somsri
    render "menu/angular_view", layout: "application_somsri"
  end

end
