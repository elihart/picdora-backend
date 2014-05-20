class CategoriesController < ApplicationController
  def index
    render json: Category.all.as_json
  end
end
