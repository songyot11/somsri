class ReportController < ApplicationController
  # GET /reports
  def index
    data = datas = [
      {
        month: 1,
        name: "มกราคม",
        year: "2016",
        employees: [
          {
            code: "0001",
            name: "pond",
            accountNumber: "11111111",
            salary: 50000,
            extraFee: 100,
            extraPay: 1000, 
          },
          {
            code: "0002",
            name: "pon2",
            accountNumber: "111111111",
            salary: 50000,
            extraFee: 100,
            extraPay: 1200, 
          }
        ]
      },
      {
        month: 2,
        name: "กุมพาพันธ์",
        year: "2016",
        employees: [
          {
            code: "0001",
            name: "pond",
            accountNumber: "11111111",
            salary: 500000,
            extraFee: 1000,
            extraPay: 10000, 
          },
          {
            code: "0002",
            name: "pon2",
            accountNumber: "111111111",
            salary: 500000,
            extraFee: 1000,
            extraPay: 12000, 
          }
        ]
      },
    ]

    render json: data
  end
end
