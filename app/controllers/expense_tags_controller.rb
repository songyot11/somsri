class ExpenseTagsController < ApplicationController
  load_and_authorize_resource

  # GET /expense_tags
  def index
    render json: ExpenseTag.search(params[:search_keyword]).as_json({
      autocomplete: params[:autocomplete].present?
    })
  end

end
