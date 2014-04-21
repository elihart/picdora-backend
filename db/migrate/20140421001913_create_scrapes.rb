class CreateScrapes < ActiveRecord::Migration
  def change
    create_table :scrapes do |t|
      t.string :key, unique: true

      t.timestamps
    end
  end
end
