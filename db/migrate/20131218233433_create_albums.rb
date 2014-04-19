class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.boolean :nsfw, default: false
      t.integer :reddit_score
      t.integer :category_id
      t.string :imgurId, unique: true
      t.boolean :deleted, default: false

      t.timestamps
    end

    create_table :categories_albums, id: false do |t|
      t.belongs_to :category
      t.belongs_to :album
    end
  end
end
