class SmokeTestVisitorMailer < VisitorMailer
  def self.smtp_settings
    {
      address: ENV['SMOKE_TEST_SMTP_HOSTNAME'],
      port: ENV['SMOKE_TEST_SMTP_PORT']
    }
  end

  def mail(options)
    super(options.merge(template_path: 'visitor_mailer'))
  end
end
