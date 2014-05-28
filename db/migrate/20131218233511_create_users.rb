class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :device_key, unique: true

      t.timestamps
    end
  end
end
