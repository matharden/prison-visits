class WebhooksController < ApplicationController
  def email
    if authorized?
      p = ParsedEmail.parse(email_params)
      
      unless p.to.local == 'no-reply'
        statsd_increment('pvb.app.email.unknown_recipient')
        render text: 'Unknown recipient'
        return
      end
      
      case p.source
      when :prison
        statsd_increment('pvb.app.email.autorespond_to_prison')
        PrisonMailer.autorespond(p).deliver
      when :visitor
        statsd_increment('pvb.app.email.autorespon_to_visitor')
        VisitorMailer.autorespond(p).deliver
      end
      
      render text: "Accepted."
    else
      statsd_increment('pvb.app.email.unauthorized')
      render text: "Unauthorized.", status: 403
    end
  rescue ParsedEmail::ParseError, ArgumentError
    render text: "Discarded."
  end

  def email_params
    params.slice(:from, :to, :subject, :text, :charsets)
  end

  def authorized?
    !params[:auth].empty? && ENV['WEBHOOK_AUTH_KEY'].secure_compare(params[:auth])
  end
end
