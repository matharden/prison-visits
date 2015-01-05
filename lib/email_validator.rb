class EmailValidator < ActiveModel::Validator
  BAD_DOMAINS = File.readlines("data/bad_domains.txt").map(&:chomp)

  def validate(record)
    parsed = Mail::Address.new(record.email)
    validate_address_domain(record, parsed) ||
      validate_bad_domain(record, parsed) ||
      validate_address_well_formed(record, parsed) ||
      validate_dns_records(record, parsed) ||
      validate_spam_reporter(record, parsed)
  rescue Mail::Field::ParseError
    set_error(record)
  end

  def has_mx_records(domain)
    Resolv::DNS.new.getresource(domain, Resolv::DNS::Resource::IN::MX)
  rescue Resolv::ResolvError
    false
  rescue Resolv::ResolvTimeout
    true
  end

  def set_error(record)
    record.errors.add(:email, "is not a valid address")
  end

  def maybe_set_error(record, message)
    yield.tap do |value|
      record.errors.add(:email, message) if value
    end
  end

  def validate_address_domain(record, parsed)
    maybe_set_error(record, "is not a valid address because it ends with a dot or starts with a dot") do
      parsed.domain.present? && (parsed.domain.end_with?('.') || parsed.domain.start_with?('.'))
    end
  end

  def validate_spam_reporter(record, parsed)
    maybe_set_error(record, "cannot receive messages from this system") do
      SendgridHelper.spam_reported?(parsed.address)
    end
  end

  def validate_bad_domain(record, parsed)
    maybe_set_error(record, "does not appear to be valid") do
      BAD_DOMAINS.include?(parsed.domain)
    end
  end

  def validate_address_well_formed(record, parsed)
    maybe_set_error(record, "is not a valid address") do
      not (parsed.local &&
           parsed.domain &&
           parsed.address == record.email &&
           parsed.local != record.email)
    end
  end

  def validate_dns_records(record, parsed)
    maybe_set_error(record, "does not appear to be valid") do
      not has_mx_records(parsed.domain)
    end
  end
end
