class TempMonitorsController < ApplicationController
  before_action :set_temp_monitor, only: %i[ show edit update destroy ]

  # GET /temp_monitors or /temp_monitors.json
  def index
    @temp_monitors = TempMonitor.all
  end

  # GET /temp_monitors/1 or /temp_monitors/1.json
  def show
  end

  # GET /temp_monitors/new
  def new
    @temp_monitor = TempMonitor.new(enabled: true)
  end

  # GET /temp_monitors/1/edit
  def edit
  end

  # POST /temp_monitors or /temp_monitors.json
  def create
    @temp_monitor = TempMonitor.new(temp_monitor_params)

    respond_to do |format|
      if @temp_monitor.save
        format.html { redirect_to temp_monitor_url(@temp_monitor), notice: "Temp monitor was successfully created." }
        format.json { render :show, status: :created, location: @temp_monitor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @temp_monitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /temp_monitors/1 or /temp_monitors/1.json
  def update
    respond_to do |format|
      if @temp_monitor.update(temp_monitor_params)
        format.html { redirect_to temp_monitor_url(@temp_monitor), notice: "Temp monitor was successfully updated." }
        format.json { render :show, status: :ok, location: @temp_monitor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @temp_monitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /temp_monitors/1 or /temp_monitors/1.json
  def destroy
    @temp_monitor.destroy

    respond_to do |format|
      format.html { redirect_to temp_monitors_url, notice: "Temp monitor was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_temp_monitor
      @temp_monitor = TempMonitor.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def temp_monitor_params
      params.require(:temp_monitor).permit(:upper_limitf, :lower_limitf, :title, :send_notifications, :toggle_fan, :enabled, :reading_location )
    end
end
