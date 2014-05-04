class ImagesController < ApplicationController


  # Get images from a category 
  def new
    categoryId = params[:category_id]
    score = params[:score]
    # Convert from string to int and add 1 so we don't include this date. We want our dates to be greater than this, 
    # but the query seems to include it even if we specify greater than (some Time conversion thing?), so just 
    # get around this by adding 1.
    createdAfter = params[:created_after].to_i + 1
    # How many images are desired
    count = params[:count].to_i

    # Get all the images in the requested category
    imagesInCategory = Image.joins('INNER JOIN categories_images ON categories_images.image_id = images.id').where('categories_images.category_id=?', categoryId)
    
    result = imagesInCategory.where('reddit_score >= ? and created_at > ?', 
      score, Time.at(createdAfter)).order(created_at: :asc).limit(count)

    resultSize = result.size

    # Include images below the given score if we didn't get enough new ones above it
    if resultSize < count
      result << imagesInCategory.where('reddit_score < ?', score).order(reddit_score: :desc, created_at: :asc).limit(count - resultSize)
    end

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
    images = Image.where("id > ? and updated_at > ? and created_at <= ?", 
      afterId, Time.at(lastUpdated.to_i), Time.at(lastCreated.to_i)).order(id: :asc).limit(batchLimit)

    render json: images.as_json
  end

end
