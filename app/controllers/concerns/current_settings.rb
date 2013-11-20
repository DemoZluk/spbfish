module CurrentSettings
  extend ActiveSupport::Concern

  included do
  end

  # Define product list for current group
  # if group is present, else list all products
  def current_products
    @group = Group.find_by_permalink(params[:id])

    if @group
      products = @group.all_products(@order_by)
      products = products.reverse_order if @desc
    else
      @order_by += ' DESC' if @desc
      products = Product.all.order(@order_by)
    end
    @products = products.page(params[:page]).per(@per_page)
  end

  def change_user_prefs
    # Create user preferences in session if undefined
    session[:user] ||= Hash[:prefs, {}] unless session && session[:user] && session[:user][:prefs]


    if session[:user][:prefs] = user_prefs.presence
      session[:user][:prefs].delete('descending') unless user_prefs[:descending]
      params.merge! session[:user][:prefs]
    end

    group_filters

    # Update user preferences
    @per_page = session[:user][:prefs]['per_page'] ||= 10
    @order_by = session[:user][:prefs]['order_by'] ||= 'title'
    @desc = session[:user][:prefs]['descending'] ||= nil

    current_products
  end

  private

    def user_prefs
      params.slice(:page, :per_page, :order_by, :descending).presence || session[:user][:prefs]
    end

    def group_filters
      filters = params.except(:page, :per_page, :order_by, :descending, :utf8, :commit, :action, :controller, :id).presence || session[:group]
      params.merge! filters.delete_if { |key, value| value == '' } if filters.presence
    end
end