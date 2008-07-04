require File.dirname(__FILE__) + '/../test_helper'

class ProductsBlockTest < ActiveSupport::TestCase

  def setup
    @block = ProductsBlock.new
  end
  attr_reader :block

  should 'be inherit from block' do
    assert_kind_of Block, block
  end

  should "list owner's products" do

    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')

    block.stubs(:owner).returns(enterprise)


    content = block.content

    assert_tag_in_string content, :content => 'Products'

    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product one/ }
    assert_tag_in_string content, :tag => 'li', :attributes => { :class => 'product' }, :descendant => { :tag => 'a', :content => /product two/ }

  end

  should 'point to all products in footer' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')

    block.stubs(:owner).returns(enterprise)

    footer = block.footer

    assert_tag_in_string footer, :tag => 'a', :attributes => { :href => /\/catalog\/testenterprise$/ }, :content => 'View all'
  end

  should 'list 4 random products by default' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')
    enterprise.products.create!(:name => 'product three')
    enterprise.products.create!(:name => 'product four')
    enterprise.products.create!(:name => 'product five')

    block.stubs(:owner).returns(enterprise)

    assert_equal 4, block.products.size
  end

  should 'list all products if less than 4 by default' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    enterprise.products.create!(:name => 'product one')
    enterprise.products.create!(:name => 'product two')
    enterprise.products.create!(:name => 'product three')

    block.stubs(:owner).returns(enterprise)

    assert_equal 3, block.products.size
  end


  should 'be able to set product_ids and have them listed' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')

    p1 = enterprise.products.create!(:name => 'product one')
    p2 = enterprise.products.create!(:name => 'product two')
    p3 = enterprise.products.create!(:name => 'product three')
    p4 = enterprise.products.create!(:name => 'product four')
    p5 = enterprise.products.create!(:name => 'product five')

    block.stubs(:owner).returns(enterprise)

    block.product_ids = [p1, p3, p5].map(&:id)
    assert_equal [p1, p3, p5], block.products
  end

  should 'save product_ids' do
    enterprise = Enterprise.create!(:name => 'testenterprise', :identifier => 'testenterprise')
    p1 = enterprise.products.create!(:name => 'product one')
    p2 = enterprise.products.create!(:name => 'product two')

    block = ProductsBlock.new
    enterprise.boxes.first.blocks << block
    block.product_ids = [p1.id, p2.id]
    block.save!

    assert_equal [p1.id, p2.id], ProductsBlock.find(block.id).product_ids
  end

end
