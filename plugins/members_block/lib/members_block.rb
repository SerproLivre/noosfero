class MembersBlock < ProfileListBlock

  settings_items :visible_role, :type => :string, :default => nil

  def self.description
    _('Members')
  end

  def default_title
    title = role ? role.name : 'members'
    _('{#} %s') % title
  end

  def help
    _('This block presents the members of a collective.')
  end

  def footer
    profile = self.owner
    role_key = visible_role
    lambda do
      link_to _('View all'), :profile => profile.identifier, :controller => 'members_block_plugin_profile', :action => 'members', :role_key => role_key 
    end
  end
  
  def role
    visible_role && !visible_role.empty? ? Role.find_by_key_and_environment_id(visible_role, owner.environment) : nil
  end

  def roles
    Profile::Roles.organization_member_roles(owner.environment)
  end

  def profiles
    role ? owner.members.with_role(role.id) : owner.members
  end

end
