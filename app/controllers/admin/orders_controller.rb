class Admin::OrdersController < Admin::BaseController
  before_action :load_order, only: %i[show edit update destroy remove]
  before_action :load_pairs, only: %i[new edit]
  before_action :load_sources, only: %i[new edit]

  def index
    @orders = Order
      .all
      .includes(:pair, :position, :source)
      .order(created_at: :desc, id: :desc)

    if params[:source_id]
      @orders = @orders.where(source_id: params[:source_id])
    end

    @orders = @orders.limit(100)
  end

  def show
    @fx_signals = @order.fx_signals
    @positions = Array.wrap(@order.position)
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.ig_place_order if @order.save

    redirect_to admin_orders_path
  end

  def edit
    
  end

  def update
    @order.update(order_params)
    redirect_to admin_orders_path
  end

  # remove from IG and mark as deleted
  def remove
    @order.ig_remove_order
    redirect_to admin_orders_path
  end

  # force destroy
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
      @pairs = Pair.where(mini: true).order(:base, :quote)
    end

    def load_sources
      @sources = Source.all
    end

end
