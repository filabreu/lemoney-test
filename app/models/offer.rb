class Offer < ApplicationRecord
  validates :advertiser_name, :url, :description, :starts_at, presence: true
  validates :advertiser_name, uniqueness: true
  validates :description, length: { maximum: 500 }
  validates :url, format: { with: URI.regexp(%w(http https)), message: "must be a valid URI" }
end
