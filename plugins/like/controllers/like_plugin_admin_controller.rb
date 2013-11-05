class LikePluginAdminController < AdminController

  def index
    settings = params[:settings]
    settings ||= {}
    settings.each do |k, v|
      settings[k] = v=="1"
    end

    @settings = Noosfero::Plugin::Settings.new(environment, LikePlugin, settings)
    if request.post?
      @settings.save!
      redirect_to :action => 'index'
    end
  end

end
