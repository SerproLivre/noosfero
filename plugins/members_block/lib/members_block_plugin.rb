require_dependency File.dirname(__FILE__) + '/members_block'
require_dependency 'ext/person'

class MembersBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    "Members Block Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you could choose a role to display profile members.")
  end

  def self.extra_blocks
    {
      MembersBlock => {:type => [Community, Enterprise], :on_creation => 3, :expire_cache => true }
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end

end
