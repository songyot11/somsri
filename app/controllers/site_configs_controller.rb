class SiteConfigsController < ApplicationController
  load_and_authorize_resource
  def index
    result = {}
    if @site_configs && @site_configs[0]
      if params[:names] && params[:names].kind_of?(Array)
        params[:names].each do |name|
          result[name.to_sym] = @site_configs[0][name.to_sym]
        end
      elsif params[:name] && params[:name].kind_of?(String)
        result = @site_configs[0][params[:name].to_sym]
      else
        result = @site_configs[0]
      end
    end
    render json: result
  end
end
