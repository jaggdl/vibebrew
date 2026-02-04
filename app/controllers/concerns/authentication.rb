module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :set_current_team
    before_action :require_team

    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :require_team
    end
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to User.exists? ? new_session_path : new_signup_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end

  def set_current_team
    return unless authenticated?

    team_id = session[:current_team_id]

    if team_id.present?
      Current.team = Current.user.teams.find_by(id: team_id)
    end

    Current.team ||= Current.user.teams.first

    if Current.team
      Current.membership = Membership.find_by(user: Current.user, team: Current.team)
    end
  end

  def require_team
    return if Current.team.present?

    if Current.user.teams.empty?
      redirect_to new_team_path, notice: "Please create a team to get started"
    else
      redirect_to teams_path, notice: "Please select a team"
    end
  end
end
