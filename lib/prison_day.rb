class PrisonDay < Struct.new(:date, :prison)
  WEEKEND_DAYS = %w<sat sun>.freeze

  def staff_working_day?
    non_holiday? && working_day?
  end

  def visiting_day?
    non_blocked_day? && available_day?
  end

  private

  delegate :works_everyday?, :anomalous_dates,
    :visiting_slot_days, :unbookable_dates, to: :prison

  def working_day?
    works_everyday? ? true : weekday?
  end

  def weekday?
    WEEKEND_DAYS.exclude? abbreviated_day_name
  end

  def non_holiday?
    Rails.configuration.bank_holidays.exclude? date
  end

  def anomalous_day?
    anomalous_dates.include? date
  end

  def visiting_slot?
    non_holiday? && visiting_slot_days.include?(abbreviated_day_name)
  end

  def available_day?
    visiting_slot? || anomalous_day?
  end

  def non_blocked_day?
    unbookable_dates.exclude? date
  end

  def abbreviated_day_name
    date.strftime('%a').downcase
  end
end
