module Redirect
  extend ActiveSupport::Concern
  
  private
  
    def redirect_to_back_or_default(default = store_url)
      request.env["HTTP_REFERER"] = default unless request.env["HTTP_REFERER"] && request.env["HTTP_REFERER"] == request.env["REQUEST_URI"]
      redirect_to :back
    end

end