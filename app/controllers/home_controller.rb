class HomeController < ApplicationController
  authorize_resource :class => :home
  def index
  end
end
