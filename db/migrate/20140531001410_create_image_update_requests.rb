class CreateImageUpdateRequests< ActiveRecord::Migration
  def change
    create_table :image_reports do |t|
      t.belongs_to :user_id
      t.belongs_to :image_id
      t.boolean :deleted, default: false
      t.boolean :reported, default: false
      t.boolean :gif, default: false      

      t.timestamps
    end
  end
end
