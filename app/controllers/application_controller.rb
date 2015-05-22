class ApplicationController < ActionController::Base
  helper_method :visit
  helper_method :smoke_testing?
  before_filter :add_extra_sentry_metadata

  def self.permit_only_from_prisons
    before_filter :reject_untrusted_ips!
  end

  def self.permit_only_from_prisons_or_with_key
    before_filter :reject_untrusted_ips_and_without_key!
  end

  def self.permit_only_with_key
    before_filter :reject_without_key!
  end

  def reject!
    raise ActionController::RoutingError.new('Go away')
  end

  def reject_untrusted_ips!
    unless Rails.configuration.permitted_ips_for_confirmations.include?(request.remote_ip)
      reject!
    end
  end

  def reject_untrusted_ips_and_without_key!
    unless Rails.configuration.metrics_auth_key.secure_compare(params[:key])
      reject_untrusted_ips!
    end
  end

  def reject_without_key!
    unless Rails.configuration.metrics_auth_key.secure_compare(params[:key])
      reject!
    end
  end

  def add_extra_sentry_metadata
    response['X-Request-Id'] = request_id
    Raven.extra_context(request_id: request_id)
    if visit = session[:visit]
      Raven.extra_context(visit_id: visit.visit_id)
      if prison = visit.prisoner.prison_name
        Raven.extra_context(prison: prison)
      end
    end
  end

  def smoke_testing?
    ENV['SMOKE_TESTING_KEY'].secure_compare(request.headers['Smoke-Test'])
  end

  def statsd_increment(counter)
    STATSD_CLIENT.increment(counter) unless smoke_testing?
  end

  def prison_mailer
    smoke_testing? ? SmokeTestPrisonMailer : PrisonMailer
  end

  def visitor_mailer
    smoke_testing? ? SmokeTestVisitorMailer : VisitorMailer
  end

  def metrics_logger
    MetricsLogger.new(smoke_testing?)
  end

  def request_id
    request.env['action_dispatch.request_id']
  end

  def logstasher_add_visit_id(visit_id)
    LogStasher.request_context[:visit_id] = visit_id
    LogStasher.custom_fields << :visit_id
  end

  def logstasher_add_visit_id_from_session
    logstasher_add_visit_id(visit.visit_id)
  end

  def visit
    session[:visit]
  end
end
