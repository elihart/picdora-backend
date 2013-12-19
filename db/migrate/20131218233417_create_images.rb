class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :imgurId
      t.integer :reddit_score
      t.boolean :reported, default: false
      t.boolean :nsfw, default: false
      t.boolean :gif, default: false
      t.integer :category_id
      t.integer :album_id, default: nil
      t.boolean :landscape, default: nil
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
