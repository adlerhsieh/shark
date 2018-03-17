class Admin::ReportsController < Admin::BaseController

  def index
    @daily = Position
      .select("created_at, count(*) as count, sum(pl) as pl")
      .group("date(created_at)")
      .order("created_at desc")
      .all
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
