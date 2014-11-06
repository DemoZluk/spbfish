class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    user ||= User.new # guest user (not logged in)
    roles = user.role?

    if roles.include?('admin')
      can :manage, :all
    else
      if roles.include?('products_manager')
        can :manage, Product
      end
      if roles.include?('content_manager')
        can :manage, Article
        can [:update, :read], Product
      end
      if roles.include?('orders_manager')
        can :manage, Order
        can :manage, Cart
      end
      can [:read], Product.with_price
      can [:read, :update, :destroy, :clear], Cart, user_id: user.id
      can [:create, :show, :update, :cancel], Order, email: user.email
      can [:read, :create, :update, :decrement, :increment, :destroy], LineItem
    end

    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

  end
end
