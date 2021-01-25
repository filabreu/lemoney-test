require 'rails_helper'

RSpec.describe Offer, type: :model do
  let(:valid_properties) do
    {
      advertiser_name: 'Advertiser 1',
      url: 'http://example.com',
      description: 'Description text',
      starts_at: DateTime.now,
      ends_at: DateTime.now.next_week
    }
  end

  before(:all) do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'validations' do
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

  describe '#state' do
    let(:offer) { Offer.create(valid_properties) }

    context 'initial value' do
      subject { offer.state }

      it { is_expected.to eq('disabled') }
    end
  end

  describe '#enable' do
    let!(:offer) { Offer.create(valid_properties) }

    context 'starts_at <= DateTime.now' do
      it do
        expect { offer.enable }.to change { offer.state }
          .from('disabled')
          .to('enabled')
      end
    end

    context 'starts_at > DateTime.now' do
      let(:valid_properties) do
        {
          advertiser_name: 'Advertiser 1',
          url: 'http://example.com',
          description: 'Description text',
          starts_at: DateTime.tomorrow,
          ends_at: DateTime.now.next_week
        }
      end

      it do
        expect { offer.enable }.not_to change { offer.state }
      end
    end
  end

  describe '#disable' do
    let!(:offer) { Offer.create(valid_properties) }

    before do
      offer.enable
    end

    context 'ends_at <= DateTime.now' do
      let(:valid_properties) do
        {
          advertiser_name: 'Advertiser 1',
          url: 'http://example.com',
          description: 'Description text',
          starts_at: DateTime.now.last_week,
          ends_at: DateTime.yesterday
        }
      end

      it do
        expect { offer.disable }.to change { offer.state }
          .from('enabled')
          .to('disabled')
      end
    end

    context 'ends_at > DateTime.now' do
      it do
        expect { offer.disable }.not_to change { offer.state }
      end
    end
  end

  describe '#enqueue_enable' do
    context 'create' do
      let(:offer) { Offer.new(valid_properties) }

      it do
        expect do
          offer.save
        end.to have_enqueued_job(OfferEnableJob)
          .with(Integer)
          .at(offer.starts_at)
      end
    end

    context 'update' do
      let!(:offer) { Offer.create(valid_properties) }

      context 'starts_at changes' do
        it do
          expect do
            offer.update(starts_at: DateTime.tomorrow)
          end.to have_enqueued_job(OfferEnableJob)
            .with(Integer)
        end
      end

      context 'changes other attribute' do
        it do
          expect do
            offer.update(description: 'Another description text')
          end.not_to have_enqueued_job(OfferEnableJob)
        end
      end
    end
  end

  describe '#enqueue_disable' do
    context 'create' do
      let(:offer) { Offer.new(valid_properties) }

      it do
        expect do
          offer.save
        end.to have_enqueued_job(OfferDisableJob)
          .with(Integer)
          .at(offer.ends_at)
      end

      context 'ends_at is nil' do
        let(:valid_properties) do
          {
            advertiser_name: 'Advertiser 1',
            url: 'http://example.com',
            description: 'Description text',
            starts_at: DateTime.now,
            ends_at: nil
          }
        end

        it do
          expect do
            offer.save
          end.not_to have_enqueued_job(OfferDisableJob)
            .with(Integer)
        end
      end
    end

    context 'update' do
      let!(:offer) { Offer.create(valid_properties) }

      context 'ends_at changes' do
        it do
          expect do
            offer.update(ends_at: DateTime.tomorrow)
          end.to have_enqueued_job(OfferDisableJob)
            .with(Integer)
        end
      end

      context 'changes other attribute' do
        it do
          expect do
            offer.update(description: 'Another description text')
          end.not_to have_enqueued_job(OfferDisableJob)
        end
      end
    end
  end
end
