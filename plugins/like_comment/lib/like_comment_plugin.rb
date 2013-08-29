require_dependency 'like_comment_plugin/ext/comment'

class LikeCommentPlugin < Noosfero::Plugin

  def self.plugin_name
    "LikeCommentPlugin"
  end

  def self.plugin_description
    _("Provide a button to like a comment.")
  end

  def stylesheet?
    true
  end

  def js_files
    'like_comment.js'
  end
  
  def comment_actions(comment)
    lambda do
      url_like = url_for(:controller => 'like_comment_plugin_profile', :profile => profile.identifier, :action => 'like', :id => comment.id)
      url_dislike = url_for(:controller => 'like_comment_plugin_profile', :profile => profile.identifier, :action => 'dislike', :id => comment.id)
      [{:link => render(:partial => 'like_comment/dislike.rhtml', :locals => {:comment => comment, :url => url_dislike, :active => comment.disliked?(profile)}), :action_bar => true}, 
      {:link => render(:partial => 'like_comment/like.rhtml', :locals => {:comment => comment, :url => url_like, :active => comment.liked?(profile)}), :action_bar => true}] if user 
    end
  end

end
