class Rating < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :value, inclusion: 1..5
end
