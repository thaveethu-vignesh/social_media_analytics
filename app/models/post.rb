class Post < ApplicationRecord
  belongs_to :user
  has_many :interactions, dependent: :destroy

  validates :content, presence: true
end