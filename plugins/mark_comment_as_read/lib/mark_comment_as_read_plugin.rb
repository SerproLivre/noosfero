require_dependency 'mark_comment_as_read_plugin/ext/comment'

class MarkCommentAsReadPlugin < Noosfero::Plugin

  def self.plugin_name
    "MarkCommentAsReadPlugin"
  end

  def self.plugin_description
    _("Provide a button to mark a comment as read.")
  end

  def js_files
    'mark_comment_as_read.js'
  end

  def stylesheet?
    true
  end
  
  def comment_actions(comment)
    lambda do
      if user
        if comment.marked_as_read?(user)
#          {:link => link_to_function(_('Mark as not read'), 'mark_comment_as_not_read(this, %s); return false;' % url_for(:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_not_read', :id => comment.id).to_json, :class => 'comment-footer comment-footer-link comment-footer-hide')}
          {:link => link_to_remote(_('Mark as not read'), :url => {:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_not_read', :id => comment.id}, :class => 'comment-footer comment-footer-link comment-footer-hide')}
        else
          {:link => link_to_remote(_('Mark as read'), :url => {:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_read', :id => comment.id}, :class => 'comment-footer comment-footer-link comment-footer-hide')}
        end
      end
    end
  end

  #FIXME make this test
  def comment_extra_contents(comment)
    lambda {"<script type=\"text/javascript\">show_comment_as_read('#{comment.id}');</script>" if comment.marked_as_read?(user)}
  end

end
