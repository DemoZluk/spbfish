class Article < ActiveRecord::Base
  validates :alias, uniqueness: true
end