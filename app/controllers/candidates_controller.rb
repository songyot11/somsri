class CandidatesController < ApplicationController

  def index
    filter_candidates
    total = @candidate.size
    @candidate = @candidate.offset(params[:offset]).limit(params[:limit])
    
    render json: {
      rows: @candidate.as_json('data-table'),
      total: total
    }, status: :ok
  end
  
  def destroy
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.destroy
  end

  def filter_candidates
    @candidate = if params[:shortlist].present?
                  Candidate.where(shortlist: true).order(created_at: 'desc')
                 else 
                  Candidate.where(shortlist: false).order(created_at: 'desc')
                 end 
    if params[:search].present?
      search = "%#{params[:search]}%"
      @candidate = @candidate.where('full_name LIKE :search OR
                                  nick_name LIKE :search OR
                                  email LIKE :search OR
                                  candidates.from LIKE :search',
                                  search: search)
    end
      # sort and order
      if params[:sort].present?
        if params[:shortlist] == nil
          params[:shortlist] = false
        end
        case params[:sort]
        when 'link_full_name'
          @candidate = Candidate.where(shortlist: params[:shortlist]).order(full_name: params[:order])
        when 'school_year'
          @candidate = Candidate.where(shortlist: params[:shortlist]).order(school_year: params[:order])
        when 'current_ability'
          @candidate = Candidate.where(shortlist: params[:shortlist]).order(current_ability: params[:order])
        when 'learn_ability'
          @candidate = Candidate.where(shortlist: params[:shortlist]).order(learn_ability: params[:order])
        when 'created_at'
          @candidate = Candidate.where(shortlist: params[:shortlist]).order(created_at: params[:order])
        end
      end
  end  

  
  def edit
    @candidate = Candidate.find(params[:id])
    render json: @candidate.as_json('joins-table'), status: :ok
  end
  
  def update_candidate
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update(candidate_params)
  end

  def upload_photo
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update( image: upload_photo_params[:file])
  end

  private

  def upload_photo_params
    params.require(:candidate).permit(:file)
  end

  def candidate_params
    params.permit(:full_name, :nick_name, :email,
      programming_skills_attributes: [:id, :skill_name, :skill_point],
      soft_skills_attributes: [:id, :skill_name, :skill_point],
      design_skills_attributes: [:id, :skill_name, :skill_point]
    )
  end
end