class Admin::ReportsController < Admin::BaseController

  def index
    @daily_reports = Position.daily_report
  end

  def signals
    @dates = ((Time.zone.today - 7.days)..Time.zone.today).to_a
    @sources = Source.active.includes(:signals, :positions).all.map do |source|
      source.signals_by_date = source.signals.group_by {|s| s.created_at.to_s(:date) }
      source.positions_by_date = source.positions.group_by {|p| p.created_at.to_s(:date) }
      source
    end
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
