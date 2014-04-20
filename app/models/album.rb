class Album < ActiveRecord::Base
  has_many :images
  has_and_belongs_to_many :categories

  validates :imgurId, uniqueness: {case_sensitive: true}
  validates :reddit_score, :imgurId, presence: true
end
