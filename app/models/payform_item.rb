class PayformItem < ActiveRecord::Base

  belongs_to :payform
  belongs_to :payform_item

  delegate :department, :to => :category
  delegate :user, :to => :payform

  validates_presence_of :payform_id, :category_id, :description, :hours, :date



end
