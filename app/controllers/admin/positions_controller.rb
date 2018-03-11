class Admin::PositionsController < Admin::BaseController
  before_action :load_position, only: %i[edit update destroy]
  before_action :load_pairs, only: %i[new edit]
  before_action :load_sources, only: %i[new edit]

  def index
    @positions = Position.all.order(created_at: :desc)
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(position_params)
    @position.ig_open_position if @position.save

    redirect_to admin_orders_path
  end

  def edit
    
  end

  def update
    @position.update(position_params)
    redirect_to admin_positions_path
  end

  def destroy
    @position.destroy
    redirect_to admin_position_path
  end

  private

    def load_position
      @position = Position.find(params[:id])
    end

    def position_params
      params.require(:position).permit!
    end

    def load_pairs
      @pairs = Pair.where(mini: true).order(:base, :quote)
    end

    def load_sources
      @sources = Source.active.all
    end

end
