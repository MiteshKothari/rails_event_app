module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    return @current_user if defined?(@current_user)

    clerk_session = Rails.configuration.clerk_client.current_session(request)
    @current_user =
      clerk_session && User.find_or_create_by!(clerk_user_id: clerk_session.user_id) { |user| user.email = clerk_session.email }
  end

  def require_authentication!
    return if current_user

    redirect_to Rails.configuration.clerk_client.sign_in_path(return_to: request.original_url), allow_other_host: true, alert: "Please sign in to vote."
  end
end
