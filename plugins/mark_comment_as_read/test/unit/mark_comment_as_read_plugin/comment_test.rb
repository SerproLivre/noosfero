require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class MarkCommentAsReadPlugin::CommentTest < ActiveSupport::TestCase

  def setup
    @person = create_user('user').person
    @comment = Comment.create!(:title => 'title', :body => 'body', :author_id => @person.id)
  end

  should 'mark comment as read' do
    assert !@comment.marked_as_read?(@person)
    @comment.mark_as_read(@person)
    assert @comment.marked_as_read?(@person)
  end

  should 'do not mark a comment as read again' do
    @comment.mark_as_read(@person)
    assert_raise ActiveRecord::StatementInvalid do
      @comment.mark_as_read(@person)
    end
  end

  should 'mark comment as not read' do
    @comment.mark_as_read(@person)
    assert @comment.marked_as_read?(@person)
    @comment.mark_as_not_read(@person)
    assert !@comment.marked_as_read?(@person)
  end

end
