class Visit
  include ActiveModel::Model

  MAX_VISITORS = 6
  MAX_SLOTS = 3

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :slots

  validates_size_of :visitors, within: 1..MAX_VISITORS
  validates_size_of :slots, within: 1..MAX_SLOTS
end
