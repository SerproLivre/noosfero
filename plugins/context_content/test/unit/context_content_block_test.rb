require File.dirname(__FILE__) + '/../test_helper'

class ContextContentBlockTest < ActiveSupport::TestCase

  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
    @block = ContextContentBlock.create!
    @block.types = ['TinyMceArticle']
  end

  should 'describe itself' do
    assert_not_equal Block.description, ContextContentBlock.description
  end

  should 'has a help' do
    assert @block.help
  end

  should 'return nothing if page is nil' do
    assert_equal nil, @block.contents(nil)
  end

  should 'render nothing if it has no content to show' do
    assert_equal '', instance_eval(&@block.content)
  end

  should 'render context content block view' do
    @page = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => @page.id)
    expects(:block_title).with(@block.title).returns('').once
    expects(:content_tag).returns('').once
    expects(:render).with(:file => 'blocks/context_content', :locals => {:block => @block, :contents => [article]})
    instance_eval(&@block.content)
  end

  should 'return children of page' do
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [article], @block.contents(folder)
  end

  should 'limit number of children to display' do
    @block.limit = 2
    folder = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :parent_id => folder.id)
    article2 = fast_create(TinyMceArticle, :parent_id => folder.id)
    article3 = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal 2, @block.contents(folder).length
  end

  should 'return parent children if page has no children' do
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [article], @block.contents(article)
  end

  should 'do not return parent children if show_parent_content is false' do
    @block.show_parent_content = false
    folder = fast_create(Folder)
    article = fast_create(TinyMceArticle, :parent_id => folder.id)
    assert_equal [], @block.contents(article)
  end

  should 'return nil if a page has no parent' do
    folder = fast_create(Folder)
    assert_equal nil, @block.contents(folder)
  end

  should 'return available content types' do
    assert_equal [TinyMceArticle, TextileArticle, RawHTMLArticle, Event, Folder, Blog, UploadedFile, Forum, Gallery, RssFeed], @block.available_content_types
  end

  should 'include plugin content at available content types' do
    class SomePluginContent;end
    class SomePlugin; def content_types; SomePluginContent end end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    assert_equal [TinyMceArticle, TextileArticle, RawHTMLArticle, Event, Folder, Blog, UploadedFile, Forum, Gallery, RssFeed, SomePluginContent], @block.available_content_types
  end

  should 'display thumbnail for image content' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    expects(:image_tag).once
    instance_eval(&@block.content_image(content))
  end

  should 'display div as content image for content that is not a image' do
    content = fast_create(Folder)
    expects(:content_tag).once
    instance_eval(&@block.content_image(content))
  end

  should 'display div with extension class for uploaded file that is not a image' do
    content = UploadedFile.new(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    expects(:content_tag).with('div', '', :class => "context-icon icon-text-plain extension-txt").once
    instance_eval(&@block.content_image(content))
  end

  should 'do not display pagination links if page is nil' do
    @page = nil
    assert_equal '', instance_eval(&@block.footer)
  end

  should 'do not display pagination links if it has until one page' do
    assert_equal '', instance_eval(&@block.footer)
  end

  should 'display pagination links if it has more than one page' do
    @block.limit = 2
    @page = fast_create(Folder)
    article1 = fast_create(TinyMceArticle, :parent_id => @page.id)
    article2 = fast_create(TinyMceArticle, :parent_id => @page.id)
    article3 = fast_create(TinyMceArticle, :parent_id => @page.id)
    expects(:content_tag).once
    expects(:render).with(:partial => 'blocks/more', :locals => {:block => @block, :contents => [article1, article2], :article_id => @page.id}).once
    instance_eval(&@block.footer)
  end

end