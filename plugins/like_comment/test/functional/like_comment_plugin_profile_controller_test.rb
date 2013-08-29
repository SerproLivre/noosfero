require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/like_comment_plugin_profile_controller'

# Re-raise errors caught by the controller.
class LikeCommentPluginProfileController; def rescue_action(e) raise e end; end

class LikeCommentPluginProfileControllerTest < ActionController::TestCase
  def setup
    @controller = LikeCommentPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('profile').person
    @article = TinyMceArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(LikeCommentPlugin)
    self.stubs(:user).returns(@profile)
  end

  attr_reader :profile, :comment

  should 'like comment' do
    xhr :post, :like, :profile => profile.identifier, :id => comment.id
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'dislike comment' do
    xhr :post, :dislike, :profile => profile.identifier, :id => comment.id
    assert_match /\{\"ok\":true\}/, @response.body
  end

end
