class Admin::PathsController < ApplicationController
  before_action :admin_access
  before_action :set_path, only: [:edit,:update]
  def index
    @paths = Path.all
  end

  def new
    @path = Path.new
  end

  def create
    @path = Path.new(path_params)
    if @path.save
      redirect_to admin_paths_path, notice: "Path creado"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  private

    def set_path
      @path = Path.find(params[:id])
    end

    def path_params
      params.require(:path).permit(:name,:description,:published)
    end
end
