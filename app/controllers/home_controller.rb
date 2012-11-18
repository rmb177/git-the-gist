class HomeController < ApplicationController

  def home
  end
  
  def github_oauth
     redirect_to "https://github.com/login/oauth/authorize"
  end

end
