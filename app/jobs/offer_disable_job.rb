class OfferDisableJob < ApplicationJob
  queue_as :default

  def perform(offer_id)
    Offer.find(offer_id).disable
  end
end