require_dependency 'mark_comment_as_read_plugin/ext/comment'

class MarkCommentAsReadPlugin < Noosfero::Plugin

  def self.plugin_name
    "MarkCommentAsReadPlugin"
  end

  def self.plugin_description
    _("Provide a button to mark a comment as read.")
  end
  
  def comment_actions(comment)
    lambda {
      if user
        if comment.marked_as_read?(user)
          {:link => link_to_function(_('Mark as not read'), 'remove_comment(this, %s); return false;' % url_for(:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_not_read', :id => comment.id).to_json, :class => 'comment-footer comment-footer-link comment-footer-hide')}
        else
          {:link => link_to_function(_('Mark as read'), 'remove_comment(this, %s); return false;' % url_for(:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_read', :id => comment.id).to_json, :class => 'comment-footer comment-footer-link comment-footer-hide')}
        end
      end
    } 
  end

end
