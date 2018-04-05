class Admin::PositionsController < Admin::BaseController
  before_action :load_position, only: %i[show edit update destroy chart]
  before_action :load_pairs, only: %i[new edit]
  before_action :load_sources, only: %i[new edit]

  def index
    @positions = Position
      .all
      .includes(:pair, :source, order: :source)
      .order(created_at: :desc, id: :desc)
      .limit(100)

    if params[:from] 
      @positions = @positions.where(
        "created_at > ?", 
        Time.parse("#{params[:from]} 00:00:00 #{Time.zone.name}").utc.to_s(:db)
      )
    end
    if params[:to]
      @positions = @positions.where(
        "created_at < ?", 
        Time.parse("#{params[:to]} 00:00:00 #{Time.zone.name}").utc.to_s(:db)
      )
    end
    if params[:source_id]
      @positions = Source.find(params[:source_id]).all_positions
    end
    case params[:stat]
    when "ongoing"
      @positions = @positions.where(closed_at: nil)
    end

  end

  def show
    @fx_signals = @position.fx_signals
    @orders = Array.wrap(@position.order)
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(position_params)
    @position.ig_open_position if @position.save

    redirect_to admin_positions_path
  end

  def edit
    
  end

  def update
    @position.update(position_params)
    redirect_to admin_positions_path
  end

  def destroy
    @position.destroy
    redirect_to admin_positions_path
  end

  def chart
    gon.push(
      chart: {
        title: @position.pair.pair,
        data: @position.price_history
        # data: [
        #   ['Mon', 20, 28, 38, 45],
        #   ['Tue', 31, 38, 55, 66],
        #   ['Wed', 50, 55, 77, 80],
        #   ['Thu', 77, 77, 66, 50],
        #   ['Fri', 68, 66, 22, 15]
        # ] 
      }    
    )
  end

  private

    def load_position
      @position = Position.find(params[:id])
    end

    def position_params
      params.require(:position).permit!
    end

    def load_pairs
      @pairs = Pair.order(:base, :quote)
    end

    def load_sources
      @sources = Source.all
    end

end
