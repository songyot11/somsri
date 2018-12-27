class AbilitiesController < ApplicationController
  before_action :authenticate_authorizer!

  def index
    render json: [Ability.new(current_authorizer)], status: :ok
  end
end
