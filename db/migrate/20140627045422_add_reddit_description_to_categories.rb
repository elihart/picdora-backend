class AddRedditDescriptionToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :reddit_description, :string
  end
end
