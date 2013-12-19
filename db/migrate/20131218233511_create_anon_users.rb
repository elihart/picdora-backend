class CreateAnonUsers < ActiveRecord::Migration
  def change
    create_table :anon_users do |t|
      t.string :device

      t.timestamps
    end
  end
end
