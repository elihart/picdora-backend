class CategoryNameIndex < ActiveRecord::Migration
  def change
  	add_index :categories, :name, name: 'category_name_ix'
  end
end
