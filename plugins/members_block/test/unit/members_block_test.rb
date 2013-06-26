require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockTest < ActiveSupport::TestCase

  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, MembersBlock.new
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, MembersBlock.description
  end

  should 'provide a default title' do
    assert_not_equal ProfileListBlock.new.default_title, MembersBlock.new.default_title
  end

  should 'provide link to members page without a visible_role selected' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.save!

    expects(:_).with('View all').returns('View all')
    expects(:link_to).with('View all' , :profile => 'mytestuser', :controller => 'members_block_plugin_profile', :action => 'members', :role_key => block.visible_role).returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
  end

  should 'provide link to members page with a selected role' do
    profile = create_user('mytestuser').person
    block = MembersBlock.new
    block.box = profile.boxes.first
    block.visible_role = 'profile_member'
    block.save!

    expects(:_).with('View all').returns('View all')
    expects(:link_to).with('View all' , :profile => 'mytestuser', :controller => 'members_block_plugin_profile', :action => 'members', :role_key => block.visible_role).returns('link-to-members')

    assert_equal 'link-to-members', instance_eval(&block.footer)
  end

  should 'pick random members' do
    block = MembersBlock.new

    owner = mock
    block.expects(:owner).returns(owner)

    list = []
    owner.expects(:members).returns(list)
    
    assert_same list, block.profiles
  end

  should 'provide a role to be displayed (and default to nil)' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = MembersBlock.new
    assert_equal nil, block.visible_role
    env.boxes.first.blocks << block
    block.visible_role = 'profile_member'
    block.save!
    assert_equal 'profile_member', block.visible_role
  end

  should 'list all' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)
    
    block = MembersBlock.new
    owner = fast_create(Community)
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!
	
    owner.add_member profile1
    owner.add_member profile2
    profiles = block.profiles
    
    assert_includes profiles, profile1
    assert_includes profiles, profile2
  end

  should 'list only profiles with moderator role' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)

    block = MembersBlock.new
    owner = fast_create(Community)
    block.visible_role = Profile::Roles.moderator(owner.environment.id).key
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!
   
    owner.add_member profile2
    owner.add_moderator profile1
    profiles = block.profiles
    
    assert_includes profiles, profile1
    assert_not_includes profiles, profile2
  end

  should 'list only profiles with member role' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Person, :environment_id => env.id)
    profile2 = fast_create(Person, :environment_id => env.id)

    block = MembersBlock.new
    owner = fast_create(Community)
    block.visible_role = Profile::Roles.member(owner.environment.id).key
    block.stubs(:owner).returns(owner)
    env.boxes.first.blocks << block
    block.save!
   
    owner.add_member profile2
    owner.add_moderator profile1
    profiles = block.profiles
    
    assert_not_includes profiles, profile1
    assert_includes profiles, profile2
  end

  should 'list available roles' do
    block = MembersBlock.new
    owner = fast_create(Community)
    block.stubs(:owner).returns(owner)
    assert_includes block.roles, Profile::Roles.member(owner.environment.id)
    assert_includes block.roles, Profile::Roles.admin(owner.environment.id)
    assert_includes block.roles, Profile::Roles.moderator(owner.environment.id)
  end
end

