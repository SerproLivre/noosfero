require File.dirname(__FILE__) + '/../test_helper'

class CertifierTest < ActiveSupport::TestCase

  should 'have link' do
    certifier = Certifier.new

    assert_equal '', certifier.link

    certifier.link = 'http://noosfero.org'
    assert_equal 'http://noosfero.org', certifier.link
  end

  should 'environment is mandatory' do
    certifier = Certifier.new(:name => 'Certifier without environment')
    assert !certifier.valid?

    certifier.environment = fast_create(Environment)
    assert certifier.valid?
  end

  should 'belongs to environment' do
    env_one = fast_create(Environment)
    certifier_from_env_one = Certifier.create(:name => 'Certifier from environment one', :environment => env_one)

    env_two = fast_create(Environment)
    certifier_from_env_two = Certifier.create(:name => 'Certifier from environment two', :environment => env_two)

    assert_includes env_one.certifiers, certifier_from_env_one
    assert_not_includes env_one.certifiers, certifier_from_env_two
  end

  should 'name is mandatory' do
    env_one = fast_create(Environment)
    certifier = Certifier.new(:environment => env_one)
    assert !certifier.valid?

    certifier.name = 'Certifier name'
    assert certifier.valid?
  end

  should 'sort by name' do
    last = fast_create(Certifier, :name => "Zumm")
    first = fast_create(Certifier, :name => "Atum")
    assert_equal [first, last], Certifier.all.sort
  end

  should 'sorting is not case sensitive' do
    first = fast_create(Certifier, :name => "Aaaa")
    second = fast_create(Certifier, :name => "abbb")
    last = fast_create(Certifier, :name => "Accc")
    assert_equal [first, second, last], Certifier.all.sort
  end

  should 'discard non-ascii char when sorting' do
    first = fast_create(Certifier, :name => "Áaaa")
    last = fast_create(Certifier, :name => "Aáab")
    assert_equal [first, last], Certifier.all.sort
  end

  should 'set qualifier as self-certified when destroyed' do
    pq = mock
    Certifier.any_instance.stubs(:product_qualifiers).returns([pq])
    pq.expects(:update_attributes!).with(:certifier => nil)
    cert = fast_create(Certifier)
    cert.destroy
  end

end
