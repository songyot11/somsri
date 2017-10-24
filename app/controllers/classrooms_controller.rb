class ClassroomsController < ApplicationController
  load_and_authorize_resource

  # GET /grades
  def index
    @classrooms = Classroom.all.to_a
    render json: @classrooms, status: :ok
  end
end
