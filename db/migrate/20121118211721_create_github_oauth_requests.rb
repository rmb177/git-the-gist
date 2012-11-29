class CreateGithubOauthRequests < ActiveRecord::Migration
  def change
    create_table :github_oauth_requests do |t|
      t.string :csrf_token

      t.timestamps
    end
  end
end
