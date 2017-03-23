class AbilitiesController < ApplicationController
  before_action :authenticate_user!
  def index
    render json: [Ability.new(current_user)], status: :ok
  end
end
