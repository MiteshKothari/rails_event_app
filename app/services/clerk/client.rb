module Clerk
  # Backed by the official `clerk-sdk-ruby` gem. Sign-in happens entirely on
  # Clerk's hosted Account Portal (CLERK_SIGN_IN_URL) — clerk-sdk-ruby's Rack
  # middleware (mounted automatically by its Railtie once CLERK_SECRET_KEY is
  # set) verifies the session on every request, including the redirect
  # handshake back from the Account Portal, and exposes it via
  # request.env["clerk"]. There is no local sign-in form in this mode.
  class Client
    Session = Struct.new(:user_id, :email, keyword_init: true)

    def current_session(request)
      proxy = request.env["clerk"]
      return nil unless proxy&.user?

      Session.new(user_id: proxy.user_id, email: proxy.user.email_addresses.first&.email_address)
    end

    def sign_in(_request, email:)
      raise NotImplementedError, "Clerk sign-in happens on the hosted Account Portal"
    end

    def sign_out(request)
      proxy = request.env["clerk"]
      session_id = proxy&.session && proxy.session["sid"]

      begin
        Clerk::SDK.new.sessions.revoke(session_id: session_id) if session_id
      rescue StandardError => e
        ::Rails.logger.warn("Clerk session revoke failed: #{e.message}")
      end

      request.cookie_jar.delete(Clerk::SESSION_COOKIE)
      request.cookie_jar.delete(Clerk::CLIENT_UAT_COOKIE)
    end

    def sign_in_path(return_to: nil)
      url = ENV.fetch("CLERK_SIGN_IN_URL")
      return url unless return_to

      uri = URI.parse(url)
      query = ::Rack::Utils.parse_query(uri.query)
      query["redirect_url"] = return_to
      uri.query = ::Rack::Utils.build_query(query)
      uri.to_s
    end

    def hosted_sign_in?
      true
    end
  end
end
