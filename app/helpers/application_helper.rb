module ApplicationHelper

  def highwatt
    highwatt = Settings.find_by_name('highwatt')
    if highwatt.nil? then
      highwatt = 20000
    else
      highwatt = highwatt[:ivalue]
    end
  end

  def lowwatt
    lowwatt = Settings.find_by_name('lowwatt')
    if lowwatt.nil? then
      lowwatt = 20000
    else
      lowwatt = lowwatt[:ivalue]
    end
  end
end