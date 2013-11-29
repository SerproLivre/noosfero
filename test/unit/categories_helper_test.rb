require File.dirname(__FILE__) + '/../test_helper'

class CategoriesHelperTest < ActiveSupport::TestCase

  include CategoriesHelper

  def setup
    @environment = Environment.default
  end
  attr_reader :environment
  def _(s); s; end

  should 'generate list of category types for selection' do
    expects(:params).returns({'fieldname' => 'fieldvalue'})
    expects(:options_for_select).with([['General Category', 'Category'],[ 'Product Category', 'ProductCategory'],[ 'Region', 'Region' ]], 'fieldvalue').returns('OPTIONS')
    expects(:select_tag).with('type', 'OPTIONS').returns('TAG')
    expects(:labelled_form_field).with(anything, 'TAG').returns('RESULT')
    
    assert_equal 'RESULT', select_category_type('fieldname')
  end

  should 'return category color if its defined' do
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb')
    assert_equal 'background-color: #fbfbfb;', category_color_style(category1)
  end

  should 'return dont category parent color if category color is not defined' do
    e = fast_create(Environment)
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb', :environment_id => e.id)
    category2 = fast_create(Category, :name => 'education', :display_color => nil, :parent_id => category1.id, :environment_id => e.id)
    assert_equal '', category_color_style(category2)
  end

  should 'return category color if its defined (tree)' do
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb')
    assert_equal 'background-color: #fbfbfb;', category_tree_color_style(category1)
  end

  should 'return category parent color if category color is not defined' do
    e = fast_create(Environment)
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb', :environment_id => e.id)
    category2 = fast_create(Category, :name => 'education', :display_color => nil, :parent_id => category1.id, :environment_id => e.id)
    assert_equal 'background-color: #fbfbfb;', category_tree_color_style(category2)
  end
  
  should 'return "" if the category and upper leves dont have a color defined' do
    e = fast_create(Environment)
    category1 = fast_create(Category, :name => 'education', :display_color => nil, :environment_id => e.id)
    category2 = fast_create(Category, :name => 'education', :display_color => nil, :parent_id => category1.id, :environment_id => e.id)
    category3 = fast_create(Category, :name => 'education', :display_color => nil, :parent_id => category2.id, :environment_id => e.id)
    assert_equal "", category_tree_color_style(category3)
  end
end
