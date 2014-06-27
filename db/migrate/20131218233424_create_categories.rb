class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, unique: true
      t.boolean :nsfw, default: false
      t.string :icon
      t.string :reddit_description

      t.timestamps
    end

    create_table :categories_images, id: false do |t|
      t.belongs_to :category
      t.belongs_to :image
    end

    add_index :categories_images, [ :category_id, :image_id ], unique: true, name: "by_image_and_category"
    add_index :categories, :name, name: 'category_name_ix'

  end
end
