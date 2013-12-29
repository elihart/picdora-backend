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
    category_ids = params[:category_ids]
    excludeIds = params[:exclude]

    # Convert true/false string param to boolean
    gif = params[:gif]
    unless gif.nil?
      gif = params[:gif].downcase == "true" ? true : false
    end


    images = Image.where(category_id: category_ids).where.not(id: excludeIds)

    images = images.where(gif: gif) unless gif.nil?

    images = images.order(reddit_score: :desc).limit(count)

    render json: images.as_json(only: [:id, :imgurId, :reddit_score, :nsfw, :gif, :category_id])
  end

  def count
    count = params[:count]
    category_ids = params[:category_ids]

    # Convert true/false string param to boolean
    gif = params[:gif]

    result = 0

    if gif.nil?
      result = Image.where(category_id: category_ids).count
    elsif gif.downcase == "true"
      result = Image.where(category_id: category_ids, gif: true).count
    elsif gif.downcase == "false"
      result = Image.where(category_id: category_ids, gif: false).count
    else
      # If
      result = Image.where(category_id: category_ids).count
    end

    render json: {count: result}
  end
end
