class Article < ActiveRecord::Base
  validates :permalink, presence: true
  validates :permalink, uniqueness: true

  def to_param
    permalink
  end
end