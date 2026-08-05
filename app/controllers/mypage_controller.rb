class MypageController < ApplicationController
  include MosaicGridAssignable

  def index
    assign_mosaic_grid!(current_user)
  end
end
