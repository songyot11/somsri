module ApplicationHelper
  def user_avatar(url, options = { size: 40, default: 'identicon' })
     if gravatar?(url) || url.abbreviation_name.blank?
       image_tag current_user.gravatar_url(options), title: current_user.email, class: 'img-circle img-avatar'
     else
       content_tag(:span, url.abbreviation_name, title: current_user.email, class: 'img-avatar')
     end
   end

 def gravatar?(url)
   gravatar_check = "https://secure.gravatar.com/avatar/#{current_user.gravatar_id}.png?r=PG"
   uri = URI.parse(gravatar_check)
   http = Net::HTTP.new(uri.host, uri.port)
   request = Net::HTTP::Get.new(uri.request_uri)
   response = http.request(request)
   if (response.code.to_i == PG)
     return false
   else
     return true
   end
 end
end
