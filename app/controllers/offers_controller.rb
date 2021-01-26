class OffersController < ApplicationController
  def index
    @offers = Offer.enabled.order('premium DESC')
  end
end
