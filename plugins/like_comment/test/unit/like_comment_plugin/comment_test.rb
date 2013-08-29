require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class LikeCommentPlugin::CommentTest < ActiveSupport::TestCase

  def setup
    @person = create_user('user').person
    @person2 = create_user('user2').person
    @person3 = create_user('user3').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:title => 'title', :body => 'body', :author_id => @person.id, :source => @article)
  end

  should 'like a comment' do
    assert !@comment.liked?(@person)
    @comment.like(@person)
    assert @comment.liked?(@person)
    assert !@comment.disliked?(@person)
  end

  should 'do not like again' do
    @comment.like(@person)
    @comment.like(@person)
    assert_equal 1, @comment.count_likes
  end

  should 'unlike a comment' do
    @comment.like(@person)
    assert @comment.liked?(@person)
    @comment.unlike(@person)
    assert !@comment.liked?(@person)
  end

  should 'dislike a comment' do
    assert !@comment.disliked?(@person)
    @comment.dislike(@person)
    assert !@comment.liked?(@person)
    assert @comment.disliked?(@person)
  end

  should 'do not dislike again' do
    @comment.dislike(@person)
    @comment.dislike(@person)
    assert_equal 1, @comment.count_dislikes
  end

  should 'undislike a comment' do
    @comment.dislike(@person)
    assert @comment.disliked?(@person)
    @comment.unlike(@person)
    assert !@comment.disliked?(@person)
  end

  should 'count comments liked' do
    @comment.like(@person)
    @comment.like(@person2)
    @comment.dislike(@person3)
    assert_equal 2, @comment.count_likes
  end

  should 'count comments disliked' do
    @comment.dislike(@person)
    @comment.dislike(@person2)
    @comment.like(@person3)
    assert_equal 2, @comment.count_dislikes
  end

  should 'dislike a liked comment' do
    @comment.like(@person)
    @comment.dislike(@person)
    assert_equal 0, @comment.count_likes
    assert_equal 1, @comment.count_dislikes
  end

  should 'not like a disliked comment' do
    @comment.dislike(@person)
    @comment.like(@person)
    assert_equal 1, @comment.count_likes
    assert_equal 0, @comment.count_dislikes
  end
end
