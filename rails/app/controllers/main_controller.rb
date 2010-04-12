class MainController < ApplicationController
  layout 'mobile'

  def index
    #@modes = %W[ bus commuter_rail subway boat ]
    modes = []
    [Bus, CommuterRail, Subway, Boat].each do |mode|
      @modes << mode.to_s.underscore unless mode.routes.size == 0
    end

    @twittags = []
    if TWIT_CONFIG['enabled']
      @twittags = Agency.all.map { |a| a.acronym.downcase } + 
        TWIT_CONFIG['additional_tags']
    end

    @agency_links = Agency.links
  end

end
