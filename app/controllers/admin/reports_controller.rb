class Admin::ReportsController < Admin::BaseController

  def index
    @daily_reports = Position.daily_report
  end

  def signals
    @sources = Source.active.includes(:signals, :positions).all
  end

  def balance
    # gon.push(
    #   account: true
    # )
    
    info = service.info
    balance = info["accounts"].first["balance"]

    @balance = {
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
