class CreateImageUpdateRequests< ActiveRecord::Migration
  def change
    create_table :image_update_requests do |t|
      t.belongs_to :user
      t.belongs_to :image
      t.boolean :deleted, default: false
      t.boolean :reported, default: false
      t.boolean :gif, default: false      

      t.timestamps
    end
  end
end
