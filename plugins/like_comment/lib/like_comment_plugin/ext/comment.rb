require_dependency 'comment'

class Comment

  has_many :liked_comments, :class_name => 'LikeCommentPlugin::LikedComments'
  has_many :people, :through => :liked_comments

  def like(person)
    like_value(person, 1)
  end

  def dislike(person)
    like_value(person, -1)
  end

  def unlike(person)
    like_value(person, 0)
  end

  def liked?(person)
    liked_value?(person, 1)
  end

  def disliked?(person)
    liked_value?(person, -1)
  end

  def count_dislikes
    count_likes_value(-1);
  end
  
  def count_likes
    count_likes_value(1);
  end

  private

  def liked_value?(person, value)
    person && liked_comments.find(:first, :conditions => {:value => value, :person_id => person.id})
  end
  
  def count_likes_value(value)
    liked_comments.count(:conditions => {:value => value, :comment_id => id})
  end

  def like_value(person, value)
    like_comment = LikeCommentPlugin::LikedComments.find(:first, :conditions => {:person_id => person.id, :comment_id => id})
    if like_comment.nil?
      like_comment = LikeCommentPlugin::LikedComments.new(:person => person, :comment => self)
    end
    like_comment.value = value
    like_comment.save!
  end
  
end
