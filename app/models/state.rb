class State < ActiveRecord::Base
  validates :state, uniqueness: true
end
