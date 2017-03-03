class MenuController < ApplicationController
  def index
  end

  def landing_payroll
    render "menu/angular_view", layout: "application_payroll"
  end

  def landing_invoice
    render "menu/angular_view", layout: "application_invoice"
  end
end
