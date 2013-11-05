require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/like_plugin_profile_controller'

# Re-raise errors caught by the controller.
class LikePluginProfileController; def rescue_action(e) raise e end; end

class LikePluginProfileControllerTest < ActionController::TestCase
  def setup
    @controller = LikePluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @profile = create_user('profile').person
    @article = TinyMceArticle.create!(:profile => @profile, :name => 'An article')
    @comment = Comment.new(:source => @article, :author => @profile, :body => 'test')
    @comment.save!
    login_as(@profile.identifier)
    environment = Environment.default
    environment.enable_plugin(LikePlugin)
    self.stubs(:user).returns(@profile)
  end

  attr_reader :profile, :comment

  should 'like comment' do
    xhr :post, :like_comment, :profile => profile.identifier, :id => comment.id
    assert comment.liked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'unlike comment' do
    xhr :post, :like_comment, :profile => profile.identifier, :id => comment.id
    xhr :post, :like_comment, :profile => profile.identifier, :id => comment.id
    assert !comment.liked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'dislike comment' do
    xhr :post, :dislike_comment, :profile => profile.identifier, :id => comment.id
    assert comment.disliked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'undislike comment' do
    xhr :post, :dislike_comment, :profile => profile.identifier, :id => comment.id
    xhr :post, :dislike_comment, :profile => profile.identifier, :id => comment.id
    assert !comment.disliked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'dislike a liked comment' do
    xhr :post, :like_comment, :profile => profile.identifier, :id => comment.id
    xhr :post, :dislike_comment, :profile => profile.identifier, :id => comment.id
    assert comment.disliked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'like a disliked comment' do
    xhr :post, :dislike_comment, :profile => profile.identifier, :id => comment.id
    xhr :post, :like_comment, :profile => profile.identifier, :id => comment.id
    assert comment.liked?(profile)
    assert_match /\{\"ok\":true\}/, @response.body
  end

end
