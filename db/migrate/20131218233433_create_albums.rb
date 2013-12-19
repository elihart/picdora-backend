class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.boolean :nsfw, default: false
      t.integer :reddit_score
      t.integer :category_id
      t.string :imgurId
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
