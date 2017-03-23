class GradesController < ApplicationController
  load_and_authorize_resource
  # GET /grades
  def index
    @grades = Grade.all.to_a
    @grades << Grade.new(name: 'All', id: -1)
  end
end
