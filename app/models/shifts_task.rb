class ShiftsTask < ActiveRecord::Base
  named_scope :after_time, lambda { |time| {:conditions => ["created_at > ?", time]}}  
  belongs_to :task
  belongs_to :shift

  # attr_accessor :missed
end