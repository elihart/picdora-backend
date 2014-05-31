class Image < ActiveRecord::Base
  has_and_belongs_to_many :categories
  belongs_to :album
  has_many :image_reports

  validates :imgurId, uniqueness: {case_sensitive: true}
  validates :imgurId, :reddit_score, presence: true

  def as_json(options={})
  	# Get the ids of the categories that this image belongs to. Pluck() or ids() can be used as a shortcut, but it seems to requery the categories
  	# even when we have them preloaded. This makes them unacceptably slow so we'll get them manually instead.
  	category_ids = []
  	self.categories.each do |c|
  		category_ids << c.id
  	end

  	{
        id: self.id,
        imgurId: self.imgurId,
        reddit_score: self.reddit_score,
        gif: self.gif,
        nsfw: self.nsfw,
        deleted: self.deleted,
        reported: self.reported,
        categories: category_ids,
        created_at: self.created_at.to_time.to_i,
        updated_at: self.updated_at.to_time.to_i
    }
  end
end
