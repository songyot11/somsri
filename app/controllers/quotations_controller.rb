class QuotationsController < ApplicationController
  load_and_authorize_resource
  def index
    quotations_filter

    @quotations = @quotations.paginate(page: params[:page], per_page: 10)

    methods = %i[student_name quotator_name grade_name total_amount paid_at
                 outstanding_balance]
    render json: {
      quotations: @quotations.as_json(methods: methods),
      current_page: @quotations.current_page,
      total_records: @quotations.total_entries
    }
  end

  private

  def quotations_filter
    start_date = params[:start_date]
    start_date = DateTime.parse(start_date).beginning_of_day if isDate(start_date)

    end_date = params[:end_date]
    end_date = DateTime.parse(end_date).end_of_day if isDate(end_date)

    data_field = Quotation.arel_table[:created_at]
    @quotations = qry_date_range(@quotations, data_field, start_date, end_date)

    keyword = params[:keyword]
    if keyword.present?
      keyword = "%#{keyword}%"
      @quotations = @quotations.where('CAST(id as text) LIKE ?', keyword)
    end
  end
end
