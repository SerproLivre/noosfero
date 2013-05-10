require File.dirname(__FILE__) + '/../../../../test/test_helper'

class MarkCommentAsReadPluginTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper
  include NoosferoTestHelper

  def setup
    @plugin = MarkCommentAsReadPlugin.new
    @person = create_user('user').person
    article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:source => article, :author => @person, :body => 'test')
    self.stubs(:user).returns(@person)
    self.stubs(:profile).returns(@person)
  end

  attr_reader :plugin, :comment

  should 'show link when person is logged in' do
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert link
  end
  
  should 'do not show link when person is not logged in' do
    self.stubs(:user).returns(nil)
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert !link
  end

  should 'show mark as read link when comment is not read' do
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert_match /mark_as_read/, link[:link]
  end

  should 'show mark as not read link when comment is read' do
    @comment.mark_as_read(@person)
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert_match /mark_as_not_read/, link[:link]
  end

  def link_to_function(content, url, options = {})
    link_to(content, url, options)
  end

end
