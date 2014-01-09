class Image < ActiveRecord::Base
  belongs_to :category
  belongs_to :album

  validate :unique_image_in_category

  def unique_image_in_category
        if Image.where(category_id: category_id, imgurId: imgurId).count > 0
          errors.add(:imgurId, " must be unique in category")
        end
  end
end
