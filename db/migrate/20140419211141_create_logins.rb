class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
    	t.belongs_to :user

      t.timestamps
    end
  end
end
