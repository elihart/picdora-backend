class CategoriesController < ApplicationController
  def index
    render json: Category.all.as_json(only: [:id, :name, :nsfw, :porn])
  end
end
