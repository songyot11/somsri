class ReportsController < ApplicationController
  # GET /reports
  def index
  end

  # GET /reports/months
  def months
    data = [
      {
        month: 1, 
        name: "มกราคม",
        year: "2016",
      },
      {
        month: 2, 
        name: "กุมภาพันธ์",
        year: "2016",
      }
    ]

    render json: data, status: :ok
  end

  # GET /reports/:year/:month
  def payroll
    year = params[:year].to_i
    month = params[:month].to_i

    if month == 1
      data = [
        {
          code: "0001",
          prefix: "Mr.",
          name: "Theeraphat Jantakat",
          account_number: "1111111111",
          salary: 50000,
          extra_fee: 2000,
          extra_pay: 5000,
        },
        {
          code: "0002",
          prefix: "Mr.",
          name: "Theeraphat2 Jantakat",
          account_number: "22222222",
          salary: 100000,
          extra_fee: 8000,
          extra_pay: 10000,
        },
      ]
    else 
      data = [
        {
          code: "0001",
          prefix: "Mr.",
          name: "Theeraphat Jantakat",
          account_number: "1111111111",
          salary: 1000000,
          extra_fee: 0,
          extra_pay: 5000,
        },
        {
          code: "0002",
          prefix: "Mr.",
          name: "Theeraphat2 Jantakat",
          account_number: "22222222",
          salary: 1000000,
          extra_fee: 0,
          extra_pay: 10000,
        },
      ]
    end

    render json: data, status: :ok
  end
end
