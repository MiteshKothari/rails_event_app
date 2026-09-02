require "rails_helper"

RSpec.describe Clerk::Client do
  subject(:client) { described_class.new }

  let(:cookie_jar) { instance_double(ActionDispatch::Cookies::CookieJar, delete: nil) }

  def request_with_clerk_env(clerk_proxy)
    instance_double(ActionDispatch::Request, env: { "clerk" => clerk_proxy }, cookie_jar: cookie_jar)
  end

  describe "#current_session" do
    it "returns nil when there is no signed-in Clerk user" do
      proxy = instance_double(Clerk::Proxy, user?: false)

      expect(client.current_session(request_with_clerk_env(proxy))).to be_nil
    end

    it "maps the Clerk user to a Session" do
      email_address = instance_double(Clerk::Models::Components::EmailAddress, email_address: "voter@example.com")
      user = instance_double(Clerk::Models::Components::User, email_addresses: [email_address])
      proxy = instance_double(Clerk::Proxy, user?: true, user_id: "user_123", user: user)

      session = client.current_session(request_with_clerk_env(proxy))

      expect(session.user_id).to eq("user_123")
      expect(session.email).to eq("voter@example.com")
    end
  end

  describe "#sign_in_path" do
    it "reads CLERK_SIGN_IN_URL" do
      allow(ENV).to receive(:fetch).with("CLERK_SIGN_IN_URL").and_return("https://example.accounts.dev/sign-in")

      expect(client.sign_in_path).to eq("https://example.accounts.dev/sign-in")
    end

    it "appends a redirect_url so Clerk sends the browser back to the app" do
      allow(ENV).to receive(:fetch).with("CLERK_SIGN_IN_URL").and_return("https://example.accounts.dev/sign-in")

      path = client.sign_in_path(return_to: "http://localhost:3000/")

      expect(path).to eq("https://example.accounts.dev/sign-in?redirect_url=http%3A%2F%2Flocalhost%3A3000%2F")
    end
  end

  it "uses hosted sign-in" do
    expect(client.hosted_sign_in?).to eq(true)
  end

  describe "#sign_in" do
    it "is not supported" do
      expect { client.sign_in(nil, email: "a@example.com") }.to raise_error(NotImplementedError)
    end
  end

  describe "#sign_out" do
    it "revokes the Clerk session and clears local cookies" do
      sessions = instance_double(Clerk::Sessions, revoke: nil)
      sdk = instance_double(Clerk::SDK, sessions: sessions)
      allow(Clerk::SDK).to receive(:new).and_return(sdk)
      proxy = instance_double(Clerk::Proxy, session: { "sid" => "sess_123" })
      request = request_with_clerk_env(proxy)

      client.sign_out(request)

      expect(sessions).to have_received(:revoke).with(session_id: "sess_123")
      expect(cookie_jar).to have_received(:delete).with(Clerk::SESSION_COOKIE)
      expect(cookie_jar).to have_received(:delete).with(Clerk::CLIENT_UAT_COOKIE)
    end

    it "still clears local cookies if there is no active Clerk session" do
      proxy = instance_double(Clerk::Proxy, session: nil)
      request = request_with_clerk_env(proxy)

      expect { client.sign_out(request) }.not_to raise_error
      expect(cookie_jar).to have_received(:delete).with(Clerk::SESSION_COOKIE)
    end

    it "clears local cookies even if revoking the remote session fails" do
      sdk = instance_double(Clerk::SDK)
      allow(Clerk::SDK).to receive(:new).and_return(sdk)
      allow(sdk).to receive(:sessions).and_raise(StandardError, "network error")
      proxy = instance_double(Clerk::Proxy, session: { "sid" => "sess_123" })
      request = request_with_clerk_env(proxy)

      expect { client.sign_out(request) }.not_to raise_error
      expect(cookie_jar).to have_received(:delete).with(Clerk::SESSION_COOKIE)
    end
  end
end
