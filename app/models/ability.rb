# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    clear_aliased_actions

    # override cancan default aliasing (we don't want to differentiate between read and index)
    alias_action :delete, to: :destroy
    # alias_action :edit, to: :update
    alias_action :new, to: :create
    alias_action :new_action, to: :create
    alias_action :show, to: :read
    alias_action :index, :read, :edit, to: :display
    alias_action :create, :update, :destroy, to: :modify

    user ||= User.new
    grant_general_permission(user)
    user.roles.each do |role|
      begin
        grant_method = "grant_permissions_to_#{role.name}"
        __send__ grant_method, user
      rescue NoMethodError => e
        Rails.logger.error("ERROR: missing definition for #{role.name}, find me at: #{e.backtrace[0]}")
        next
      end
    end
    # Protect admin and user roles
    cannot %i[update destroy], Role, name: %w[admin super_admin]
  end

  def grant_permissions_to_admin(user)
    grant_general_permission(user)
    can :manage, :inspect_merchants
    can :manage, User
    can :manage, ErrorLog
    can :manage, Agent
    can :manage, :test
  end

  def grant_permissions_to_agent(user)
    can :display, User, partner_id: user.partner_id
  end

  def grant_general_permission(user)
    can :index, Merchant
    can :manage, Merchant, user_id: user.id.to_s
    # do |merchant|
    #   merchant.user_id == user.id.to_s
    # end
  end
end
