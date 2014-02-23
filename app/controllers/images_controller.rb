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

  # Get images created after a certain date
  def new
    afterId = params[:id]
    afterTime = params[:after]
    batchLimit = params[:limit] || 1000
    batchLimit = batchLimit.to_i

    # Get one more image than we need so we can tell them what the next image id is
    images = Image.where("id >= ? and created_at > ?", afterId, Time.at(afterTime.to_i)).order(id: :asc).limit(batchLimit + 1)

    nextImage = images[batchLimit]

    result = {}
    if nextImage
      result[:nextId] = nextImage.id
    end

    # Don't include the last image in the range
    result[:images] = images[0...batchLimit].as_json(only: [:id, :imgurId, :reddit_score, :nsfw, :gif, :category_id])


    render json: result
  end

  def update
    afterId = params[:id]
    afterTime = params[:time]
    batchLimit = params[:limit] || 1000
    batchLimit = batchLimit.to_i

    # Get one more image than we need so we can tell them what the next image id is
    images = Image.where("id >= ? and updated_at > ?", afterId, Time.at(afterTime.to_i)).order(id: :asc).limit(batchLimit + 1)

    nextImage = images[batchLimit]

    result = {}
    if nextImage
      result[:nextId] =  nextImage.id
    end

    # Don't include the last image in the range
    result[:images] = images[0...batchLimit].as_json(only: [:id, :imgurId, :reddit_score, :nsfw, :gif, :category_id])


    render json: result
  end

  def range
    start = params[:start]
    stop = params[:end]
    before = params[:before]
    after = params[:after]

    if start.nil? || stop.nil?
      render json: {}
      return
    end


    if before && after
      images = Image.where(id: start..stop, updated_at: Time.at(after.to_i)..Time.at(before.to_i))
    elsif before
      images = Image.where(id: start..stop, updated_at: Time.at(0)..Time.at(before.to_i))
    elsif after
      images = Image.where(id: start..stop, updated_at: Time.at(after.to_i)..Time.now)
    else
      images = Image.where(id: start..stop)
    end

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
