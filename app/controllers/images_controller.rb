class ImagesController < ApplicationController

  def top
    categoryId = params[:category_id]

    # How many images are desired
    count = params[:count].to_i

    # Get all the images in the requested category
    result = Image.includes(:categories).joins('INNER JOIN categories_images ON categories_images.image_id = images.id')
    .where('categories_images.category_id=?', categoryId).where(deleted: false, reported: false).order(reddit_score: :desc).limit(count)

    render json: result.as_json
  end

  # Check for images that have been updated within the given time spans.
  def update
    afterId = params[:id]
    
    lastUpdated = params[:last_updated].to_i
    lastCreated = params[:created_before].to_i
    
    batchLimit = params[:limit] || 1000
    batchLimit = batchLimit.to_i

    # Get one more image than we need so we can tell them what the next image id is
    images = Image.includes(:categories).where("id > ? and updated_at > ? and created_at <= ?", 
      afterId, Time.at(lastUpdated), Time.at(lastCreated)).order(id: :asc).limit(batchLimit)

    render json: images.as_json
  end

end
