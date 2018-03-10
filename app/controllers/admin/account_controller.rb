class Admin::AccountController < Admin::BaseController

  def root
    gon.push(
      account: true
    )
  end

  def balance
    info = service.info
    balance = info["accounts"].first["balance"]

    render json: {
      available: balance["available"],
      margin: balance["deposit"],
      profit_loss: balance["profitLoss"]
    }
  end

  private

    def service
      @service ||= IG::Service::Account.new
    end

end
