require File.dirname(__FILE__) + '/../../../../test/test_helper'

class LikePluginTest < ActiveSupport::TestCase

  ActionController::Base.append_view_path(File.join(File.dirname(__FILE__) + '/../../views'))
  
  include ActionView::Helpers::TagHelper
  include NoosferoTestHelper

  def setup
    @environment = fast_create(Environment)
    @plugin = LikePlugin.new
    @person = create_user('user').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:source => @article, :author => @person, :body => 'test')
    self.stubs(:user).returns(@person)
    self.stubs(:profile).returns(@person)
    self.stubs(:environment).returns(@environment)
  end

  attr_reader :plugin, :comment

  should 'show link when person is logged in' do
    action = @plugin.comment_actions(@comment)
    link = self.instance_eval(&action)
    assert link
  end
  
  should 'show disabled link when person is not logged in' do
    self.stubs(:user).returns(nil)
    action = @plugin.comment_actions(@comment)
    links = self.instance_eval(&action)
    links.collect do |link| 
      assert_match /disabled/, link[:link]
      assert_no_match /onclick/, link[:link]
    end
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

  should 'display actions to like an article' do
    action = @plugin.article_extra_contents(@article)
    link = self.instance_eval(&action)
    assert_match /action-like-#{@article.id}/, link
    assert_match /action-dislike-#{@article.id}/, link
  end

  def link_to_function(content, url, options = {})
    link_to(content, url, options)
  end

end
