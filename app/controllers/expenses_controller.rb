class ExpensesController < ApplicationController
  load_and_authorize_resource

  # GET /expenses
  def index
    sort = params[:sort]
    order = params[:order]
    search = params[:search_keyword]
    page = params[:page]
    start_date = DateTime.parse(params[:start_date]).beginning_of_day if isDate(params[:start_date])
    end_date = DateTime.parse(params[:end_date]).end_of_day if isDate(params[:end_date])

    qry_expenses = Expense.all
    qry_expenses = qry_date_range(
    qry_expenses, Expense.arel_table[:effective_date], start_date, end_date)
    qry_expenses = qry_expenses.search(search) if search.present?
    qry_expenses = qry_expenses.order("total_cost::FLOAT #{order}") if sort == 'total_cost' && order
    qry_expenses = qry_expenses.order("#{sort} #{order}") if sort != 'total_cost' && order
    qry_expenses = qry_expenses.order("effective_date asc") if !order

    respond_to do |format|
      format.html do
      end
      format.json do
        result = {
          expenses: qry_expenses.paginate(page: page, per_page: 10),
          total_price: qry_expenses.sum(:total_cost)
        }

        if page
          result[:current_page] = result[:expenses].current_page
          result[:total_records] = result[:expenses].total_entries
        end
         render json: result, status: :ok
      end
      format.pdf do
        @results = qry_expenses.to_a
        total_all_price = 0
        @results.each do |item|
          total_all_price += item.total_cost.to_f
        end
        @total_price = total_all_price
        @start_date_time = start_date
        @end_date_time = end_date
        render pdf: "expense",
                template: "pdf/expense_report.html.erb",
                encoding: "UTF-8",
                layout: 'pdf.html',
                show_as_html: params[:show_as_html].present?
      end
    end
  end

  def show
    render json: @expense.as_json.merge({
      expense_items: @expense.expense_items,
      img: @expense.img_url.exists? ? @expense.img_url.expiring_url(10) : nil
    })
  end

  # POST /expenses
  def create
    if @expense.save
      render json: @expense, status: :ok
    else
      render json: { message: @expense.errors.full_messages }, status: :bad_request
    end
  end

  # PUT /expenses/:id
  def update
    @expense = Expense.find params[:id]
    @expense.expense_items = []
    if (expense_params[:img_url].class.to_s == "ActionDispatch::Http::UploadedFile")
      if @expense.update(expense_params)
        render json: @expense
      else
        render json: @expense.errors.full_messages, status: :bad_request
      end
    else
      @expense.update(expense_params_no_img)
    end
  end

  # DELETE /expense/1
  def destroy
    @expense.destroy
  end

  def upload_photo
     @expense = Expense.where(id: params[:id]).update( upload_photo_params )
     render json: @expense
  end

  private
  def expense_params
    params.require(:expense).permit(
      :effective_date,
      :expenses_id,
      :detail,
      :total_cost,
      :img_url,
      expense_items_attributes: [:detail, :amount, :cost,
        tags: [:text]
      ]
    )
  end

  def expense_params_no_img
    params.require(:expense).permit(
      :effective_date,
      :expenses_id,
      :detail,
      :total_cost,
      expense_items_attributes: [:detail, :amount, :cost,
        tags: [:text]
      ]
    )
  end

  def upload_photo_params
    params.require(:expense).permit(:img_url)
  end

end
