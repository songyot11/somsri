class BanksController < ApplicationController
  load_and_authorize_resource

  def index
    render json: {
      banks: @banks
    }, status: :ok
  end

  def create
    @bank = Bank.new(params_bank)
    if @bank.save
      redirect_to banks_path
    else
      render json: @bank.error , status: 500
    end
  end

  private
  def params_bank
    params.require(:params).permit(:bank_name, :bank_account, :account_name)
  end
end
