class CandidatesController < ApplicationController

  def index
    @candidate = Candidate.all.order(created_at: 'desc')
    filter_parents
    total = @candidate.size
    @candidate = @candidate.offset(params[:offset]).limit(params[:limit])
    
    render json: {
      rows: @candidate.as_json,
      total: total
    }, status: :ok
  end
  
  def destroy
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.destroy
  end

  def filter_parents
    if params[:search].present?
      search = "%#{params[:search]}%"
      @candidate = @candidate.where('full_name LIKE :search OR
                                  nick_name LIKE :search OR
                                  email LIKE :search
                                  ',
                                  search: search)
    end
      # sort and order
      if params[:sort].present?
        case params[:sort]
        when 'link_full_name'
          @candidate = Candidate.order(full_name: params[:order])
        when 'school_year'
          @candidate = Candidate.order(school_year: params[:order])
        when 'current_ability'
          @candidate = Candidate.order(current_ability: params[:order])
        when 'learn_ability'
          @candidate = Candidate.order(learn_ability: params[:order])
        when 'created_at'
          @candidate = Candidate.order(created_at: params[:order])
        end
      end
  end  

  

end