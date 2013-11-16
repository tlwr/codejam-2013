class SettingsController < ApplicationController
  def watts
    high = params[:settings_high]
    low = params[:settings_low]
    highwatt = Settings.find_by_name('highwatt')
    lowwatt = Settings.find_by_name('lowwatt')
    unless high.nil?
      highwatt.ivalue = high
    end
    unless low.nil?
        lowwatt.ivalue = low
    end
    highwatt.save
    lowwatt.save
    render :nothing => true, :status => 200
  end
end
