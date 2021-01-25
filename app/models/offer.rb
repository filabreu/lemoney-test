class Offer < ApplicationRecord
  validates :advertiser_name, :url, :description, :starts_at, presence: true
  validates :advertiser_name, uniqueness: true
  validates :description, length: { maximum: 500 }
  validates :url, format: { with: URI.regexp(%w(http https)), message: "must be a valid URI" }

  after_save :enqueue_enable
  after_save :enqueue_disable, if: :ends_at

  enum state: { disabled: 0, enabled: 1 }

  def enable
    update(state: :enabled) if starts_at <= DateTime.now
  end

  def disable
    update(state: :disabled) if ends_at && ends_at <= DateTime.now
  end

  private

  def enqueue_enable
    if saved_change_to_starts_at?
      OfferEnableJob.set(wait_until: starts_at).perform_later(id)
    end
  end

  def enqueue_disable
    if saved_change_to_ends_at?
      OfferDisableJob.set(wait_until: ends_at).perform_later(id)
    end
  end
end
