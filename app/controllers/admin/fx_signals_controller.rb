class Admin::FxSignalsController < Admin::BaseController
  before_action :load_fx_signal, only: %i[show edit update destroy]

  def index
    @signals = FxSignal.includes(:pair).all.order(created_at: :desc)
  end

  def show
    
  end

  def new
    @fx_signal = FxSignal.new
  end

  def create
    FxSignal.create(fx_signal_params)
    redirect_to admin_fx_signals_path
  end

  def edit
    
  end

  def update
    @fx_signal.update(fx_signal_params)
    redirect_to admin_fx_signals_path
  end

  def destroy
    @fx_signal.destroy
    redirect_to admin_fx_signals_path
  end

  private

    def load_fx_signal
      @fx_signal = FxSignal.find(params[:id])
    end

    def fx_signal_params
      params.require(:fx_signal).permit(:pair_id, :direction, :entry, :take_profit, :stop_loss, :opened_at, :closed_at, :evaluated_at, :closed)
    end

end
