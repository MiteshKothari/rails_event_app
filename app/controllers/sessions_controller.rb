class SessionsController < ApplicationController
  def new
    if Rails.configuration.clerk_client.hosted_sign_in?
      redirect_to Rails.configuration.clerk_client.sign_in_path(return_to: root_url), allow_other_host: true
    end
  end

  def create
    email = params.require(:email)
    Rails.configuration.clerk_client.sign_in(request, email: email)
    redirect_to events_path, notice: "Signed in as #{email}"
  end

  def destroy
    Rails.configuration.clerk_client.sign_out(request)
    redirect_to events_path, notice: "Signed out"
  end
end
