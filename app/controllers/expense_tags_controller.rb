class ExpenseTagsController < ApplicationController
  load_and_authorize_resource

  # GET /expense_tags
  def index
    render json: ExpenseTag.search(params[:search_keyword]).order("id asc").as_json({
      autocomplete: params[:autocomplete].present?
    })
  end

  # POST /expense_tags
  def create
    old_ids = ExpenseTag.pluck(:id)
    input_ids = params[:data].collect { |data| data[:id] }
    input_ids.compact!

    # delete
    delete_ids = old_ids - input_ids
    ExpenseTag.where(id: delete_ids).destroy_all

    params[:data].each do |data|
      if data[:id].blank? && data[:name].present?
        # craete
        ExpenseTag.create(name: data[:name], description: data[:description])
      elsif data[:id].present? && data[:name].present?
        # update
        ExpenseTag.where(id: data[:id]).update(
          name: data[:name], description: data[:description]
        )
      end
    end
    render json: ExpenseTag.all.order("id asc")
  end

end
