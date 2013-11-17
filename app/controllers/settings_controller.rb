class SettingsController < ApplicationController
  def watts
    high = params[:settings_high]
    low = params[:settings_low]
    highwatt = Settings.find_by_name('highwatt')
    lowwatt = Settings.find_by_name('lowwatt')
    if highwatt.nil?
      highwatt = Settings.new
      highwatt.name = 'highwatt'
    end
    if lowwatt.nil?
      lowwatt = Settings.new
      lowwatt.name = 'lowwatt'
    end
    unless high.nil?
      highwatt.ivalue = high
    else
      highwatt.ivalue = 20000
    end
    unless low.nil?
      lowwatt.ivalue = low
    else
      lowwatt.ivalue = 5000
    end
    highwatt.save
    lowwatt.save
    render :nothing => true, :status => 200
  end
end
