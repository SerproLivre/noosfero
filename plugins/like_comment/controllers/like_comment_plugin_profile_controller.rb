class LikeCommentPluginProfileController < ProfileController
  
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  
  def like
    comment = Comment.find(params[:id])
    if comment.liked?(user)
      comment.unlike(user)
    else
      comment.like(user)
    end
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

  def dislike
    comment = Comment.find(params[:id])
    if comment.disliked?(user)
      comment.unlike(user)
    else
      comment.dislike(user)
    end
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

end
