class AlumnisController < ApplicationController
  load_and_authorize_resource
  def index
    alumnis = Alumni.all
    alumnis = alumnis.where(graduated_year: params[:year]) if params[:year] && params[:year] != "ทั้งหมด"
    alumnis = alumnis.where(status: params[:status]) if params[:status] && params[:status] != "ทั้งหมด"
    alumnis = alumnis.order("#{params[:sort]} #{params[:order]}") if params[:sort]
    alumnis = alumnis.search(params[:search]) if params[:search]
    if params[:limit] && params[:offset]
      per_page = params[:limit].to_i
      page = (params[:offset].to_i/per_page) + 1
      alumnis = alumnis.paginate(page: page, per_page: per_page)
    end
    render json: {
      rows: alumnis.as_json({ index: true }),
      total: alumnis.count
      }, status: :ok
  end

  #POST /alumnis/years
  def years
    alumnis = Alumni.select(:graduated_year).distinct
    render json: alumnis.as_json({ years: true }), status: :ok
  end

  #POST /alumnis/status
  def status
    alumnis = Alumni.select(:status).distinct
    render json: alumnis.as_json({ status: true }), status: :ok
  end
end
