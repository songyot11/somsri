class GradesController < ApplicationController
  # GET /grades
  def index
    @grades = Grade.all.to_a
    @grades << Grade.new(name: 'All', id: -1)
  end
end
