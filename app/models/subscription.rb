class Subscription < ActiveRecord::Base
  include Tokenable
  belongs_to :mailer
  belongs_to :subscriber, class_name: 'User', primary_key: :email, foreign_key: :email
  validates :email, :mailer_id, presence: true
  validates_uniqueness_of :email, scope: :mailer_id, message: 'Пользователь с таким email уже подписан на эту рассылку'
end
