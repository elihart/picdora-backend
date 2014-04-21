class CreateScrapes < ActiveRecord::Migration
  def change
    create_table :scrapes do |t|
      t.key :string, unique: true

      t.timestamps
    end
  end
end
