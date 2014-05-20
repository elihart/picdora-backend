class Image < ActiveRecord::Base
  has_and_belongs_to_many :categories
  belongs_to :album

  validates :imgurId, uniqueness: {case_sensitive: true}
  validates :imgurId, :reddit_score, presence: true

  def as_json(options={})
  	{
        id: self.id,
        imgurId: self.imgurId,
        reddit_score: self.reddit_score,
        gif: self.gif,
        nsfw: self.nsfw,
        deleted: self.deleted,
        reported: self.reported,
        categories: self.categories.pluck(:id),
        created_at: self.created_at.to_time.to_i,
        updated_at: self.updated_at.to_time.to_i
    }
  end
end
