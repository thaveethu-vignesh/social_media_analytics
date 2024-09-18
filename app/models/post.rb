class Post < ApplicationRecord
  belongs_to :user
  has_many :interactions, dependent: :destroy

  validates :content, presence: true

  before_save :log_before_save
  after_save :log_after_save

  private

  def log_before_save
    Rails.logger.info "Before save: Post with content: #{content[0..50]}... for user: #{user_id}"
  end

  def log_after_save
    Rails.logger.info "After save: Post ID: #{id}, content: #{content[0..50]}... for user: #{user_id}"
  end
  
end