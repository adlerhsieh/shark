class Admin::SourcesController < Admin::BaseController
  before_action :load_source, only: %i[show edit update destroy]
  before_action :remove_blank_values, only: %i[create update]

  def index
    @sources = Source.all.order(created_at: :desc)
  end

  def show
    @signals = @source.signals.includes(:order, :position)
    @positions = @source.all_positions
  end

  def new
    @source = Source.new
  end

  def create
    @source = Source.new(source_params)

    if @source.save
      flash[:info] = "Successfully created"
      redirect_to admin_sources_path
    else
      flash[:warning] = @source.errors
      render :new
    end
  end

  def edit
    
  end

  def update
    if @source.update(source_params)
      flash[:info] = "Successfully updated"
      redirect_to admin_source_path(@source)
    else
      flash[:warning] = @source.errors
      render :edit
    end
  end

  def destroy
    @source.destroy

    flash[:info] = "Source destoryed"
    redirect_to admin_sources_path
  end

  private

    def source_params
      params.require(:source).permit(:name, :username, :active, :abbreviation)
    end

    def load_source
      @source = Source.find(params[:id])
    end

    def remove_blank_values
      params[:source].each do |key, value|
        params[:source][key] = nil if params[:source][key].blank?
      end
    end

end
