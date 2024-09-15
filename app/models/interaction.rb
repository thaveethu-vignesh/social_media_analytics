class Interaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :interaction_type, presence: true, inclusion: { in: %w(like share comment) }
end