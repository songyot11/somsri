class BanksController < ApplicationController
  load_and_authorize_resource

  def index
    banks = []
    @banks.each do |bank|
      banks << {
        bank_name: bank.bank_name,
        bank_account: bank.bank_account,
        account_name: bank.account_name,
        image: bank&.lt_bank.image&.url(:thumb)
      }
    end
    
    render json: {
      banks: banks,
      lt_banks: LtBank.all
    }, status: :ok
  end

  def create
    @bank = Bank.new(params_bank)
    @bank[:bank_name] = LtBank.find_by_id(params[:params][:bank_id])[:name]
    if @bank.save
      redirect_to banks_path
    else
      render json: @bank.error , status: 500
    end
  end

  private
  def params_bank
    params.require(:params).permit(:bank_name, :bank_id, :bank_account, :account_name)
  end
end
