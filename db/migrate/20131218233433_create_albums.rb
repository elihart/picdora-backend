class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.boolean :nsfw, default: false
      t.integer :reddit_score
      t.string :imgurId, unique: true
      t.boolean :deleted, default: false

      t.timestamps
    end

    create_table :albums_categories, id: false do |t|
      t.belongs_to :category
      t.belongs_to :album
    end

    add_index :albums_categories, [ :category_id, :album_id ], unique: true, name: "by_album_and_category"
  end
end
