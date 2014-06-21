class AddCategories20140621192556 < ActiveRecord::Migration
  def change
      Category.create(name: 'surfing', nsfw: false)
  end
end
