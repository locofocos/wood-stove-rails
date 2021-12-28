# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :set_settings, only: %i[show edit update destroy]

  # # GET /settings or /settings.json
  # def index
  #   @settings = Settings.all
  # end

  # # GET /settings/1 or /settings/1.json
  # def show
  # end

  # # GET /settings/new
  # def new
  #   @settings = Settings.new
  # end

  # basically a copy/paste of edit, just to give a nice URL
  def index
    @settings = Settings.first
  end

  # # GET /settings/1/edit
  # def edit
  # end

  # # POST /settings or /settings.json
  # def create
  #   @settings = Settings.new(settings_params)
  #
  #   respond_to do |format|
  #     if @settings.save
  #       format.html { redirect_to settings_url(@settings), notice: "Settings was successfully created." }
  #       format.json { render :show, status: :created, location: @settings }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @settings.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /settings/1 or /settings/1.json
  def update
    respond_to do |format|
      Settings.transaction do
        if @settings.update(settings_params)
          TempReading.where(created_at: 30.minutes.ago...Time.now).each(&:derive_temps!)

          format.html do
            redirect_to settings_url(@settings),
                        notice: 'Settings was successfully updated. Last 30 minutes of data have been recalibrated using these values'
          end
          format.json { render :show, status: :ok, location: @settings }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @settings.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # # DELETE /settings/1 or /settings/1.json
  # def destroy
  #   @settings.destroy
  #
  #   respond_to do |format|
  #     format.html { redirect_to settings_index_url, notice: "Settings was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

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
