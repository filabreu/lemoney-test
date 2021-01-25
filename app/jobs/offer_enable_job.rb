class OfferEnableJob < ApplicationJob
  queue_as :default

  def perform(offer_id, state)
    Offer.find(offer_id).enable
  end
end