class ImagesController < ApplicationController
  def random
    image = Image.offset(rand(Image.count)).first
    render json: image
  end
end
