require File.dirname(__FILE__) + '/../test_helper'

class MembersBlockPluginTest < ActiveSupport::TestCase

  should "return MembersBlock in extra_mlocks class method" do
    assert MembersBlockPlugin.extra_blocks.keys.include?(MembersBlock)
  end

  should "return false for class method has_admin_url?" do
    assert  !MembersBlockPlugin.has_admin_url?
  end

  should "list MembersBlock as a available block for Community" do
    assert MembersBlockPlugin.new.extra_blocks(:type => Community).include?(MembersBlock)
  end

  should "list MembersBlock as a available block for Enterprise" do
    assert MembersBlockPlugin.new.extra_blocks(:type => Enterprise).include?(MembersBlock)
  end

  should "do not list MembersBlock as a available block for Environment" do
    assert !MembersBlockPlugin.new.extra_blocks(:type => Environment).include?(MembersBlock)
  end

  should "list MembersBlock as a block with expire_cache enabled" do
    assert MembersBlockPlugin.new.extra_blocks(:type => :all, :expire_cache => true).include?(MembersBlock)
  end

  should "list MembersBlock as a block with index 3 for default creation position" do
    assert MembersBlockPlugin.new.extra_blocks(:type => :all, :on_creation => 3).include?(MembersBlock)
  end

end
