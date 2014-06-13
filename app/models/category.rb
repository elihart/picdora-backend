class Category < ActiveRecord::Base
  has_and_belongs_to_many :images
  has_and_belongs_to_many :albums

  validates :name, uniqueness: {case_sensitive: false}
  validates :name, presence: true

  def as_json(options={})
  	{
        id: self.id,
        name: self.name,
        nsfw: self.nsfw,
        icon: self.icon,
        updated_at: self.updated_at.to_time.to_i
    }
  end
end
