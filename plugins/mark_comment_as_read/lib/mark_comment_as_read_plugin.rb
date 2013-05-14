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
      [{:link => link_to_remote(_('Mark as not read'), :url => {:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_not_read', :id => comment.id}, :html => {:class => 'comment-footer comment-footer-link comment-footer-hide', :style => 'display: none', :id => "comment-action-mark-as-not-read-#{comment.id}"})},
      {:link => link_to_remote(_('Mark as read'), :url => {:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_read', :id => comment.id}, :html => {:class => 'comment-footer comment-footer-link comment-footer-hide', :style => 'display: none', :id => "comment-action-mark-as-read-#{comment.id}"})}] if user
    end
  end

  def check_comment_actions(comment)
    lambda {comment.marked_as_read?(user) ? "#comment-action-mark-as-not-read-#{comment.id}" : "#comment-action-mark-as-read-#{comment.id}"}
  end

  def user_data_extras
    { :read_comments => [] }
  end

end
