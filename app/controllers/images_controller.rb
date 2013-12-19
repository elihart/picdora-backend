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
end
