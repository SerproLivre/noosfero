class LikePluginProfileController < ProfileController
  
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
 
  def like_article
    target = Article.find(params[:id])
    like(target)
  end

  def dislike_article
    target = Article.find(params[:id])
    dislike(target)
  end
 
  def like_comment
    target = Comment.find(params[:id])
    like(target)
  end

  def dislike_comment
    target = Comment.find(params[:id])
    dislike(target)
  end

  protected

  def like(target)
    if target.liked?(user)
      target.unlike(user)
    else
      target.like(user)
    end
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

  def dislike(target)
    if target.disliked?(user)
      target.unlike(user)
    else
      target.dislike(user)
    end
    render :text => {'ok' => true}.to_json, :content_type => 'application/json'
  end

end
