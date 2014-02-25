class PairwisePlugin < Noosfero::Plugin

  def self.plugin_name
    "PairwisePlugin"
  end

  def self.plugin_description
    _("A plugin that add a pairwise client feature to noosfero.")
  end

  # def self.extra_blocks
  #   {
  #      PairwiseBlock => {:type => ['community', 'profile'] }
  #   }
  # end

  def self.extra_blocks
    { PairwisePlugin::QuestionsGroupBlock => {} }
  end

   def control_panel_buttons
    #if context.profile.is_a?(Community)
      {:title => _('Pairwise Question'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'PairwisePlugin::PairwiseContent'}, :icon => 'pairwise' }
    #else
    #  [{:title => _('Mezuro configuration'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ConfigurationContent'}, :icon => 'mezuro' },
    #  {:title => _('Mezuro reading group'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ReadingGroupContent'}, :icon => 'mezuro' }]
    #end
  end

  def content_types
    [PairwisePlugin::PairwiseContent]
    # if context.profile.is_a?(Community)
    # else
    #   []
    # end
  end

  def stylesheet?
    true
  end

end

