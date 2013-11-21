require File.dirname(__FILE__) + '/../test_helper'

class RawHTMLBlockTest < ActiveSupport::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, RawHTMLBlock.description
  end

  should 'store HTML' do
    block = RawHTMLBlock.new(:html => '<strong>HTML!</strong>')
    assert_equal '<strong>HTML!</strong>', block.html
  end

  should 'not filter HTML' do
    html = '<script type="text/javascript">alert("Hello, world")</script>"'
    block = RawHTMLBlock.new(:html => html)
    assert_equal html, block.html
  end

  should 'return html as content' do
    block = RawHTMLBlock.new(:html => "HTML")
    assert_match(/HTML$/, block.content)
  end

  should 'replace {profile} with profile identifier' do
    profile = Profile.new(:identifier => 'test_profile')
    block = RawHTMLBlock.new(:html => "Profile: {profile}")
    block.stubs(:owner).returns(profile)
    assert_equal 'Profile: test_profile', block.content
  end

  should 'do not replace {profile} if owner is not a profile' do
    environment = fast_create(Environment)
    block = RawHTMLBlock.new(:html => "Profile: {profile}")
    block.stubs(:owner).returns(environment)
    assert_equal 'Profile: {profile}', block.content
  end

end
