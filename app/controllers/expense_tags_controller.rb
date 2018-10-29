class ExpenseTagsController < ApplicationController
  load_and_authorize_resource

  # GET /expense_tags
  def index
    if params[:search_keyword]
      render json: ExpenseTag.search(params[:search_keyword]).order("id asc")
    else
      tree = SiteConfig.get_cache.expense_tag_tree_hash
      results = []
      tree.each do |t|
        ExpenseTag.all.each do |e|
          results << e if t[:id] == e.id
        end
      end
      render json: results
    end
  end

  # POST /expense_tags/save
  def save
    create_expenses = params[:data].select{ |d| !d[:id] && d[:name].present? }
    update_expenses = params[:data].select{ |d| d[:id] && d[:name].present? }
    new_ids = params[:data].collect{ |d| d[:id] if d[:name].present? }.compact
    old_ids = ExpenseTag.all.collect{ |d| d[:id] }

    # delete
    if ExpenseTagItem.where(expense_tag_id: (old_ids - new_ids)).count > 0
      return render json: {
        error: "Cannot delete category",
        message: I18n.t("expense_category_already_used")
      }, status: 400
    end
    ExpenseTag.where(id: (old_ids - new_ids)).destroy_all

    # update
    update_expenses.each do |d|
      ExpenseTag.where(id: d[:id]).update(name: d[:name])
    end

    # create
    create_expenses.each do |c|
      expense = ExpenseTag.create(name: c[:name])
      c[:id] = expense.id
    end

    # data to expense json setting
    site_config = SiteConfig.get_cache
    site_config.expense_tag_tree = params[:data].collect{|d| { id: d[:id], cost: 0, lv: d[:lv] } }.to_json
    site_config.save

    render json: { message: "success" }
  end

end
