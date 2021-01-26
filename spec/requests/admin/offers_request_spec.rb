require 'rails_helper'

RSpec.describe "Admin::Offers", type: :request do
  let(:valid_params) do
    {
      advertiser_name: 'Advertiser 1',
      url: 'http://example.com',
      description: 'Description text',
      starts_at: DateTime.now,
      ends_at: DateTime.now.next_week,
      premium: false
    }
  end

  let(:invalid_params) do
    {
      advertiser_name: nil,
      url: nil,
      description: nil,
      starts_at: nil
    }
  end

  describe 'GET index' do
    let(:offers) { [Offer.create(valid_params)] }

    it 'renders list of offers' do
      get '/admin/offers'

      expect(assigns(:offers)).to eq(offers)
      expect(response).to render_template(:index)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET new' do
    it 'renders new offer form' do
      get '/admin/offers/new'

      expect(assigns(:offer)).to be_a(Offer)
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET edit' do
    let(:offer) { Offer.create(valid_params) }

    it 'renders edit offer form' do
      get "/admin/offers/#{offer.id}/edit"

      expect(assigns(:offer)).to eq(offer)
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      it 'creates offer and redirect' do
        post '/admin/offers', params: { offer: valid_params }

        expect(assigns(:offer)).to be_a(Offer)
        expect(response).to redirect_to(admin_offers_path)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      it 'respond with error and renders new offer form' do
        post '/admin/offers', params: { offer: invalid_params }

        expect(assigns(:offer)).to be_a(Offer)
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT/PATCH update' do
    let(:offer) { Offer.create(valid_params) }

    context 'with valid params' do
      it 'updates offer and redirect' do
        put "/admin/offers/#{offer.id}", params: { offer: valid_params }

        expect(assigns(:offer)).to eq(offer)
        expect(response).to redirect_to(admin_offers_path)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      it 'respond with error and renders new offer form' do
        put "/admin/offers/#{offer.id}", params: { offer: invalid_params }

        expect(assigns(:offer)).to eq(offer)
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:offer) { Offer.create(valid_params) }

    it 'destroys offer and redirect to offers list' do
      delete "/admin/offers/#{offer.id}"

      expect(assigns(:offer)).to eq(offer)
      expect(response).to redirect_to(admin_offers_path)
      expect(response).to have_http_status(:redirect)
    end
  end
end
