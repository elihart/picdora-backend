class ImagesController < ApplicationController
  def random
    count = params[:count]
    if !count
      count = 1
    end

    images = []
    count.to_i.times do
      images.push(Image.offset(rand(Image.count)).first)
    end

    render json: images
  end

  def top
    count = params[:count]
    category = Category.find(params[:category_id])
    excludeIds = params[:exclude]
    if !excludeIds
      excludeIds = []
    end

    images = Image.where(category: category).where.not(id: excludeIds).order(reddit_score: :desc).limit(count)

    render json: images.as_json(only: [:id, :imgurId, :reddit_score, :nsfw, :gif, :category_id])
  end
end
