module ParentsHelper

  def set_option_selected key, object
    if !object.nil?
      key.id == object.id ? "selected" : ""
    end
  end

end
