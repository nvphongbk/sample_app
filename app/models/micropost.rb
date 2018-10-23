class Micropost < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.maximum_content}
  validate :picture_size
  scope :create_at, ->{order(created_at: :desc)}

  private

  def picture_size
    return unless picture.size > Settings.img_size.megabytes
    errors.add(:picture, I18n.t("models.micropost.less_than_5MB"))
  end
end
