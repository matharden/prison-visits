class Instant::VisitsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include KillswitchGuard

  def update
    VisitorMailer.instant_confirmation_email(visit).deliver

    metrics_logger.record_instant_visit(visit)
    redirect_to instant_show_visit_path
  end

  def show
    render
    reset_session
  end

  def metrics_logger
    METRICS_LOGGER
  end
end