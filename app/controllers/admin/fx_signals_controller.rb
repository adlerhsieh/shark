class Admin::FxSignalsController < Admin::BaseController
  before_action :load_fx_signal, only: %i[show edit update destroy source iframe_source]
  before_action :load_pairs, only: %i[new edit]

  def index
    @fx_signals = FxSignal.includes(:pair, :source).all.order(created_at: :desc, id: :desc)

    if params[:source_id]
      @fx_signals = @fx_signals.where(source_id: params[:source_id])
    end

    @fx_signals = @fx_signals.limit(100)
  end

  def show
    @orders = @fx_signal.orders
    @positions = @fx_signal.positions
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

  def source
  end

  def iframe_source
    case @fx_signal.source.channel
    when "gmail"
      s = Gmail::Service.new
      mail = Timeout::timeout(10) { s.message(@fx_signal.source_secondary_id) }
      @html = mail.payload.try(:parts).try(:last).try(:body).try(:data) || mail.payload.try(:body).try(:data)
    end

    render "iframe_source", layout: false
  end

  private

    def load_fx_signal
      @fx_signal = FxSignal.find(params[:id])
    end

    def fx_signal_params
      params.require(:fx_signal).permit(:pair_id, :direction, :entry, :take_profit, :stop_loss, :opened_at, :closed_at, :evaluated_at, :closed, :issue)
    end

    def load_pairs
      @pairs = Pair.all.order(:base, :quote)
    end

end
