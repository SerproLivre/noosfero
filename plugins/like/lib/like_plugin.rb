class LikePlugin < Noosfero::Plugin
  
  def self.plugin_name
    "Like Plugin"
  end

  def self.plugin_description
    _("Provide buttons to like/dislike a articles and comments.")
  end

  def stylesheet?
    true
  end

  def js_files
    'like_actions.js'
  end

  def self.enable_like_article_default_setting
    true
  end

  def self.enable_like_comment_default_setting
    true
  end
 
  def comment_actions(comment)
    like = like_partial(comment)
    dislike = like_partial(comment, false)
    lambda do
      [{:link => instance_eval(&dislike), :action_bar => true}, {:link => instance_eval(&like), :action_bar => true}]
    end
  end

  def article_extra_contents(article)
    like = like_partial(article)
    dislike = like_partial(article, false)
    lambda do
      content_tag('div', instance_eval(&dislike) + instance_eval(&like), :class => 'like-actions')
    end
  end

  protected

  def like_partial(target, like = true)
    lambda do
      settings = Noosfero::Plugin::Settings.new(environment, LikePlugin)
      type = target.kind_of?(Article) ? 'article' : target.kind_of?(Comment) ? 'comment' : nil
      if settings.get_setting("enable_like_#{type}")
        like_action = like ? 'like' : 'dislike'
        enabled = !user.nil?
        url = url_for(:controller => 'like_plugin_profile', :profile => profile.identifier, :action => "#{like_action}_#{type}", :id => target.id)
        render(:partial => 'like/like.rhtml', :locals => {:target => target, :url => url, :active => like ? target.liked?(user) : target.disliked?(user), :action => like_action, :count => like ? target.count_likes : target.count_dislikes, :enabled => enabled})
      else
        ""
      end
    end
  end

end
