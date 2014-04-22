class AddIconToCategories < ActiveRecord::Migration
  def change
  	add_column :categories, :icon, :string

    Category.find_each do |cat|
     image = cat.images.where(reported: false, deleted: false).order(reddit_score: :desc).offset(20).first
     cat.update(icon: image.imgurId)
    end

    Category.where(name: "onoff").first.update(icon: "ojXSD")
    Category.where(name: "assinthong").first.update(icon: "E9zi2uR")
  end
end
