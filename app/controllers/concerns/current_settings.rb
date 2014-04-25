module CurrentSettings
  extend ActiveSupport::Concern

  def change_user_prefs
    # Create default user preferences in session if undefined
    session[:user] ||= Hash[:prefs, {per_page: 10, order_by: 'title'}].with_indifferent_access unless session && session[:user] && session[:user][:prefs]

    session[:user][:prefs].delete_if{|key, val| val.blank?} if session[:user][:prefs] = user_prefs.presence

    # Update user preferences
    @per_page = session[:user][:prefs][:per_page] ||= 10
    @order_by = 'products.' + session[:user][:prefs][:order_by] ||= 'title'
    @desc = session[:user][:prefs][:descending].presence
    @order_by += ' DESC' if @desc
  end

  private

    def user_prefs
      params.slice(:per_page, :order_by, :descending).presence || session[:user][:prefs]
    end
end