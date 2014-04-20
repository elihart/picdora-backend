class Image < ActiveRecord::Base
  has_and_belongs_to_many :categories, uniq: true
  belongs_to :album

  validates :imgurId, uniqueness: {case_sensitive: true}
  validates :imgurId, :reddit_score, presence: true
end
