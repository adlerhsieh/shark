class Admin::FxSignalsController < Admin::BaseController
  before_action :load_fx_signal, only: %i[show edit update destroy]

  def index
    @signals = FxSignal.includes(:pair).all.order(created_at: :desc)
  end

  def show
    
  end

  def new
    
  end

  def create
    
  end

  def edit
    
  end

  def update
    
  end

  def destroy
    
  end

  private

    def load_fx_signal
      @fx_signal = FxSignal.find(params[:id])
    end

end
