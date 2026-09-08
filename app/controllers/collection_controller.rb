class CollectionController < ApplicationController
  before_action :authenticate_user!

  def index
    @mosaic_arts = current_user.mosaic_arts
                               .completed
                               .includes(mosaic_design: :design_pieces)
                               .order(completed_at: :desc)
  end
end
