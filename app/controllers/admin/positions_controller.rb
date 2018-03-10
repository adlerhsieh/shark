class Admin::PositionsController < Admin::BaseController
  before_action :load_position, only: %i[edit update destroy]

  def index
    @positions = Position.all
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

    def load_position
      @position = Position.find(params[:id])
    end

end
