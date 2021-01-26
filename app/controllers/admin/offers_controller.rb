class Admin::OffersController < ApplicationController
  before_action :set_offer, only: [:edit, :update, :destroy]

  def index
    @offers = Offer.all
  end

  def new
    @offer = Offer.new
  end

  def edit
  end

  def create
    @offer = Offer.new(offer_params)

    if @offer.save
      redirect_to admin_offers_path, notice: 'Offer successfully created'
    else
      render :new, alert: 'Failed to created Offer', status: :unprocessable_entity
    end
  end

  def update
    if @offer.update(offer_params)
      redirect_to admin_offers_path, notice: 'Offer successfully updated'
    else
      render :edit, alert: 'Failed to update Offer', status: :unprocessable_entity
    end
  end

  def destroy
    @offer.destroy

    redirect_to admin_offers_path, notice: 'Offer deleted successfully'
  end

  protected

  def offer_params
    params.require(:offer).permit(:advertiser_name, :description, :url, :starts_at, :ends_at, :premium, :state)
  end

  def set_offer
    @offer = Offer.find(params[:id])
  end
end
