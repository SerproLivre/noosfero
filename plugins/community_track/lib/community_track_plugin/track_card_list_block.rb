class CommunityTrackPlugin::TrackCardListBlock < CommunityTrackPlugin::TrackListBlock

  def self.description
    _('Track Card List')
  end

  def default_title
    _('Relevant Tracks as cards')
  end

  def help
    _('This block displays a list of most relevant tracks as cards.')
  end

  def track_partial
    'track_card'
  end

end
