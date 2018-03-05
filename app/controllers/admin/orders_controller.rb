class Admin::OrdersController < Admin::BaseController
  before_action :load_order, only: %i[show edit update destroy]
  before_action :load_pairs, only: %i[new edit]

  def index
    @orders = Order.all.includes(:position).order(created_at: :desc)
    @signals = FxSignal.includes(:pair).all.order(created_at: :desc)
  end

  def show
    
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.ig_sync if @order.save

    redirect_to admin_orders_path
  end

  def edit
    
  end

  def update
    @order.update(order_params)
    redirect_to admin_orders_path
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path
  end

  private

    def order_params
      params.require(:order).permit!
    end

    def load_order
      @order = Order.find(params[:id])
    end

    def load_pairs
      @pairs = Pair.all.order(:base, :quote)
    end

end
