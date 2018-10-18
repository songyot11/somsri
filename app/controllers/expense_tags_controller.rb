class ExpenseTagsController < ApplicationController
  load_and_authorize_resource

  # GET /expense_tags
  def index
    render json: ExpenseTag.search(params[:search_keyword]).order("id asc")
  end

end
