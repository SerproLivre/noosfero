class MarkCommentAsReadPluginProfileController < ProfileController
  
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  
  def mark_as_read
    comment = Comment.find(params[:id])
    comment.mark_as_read(user)
    render_comment_partial(comment)
  end

  def mark_as_not_read
    comment = Comment.find(params[:id])
    comment.mark_as_not_read(user)
    render_comment_partial(comment)
  end

  private

  def render_comment_partial(comment)
    render :update do |page|
      page.replace "comment-#{comment.id}", :partial => 'comment/comment.rhtml', :locals => {:comment => comment}
    end
  end

end
