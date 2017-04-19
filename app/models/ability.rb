class Ability
  include CanCan::Ability

	def initialize(user)
    self.clear_aliased_actions

    # override cancan default aliasing (we don't want to differentiate between read and index)
    alias_action :delete, to: :destroy
    #alias_action :edit, to: :update
    alias_action :new, to: :create
    alias_action :new_action, to: :create
    alias_action :show, to: :read
    alias_action :index, :read, :edit, to: :display
    alias_action :create, :update, :destroy, to: :modify

    user ||= User.new
    grant_general_permission(user)
    user.role.each do |role|
      begin
        grant_method = "grant_permissions_to_#{role.name}"
        __send__ grant_method, user
      rescue NoMethodError => e
        Rails.logger.error("ERROR: missing definition for #{role.name}, find me at: #{e.backtrace[0]}")
        next
      end
    end
    # Protect admin and user roles
    cannot [:update, :destroy], Role, name: ['admin', 'super_admin']
  end
  def grant_permissions_to_admin(user)
    grant_general_permission(user)
  end

  def grant_permissions_to_super_admin(user)
  end

  def grant_general_permission(user)
  end
end
