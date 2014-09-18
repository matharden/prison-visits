class VisitMetricsEntry < ActiveRecord::Base
  validates_presence_of :visit_id, :prison_name, :requested_at

  def processed?
    if block_given?
      yield if outcome
    else
      outcome
    end
  end

  def rejected?
    yield if outcome == 'rejected'
  end

  def confirmed?
    yield if outcome == 'confirmed'
  end
end