require 'net/https'
require 'securerandom'
require 'uri'

class HomeController < ApplicationController

  def home
  end
  
  # Save off the user's request with a csrf_token to retrieve when we get
  # callback from github
  def github_oauth  
    request = GithubOauthRequest.new( {:csrf_token => SecureRandom.urlsafe_base64(30)} )
    request.save
    redirect_to "https://github.com/login/oauth/authorize?client_id=%s&redirect_uri=%s&state=%s" %
     [ ENV['GITHUB_CLIENT_ID'],
     '%s/github_oauth_code/%d' % [ENV['BASE_URL'], request.id],
     request.csrf_token]
  end
  
  
  # Callback for github to provide us with the temporary authorization code
  def github_oauth_code
    request = GithubOauthRequest.find(params[:request_id])
    if request.csrf_token != params[:state]
      flash[:notice] = "Unauthorized access to github account."
    else
      postData = { :client_id => ENV['GITHUB_CLIENT_ID'], 
        :client_secret => ENV['GITHUB_CLIENT_SECRET'],
        :redirect_uri => '%s/github_oauth_token' % [ENV['BASE_URL']],
        :code => params[:code],
        :state => params[:state]}
      url = URI.parse('https://github.com/login/oauth/access_token')
      req = Net::HTTP::Post.new(url.path)
      req.form_data = postData
      con = Net::HTTP.new(url.host, url.port)
      con.use_ssl = true
      con.start { |http| 
        response = http.request(req)
        puts response.to_s
        puts response.msg
        puts response.code
        puts response.body
      }
    end
  end
end
