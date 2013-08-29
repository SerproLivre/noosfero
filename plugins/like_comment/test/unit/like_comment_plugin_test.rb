require File.dirname(__FILE__) + '/../../../../test/test_helper'

class LikeCommentPluginTest < ActiveSupport::TestCase

  ActionController::Base.append_view_path(File.join(File.dirname(__FILE__) + '/../../views'))
  
  include ActionView::Helpers::TagHelper
  include NoosferoTestHelper

  def setup
    @plugin = LikeCommentPlugin.new
    @person = create_user('user').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:source => @article, :author => @person, :body => 'test')
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

  should 'return actions when comment is not liked' do
    action = @plugin.comment_actions(@comment)
    links = self.instance_eval(&action)
    assert_equal 2, links.size
  end

  should 'return actions when comment is liked' do
    @comment.like(@person)
    action = @plugin.comment_actions(@comment)
    links = self.instance_eval(&action)
    assert_equal 2, links.size
  end

  def link_to_function(content, url, options = {})
    link_to(content, url, options)
  end

end
