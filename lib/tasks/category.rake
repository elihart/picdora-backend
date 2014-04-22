namespace :category do
  desc "update categories icons based on the most popular images"
  task set_icons: :environment do
    Category.find_each do |cat|
     image = cat.images.where(reported: false, deleted: false).order(reddit_score: :desc).offset(20).first
     cat.update(icon: image.imgurId)
    end
  end
end