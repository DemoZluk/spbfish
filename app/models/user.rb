class User < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	has_secure_password

  after_destroy :last_user_remains

  private
    def last_user_remains
      if User.count.zero?
        raise I18n.t(:cant_delete_last_user)
      end
    end
end
