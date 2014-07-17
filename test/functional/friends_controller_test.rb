require File.dirname(__FILE__) + '/../test_helper'
require 'friends_controller'

class FriendsController; def rescue_action(e) raise e end; end

class FriendsControllerTest < ActionController::TestCase

  noosfero_test :profile => 'testuser'

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    self.friend = create_user('thefriend').person
    login_as ('testuser')
  end
  attr_accessor :profile, :friend

  should 'list friends' do
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:friends)
  end

  should 'confirm removal of friend' do
    profile.add_friend(friend)

    get :remove, :id => friend.id
    assert_response :success
    assert_template 'remove'
    ok("must load the friend being removed") { friend == assigns(:friend) }
  end

  should 'actually remove friend' do
    profile.add_friend(friend)

    assert_difference 'Friendship.count', -1 do
      post :remove, :id => friend.id, :confirmation => '1'
      assert_redirected_to :action => 'index'
    end
    assert_equal friend, Profile.find(friend.id)
  end

  should 'display find people button' do
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Find people', :attributes => { :href => '/assets/people' }
  end

  should 'not display invite friends button if any plugin tells not to' do
    class Plugin1 < Noosfero::Plugin
      def remove_invite_friends_button
        true
      end
    end
    class Plugin2 < Noosfero::Plugin
      def remove_invite_friends_button
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    e = profile.environment
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    get :index, :profile => 'testuser'
    assert_no_tag :tag => 'a', :attributes => { :href => "/profile/testuser/invite/friends" }
  end

end
