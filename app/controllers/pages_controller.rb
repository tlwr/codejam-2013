

class PagesController < ApplicationController
  def index
    t = Time.new
    @time = t-t.sec-t.min%15*60 + (15*60)
    @power = 20000
    @points = 128
  end

  def empty
    Curve.delete_all
  end
end
