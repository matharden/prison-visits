class APIHelper
  def initialize(wsdl='http://127.0.0.1:8888/ws?wsdl')
    @client = Savon.client(wsdl: wsdl, log: true)
  end

  def check_prisoner_info(prisoner)
    handle_response do
      m = {}.tap do |m|
        m.merge!(prisonerInfo: prisoner_hash(prisoner)) if prisoner
      end

      @client.call(:check_prisoner_info, message: m)
    end
  end

  def get_available_time_slots(prisoner, visitors, start_date, end_date)
    handle_response do
      m = {}.tap do |m|
        m.merge!(prisonerInfo: prisoner_hash(prisoner)) if prisoner
        m.merge!(visitors: visitors.map { |v| visitor_hash(v) }) if visitors && visitors.any?
        m.merge!(startDate: format_date(start_date)) if start_date
        m.merge!(endDate: format_date(end_date)) if end_date
      end

      @client.call(:get_available_time_slots, message: m)
    end
  end

  def book_visit(prisoner, visitors, time_slot)
    handle_response do
      m = {}.tap do |m|
        m.merge!(prisonerInfo: prisoner_hash(prisoner)) if prisoner
        m.merge!(visitors: visitors.map { |v| visitor_hash(v) }) if visitors && visitors.any?
        m.merge!(timeSlot: time_slot_hash(time_slot)) if time_slot
      end

      @client.call(:book_visit, message: m)
    end
  end

  private
  def handle_response(&blk)
    value = blk.call.to_hash
    value.first.last[:return]
  rescue Savon::SOAPFault => f
    if detail = f.to_hash[:fault][:detail]
      detail = detail.first.last
      raise ServiceException.new(detail[:message])
    else
      raise ServiceException.new(f.to_hash[:fault][:faultstring])
    end
  end

  def prisoner_hash(prisoner)
    {
      forename: prisoner.first_name,
      surname: prisoner.last_name,
      dateOfBirth: format_date(prisoner.date_of_birth),
      number: prisoner.number,
      prisonId: Rails.configuration.prison_data[prisoner.prison_name]['nomis_code']
    }
  end

  def visitor_hash(visitor)
    {
      dateOfBirth: format_date(visitor.date_of_birth),
      forename: visitor.first_name,
      surname: visitor.last_name
    }
  end

  def time_slot_hash(ts)
    {
      startTime: ts.start_time,
      endTime: ts.end_time
    }
  end

  def format_date(date)
    date.to_time.iso8601
  end

  class ServiceException < StandardError; end
end
