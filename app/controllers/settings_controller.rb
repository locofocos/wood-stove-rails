class SettingsController < ApplicationController
  before_action :set_settings, only: %i[ show edit update destroy ]

  # GET /settings or /settings.json
  def index
    @settings = Settings.all
  end

  # GET /settings/1 or /settings/1.json
  def show
  end

  # GET /settings/new
  def new
    @settings = Settings.new
  end

  # GET /settings/1/edit
  def edit
  end

  # POST /settings or /settings.json
  def create
    @settings = Settings.new(settings_params)

    respond_to do |format|
      if @settings.save
        format.html { redirect_to settings_url(@settings), notice: "Settings was successfully created." }
        format.json { render :show, status: :created, location: @settings }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @settings.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /settings/1 or /settings/1.json
  def update
    respond_to do |format|
      if @settings.update(settings_params)
        format.html { redirect_to settings_url(@settings), notice: "Settings was successfully updated." }
        format.json { render :show, status: :ok, location: @settings }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @settings.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1 or /settings/1.json
  def destroy
    @settings.destroy

    respond_to do |format|
      format.html { redirect_to settings_index_url, notice: "Settings was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_settings
      @settings = Settings.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def settings_params
      params.require(:settings).permit(:static_temp_factor, :dynamic_temp_factor)
    end
end
