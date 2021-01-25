require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'validations' do
    let(:valid_properties) do
      {
        advertiser_name: 'Advertiser 1',
        url: 'http://example.com',
        description: 'Description text',
        starts_at: DateTime.now
      }
    end

    let(:invalid_properties) do
      {
        advertiser_name: nil,
        url: nil,
        description: nil,
        starts_at: nil
      }
    end

    describe 'valid' do
      subject { Offer.new(valid_properties) }

      it { is_expected.to be_valid }
    end

    describe 'invalid' do
      let(:offer) { Offer.new(invalid_properties) }

      subject { offer }

      it { is_expected.not_to be_valid }

      describe 'errors' do
        subject { offer.errors }

        before do
          offer.valid?
        end

        it { is_expected.to include(:advertiser_name) }
        it { is_expected.to include(:url) }
        it { is_expected.to include(:description) }
        it { is_expected.to include(:starts_at) }
      end

      context 'non unique advertiser name' do
        let(:offer) { Offer.new(valid_properties) }

        before do
          Offer.create(valid_properties)
        end

        it { is_expected.to be_invalid }

        describe 'errors' do
          subject { offer.errors }

          before do
            Offer.create(valid_properties)
            offer.valid?
          end

          it { is_expected.to include(:advertiser_name) }
        end
      end

      context 'invalid uri format' do
        let(:invalid_properties) do
          {
            advertiser_name: 'Advertiser 1',
            url: 'www.example.com',
            description: 'Description text',
            starts_at: DateTime.now
          }
        end

        let(:offer) { Offer.new(invalid_properties) }

        it { is_expected.not_to be_valid }

        describe 'errors' do
          subject { offer.errors }

          before do
            offer.valid?
          end

          it { is_expected.to include(:url) }
        end
      end

      context 'invalid description length' do
        let(:invalid_properties) do
          {
            advertiser_name: 'Advertiser 1',
            url: 'https://example.com',
            description: 501.times.map { 'a' }.join,
            starts_at: DateTime.now
          }
        end

        let(:offer) { Offer.new(invalid_properties) }

        it { is_expected.not_to be_valid }

        describe 'errors' do
          subject { offer.errors }

          before do
            offer.valid?
          end

          it { is_expected.to include(:description) }
        end
      end
    end
  end
end
