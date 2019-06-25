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
    render json: getInfo(params[:id]), status: :ok
  end
  
  def update_candidate
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update(params_candidate)
    @programming_skill = ProgrammingSkill.find_by(id: params[:id])
    @programming_skill.update(params_programming_skill)
    @soft_skill = SoftSkill.find_by(id: params[:id])
    @soft_skill.update(params_soft_skill)
    @design_skill = DesignSkill.find_by(id: params[:id])
    @design_skill.update(params_design_skill)
  end

  def upload_photo
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update( image: upload_photo_params[:file] )
  end

  def rollback
    @candidate = Candidate.find(params[:id])
    version = @candidate.versions.find(params[:version])
    if version.reify.save
      redirect_to @candidate, notice: 'User was Successfully rollbacked.'
    else
      render :show
    end
  end

  private

  def getInfo(id)
    {
      candidate: Candidate.find_by(id: id),
      programming_skill: ProgrammingSkill.find_by(id: id),
      soft_skill: SoftSkill.find_by(id: id),
      design_skill: DesignSkill.find_by(id: id)
    }
  end

  def params_candidate
    params.require(:candidate).permit(:full_name, :nick_name, :email)
  end

  def params_programming_skill
    params.require(:programming_skill).permit(:skill_name, :skill_point, :candidate_id)
  end

  def params_soft_skill
    params.require(:soft_skill).permit(:skill_name, :skill_point, :candidate_id)
  end

  def params_design_skill
    params.require(:design_skill).permit(:skill_name, :skill_point, :candidate_id)
  end

  def upload_photo_params
    params.require(:candidate).permit(:file)
  end

end