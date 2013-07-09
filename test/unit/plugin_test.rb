require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
  end
  attr_reader :environment

  include Noosfero::Plugin::HotSpot

  should 'keep the list of all loaded subclasses' do
    class Plugin1 < Noosfero::Plugin
    end

    class Plugin2 < Noosfero::Plugin
    end

    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
    assert_includes  Noosfero::Plugin.all, Plugin2.to_s
  end

  should 'returns url to plugin management if plugin has admin_controller' do
    class Plugin1 < Noosfero::Plugin
    end
    File.stubs(:exists?).with(anything).returns(true)

    assert_equal({:controller => 'plugin_test/plugin1_admin', :action => 'index'}, Plugin1.admin_url)
  end

  should 'register its macros in the environment when instantiated' do
    class Plugin1 < Noosfero::Plugin
      def macro_example1(params, inner_html, source)
      end

      def example2(params, inner_html, source)
      end

      def not_macro
      end

      def macro_methods
        ['macro_example1', 'example2']
      end
    end
    
    Environment.macros = {}
    Environment.macros[environment.id] = {}
    macros = Environment.macros[environment.id]
    context = mock()
    context.stubs(:environment).returns(environment)

    plugin_instance = Plugin1.new(context)

    assert_equal plugin_instance, macros['macro_example1']
    assert_equal plugin_instance, macros['example2']
    assert_nil macros['not_macro']
  end

  should 'load_comments return nil by default' do

    class Plugin1 < Noosfero::Plugin; end;

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s])

    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    assert_nil plugins.dispatch_first(:load_comments, a)
  end

  should 'load_comments return the value defined by plugin' do

    class Plugin1 < Noosfero::Plugin
      def load_comments(page)
        'some value'
      end
    end

    environment.stubs(:enabled_plugins).returns([Plugin1.to_s])

    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    assert_equal 'some value', plugins.dispatch_first(:load_comments, a)
  end

  should 'returns empty hash for class method extra_blocks by default if no blocks are defined on plugin' do
    
    class SomePlugin1 < Noosfero::Plugin
    end

    assert_equal({}, SomePlugin1.extra_blocks)
  end

  should 'returns empty array for instance method extra_blocks by default if no blocks are defined on plugin' do
    class Plugin1 < Noosfero::Plugin
       def self.extra_blocks
       end
    end
    p = Plugin1.new
    assert_equal([], p.extra_blocks)
  end

  should 'returns empty array for instance method extra_blocks by default if nil is returned' do
    class Plugin1 < Noosfero::Plugin
       def self.extra_blocks
         nil
       end
    end
    p = Plugin1.new
    assert_equal([], p.extra_blocks)
  end

  should 'returns the blocks implemented by plugin' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {},
          CustomBlock2 => {}
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks)
    assert_equal([], p.extra_blocks - [CustomBlock1, CustomBlock2])
  end

  should 'returns only person block and non defined types block if type person is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'person'},
          CustomBlock2 => {},
          CustomBlock3 => {:type => 'enterprise'},
          CustomBlock4 => {:type => 'community'},
          CustomBlock5 => {:type => 'environment'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Person))
    assert_equal([],  p.extra_blocks(:type => Person) - [CustomBlock1, CustomBlock2])
  end

  should 'returns only community block and non defined types block if type community is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'community'},
          CustomBlock2 => {},
          CustomBlock3 => {:type => 'person'},
          CustomBlock4 => {:type => 'enterprise'},
          CustomBlock5 => {:type => 'environment'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Community))
    assert_equal([],  p.extra_blocks(:type => Community) - [CustomBlock1, CustomBlock2])
  end

  should 'returns only enterprise block and non defined types block if type enterprise is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'enterprise'},
          CustomBlock2 => {},
          CustomBlock3 => {:type => 'person'},
          CustomBlock4 => {:type => 'community'},
          CustomBlock5 => {:type => 'environment'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Enterprise))
    assert_equal([],  p.extra_blocks(:type => Enterprise) - [CustomBlock1, CustomBlock2])
  end

  should 'returns only environment block and non defined types block if type environment is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'environment'},
          CustomBlock2 => {},
          CustomBlock3 => {:type => 'enterprise'},
          CustomBlock4 => {:type => 'community'},
          CustomBlock5 => {:type => 'person'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Environment))
    assert_equal([],  p.extra_blocks(:type => Environment) - [CustomBlock1, CustomBlock2])
  end

  should 'returns array of blocks of a specified type' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'person'},
          CustomBlock2 => {:type => 'person'},
          CustomBlock3 => {:type => 'environment'},
          CustomBlock4 => {:type => 'enterprise'},
          CustomBlock5 => {:type => 'community'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Person))
    assert_equal([], p.extra_blocks(:type => Person) - [CustomBlock1, CustomBlock2])
  end

  should 'returns all blocks without type if no type is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;
    class CustomBlock6 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'person'},
          CustomBlock2 => {:type => 'environment'},
          CustomBlock3 => {:type => 'enterprise'},
          CustomBlock4 => {:type => 'community'},
          CustomBlock5 => {},
          CustomBlock6 => {},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock5, CustomBlock6] - p.extra_blocks)
    assert_equal([], p.extra_blocks - [CustomBlock5, CustomBlock6])
  end

  should 'returns all blocks if type all is specified as parameter' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;
    class CustomBlock6 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'person'},
          CustomBlock2 => {:type => 'environment'},
          CustomBlock3 => {:type => 'enterprise'},
          CustomBlock4 => {:type => 'community'},
          CustomBlock5 => {},
          CustomBlock6 => {},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4, CustomBlock5, CustomBlock6] - p.extra_blocks(:type => :all))
    assert_equal([], p.extra_blocks(:type => :all) - [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4, CustomBlock5, CustomBlock6])
  end


  should 'returns blocks of specified types' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => ['person', 'environment']},
          CustomBlock2 => {:type => 'environment'},
          CustomBlock3 => {:type => 'enterprise'},
          CustomBlock4 => {:type => 'community'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:type => Environment))
    assert_equal([], p.extra_blocks(:type => Environment) - [CustomBlock1, CustomBlock2])
  end

  should 'returns blocks of with types passed as string or constant' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => ['person', 'environment']},
          CustomBlock2 => {:type => 'environment'},
          CustomBlock3 => {:type => Environment},
          CustomBlock4 => {:type => [Environment]},
          CustomBlock5 => {:type => 'person'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4] - p.extra_blocks(:type => Environment))
    assert_equal([], p.extra_blocks(:type => Environment) - [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4])
  end

  should 'through exception if undefined type is specified as parameter' do
    class CustomBlock1 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'undefined_type'},
        }
      end
    end
    p = Plugin1.new

    assert_raise NameError do
      p.extra_blocks
    end
  end

  should 'returns only position 1 block and non defined position block if position 1 is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => 1},
          CustomBlock2 => {},
          CustomBlock3 => {:position => 3},
          CustomBlock4 => {:position => 2},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:position => 1))
    assert_equal([],  p.extra_blocks(:position => 1) - [CustomBlock1, CustomBlock2])
  end

  should 'returns only position 2 block and non defined position block if position 2 is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => 2},
          CustomBlock2 => {},
          CustomBlock3 => {:position => 3},
          CustomBlock4 => {:position => 1},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:position => 2))
    assert_equal([],  p.extra_blocks(:position => 2) - [CustomBlock1, CustomBlock2])
  end

  should 'returns only position 3 block and non defined position block if position 3 is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => 3},
          CustomBlock2 => {},
          CustomBlock3 => {:position => 1},
          CustomBlock4 => {:position => 2},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:position => 3))
    assert_equal([],  p.extra_blocks(:position => 3) - [CustomBlock1, CustomBlock2])
  end

  should 'returns array of blocks of a specified position' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => 1 },
          CustomBlock2 => {:position => 1 },
          CustomBlock3 => {:position => 2},
          CustomBlock4 => {:position => 3},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:position => 1))
    assert_equal([], p.extra_blocks(:position => 1) - [CustomBlock1, CustomBlock2])
  end

  should 'returns array of blocks of a specified position wihout any type' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;
    class CustomBlock6 < Block; end;
    class CustomBlock7 < Block; end;
    class CustomBlock8 < Block; end;
    class CustomBlock9 < Block; end;
    class CustomBlock10 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => Person, :position => 1 },
          CustomBlock2 => {:type => Community, :position => 1 },
          CustomBlock3 => {:type => Enterprise, :position => 1 },
          CustomBlock4 => {:type => Environment, :position => 1 },
          CustomBlock5 => {:position => 1 },
          CustomBlock6 => {:type => Person, :position => [1,2,3] },
          CustomBlock7 => {:type => Community, :position => [1,2,3] },
          CustomBlock8 => {:type => Enterprise, :position => [1,2,3] },
          CustomBlock9 => {:type => Environment, :position => [1,2,3] },
          CustomBlock10 => {:position => [1,2,3] },
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock5, CustomBlock10] - p.extra_blocks(:position => 1))
    assert_equal([], p.extra_blocks(:position => 1) - [CustomBlock5, CustomBlock10])
  end

  should 'returns blocks of all position if no position is specified' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => 1 },
          CustomBlock2 => {:position => 2},
          CustomBlock3 => {:position => 3},
          CustomBlock4 => {},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4] - p.extra_blocks)
    assert_equal([], p.extra_blocks - [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4])
  end

  should 'returns blocks of specified positions' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => [1, 2]},
          CustomBlock2 => {:position => 2},
          CustomBlock3 => {:position => 3},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks(:position => 2))
    assert_equal([], p.extra_blocks(:position => 2) - [CustomBlock1, CustomBlock2])
  end

  should 'returns blocks of with positions passed as string or numbers' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;
    class CustomBlock4 < Block; end;
    class CustomBlock5 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:position => [1, '2']},
          CustomBlock2 => {:position => '2'},
          CustomBlock3 => {:position => 2},
          CustomBlock4 => {:position => [2]},
          CustomBlock5 => {:position => '1'},
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4] - p.extra_blocks(:position => 2))
    assert_equal([], p.extra_blocks(:position => 2) - [CustomBlock1, CustomBlock2, CustomBlock3, CustomBlock4])
  end

  should 'through exception if undefined position is specified as parameter' do
    class CustomBlock1 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:type => 'undefined_type'},
        }
      end
    end
    p = Plugin1.new

    assert_raise NameError do
      p.extra_blocks
    end
  end

  should 'returns array of blocks of a specified on_creation parameter' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:on_creation => 1},
          CustomBlock2 => {:on_creation => 2},
          CustomBlock3 => {:on_creation => 3},
        }
      end
    end
    p = Plugin1.new
    assert_equal([CustomBlock1], p.extra_blocks(:on_creation => 1))
    assert_equal([CustomBlock2], p.extra_blocks(:on_creation => 2))
    assert_equal([CustomBlock3], p.extra_blocks(:on_creation => 3))
  end

  should 'comment_actions be nil if the comment is nil' do
    class SomePlugin < Noosfero::Plugin; end
    plugin = SomePlugin.new
    assert_nil plugin.comment_actions(nil)
  end

  should 'comment_actions be nil by default' do
    class SomePlugin < Noosfero::Plugin; end
    plugin = SomePlugin.new
    assert_nil plugin.comment_actions(Comment.new)
  end

  should 'check_comment_actions be an empty array if the comment is nil' do
    class SomePlugin < Noosfero::Plugin; end
    plugin = SomePlugin.new
    assert_equal [], plugin.check_comment_actions(nil)
  end


  should 'check_comment_actions be  an empty array by default' do
    class SomePlugin < Noosfero::Plugin; end
    plugin = SomePlugin.new
    assert_equal [], plugin.check_comment_actions(Comment.new)
  end

  should 'not return a block without on_creation parameter if on_creation parameter is defined' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:on_creation => 1},
          CustomBlock2 => {}
        }
      end
    end
    p = Plugin1.new
    assert_equal([CustomBlock1], p.extra_blocks(:on_creation => 1))
  end

  should 'not return a block with on_creation parameter nil if on_creation parameter is defined' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:on_creation => 1},
          CustomBlock2 => {:on_creation => nil}
        }
      end
    end
    p = Plugin1.new
    assert_equal([CustomBlock1], p.extra_blocks(:on_creation => 1))
  end

  should 'not take in consideration on_creation parameter if its not defined as parameter' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:on_creation => 2},
          CustomBlock2 => {}
        }
      end
    end
    p = Plugin1.new
    assert_equal([], [CustomBlock1, CustomBlock2] - p.extra_blocks)
  end

  should 'returns array of blocks for expire_cache = true parameter' do
    class CustomBlock1 < Block; end;
    class CustomBlock2 < Block; end;
    class CustomBlock3 < Block; end;

    class Plugin1 < Noosfero::Plugin
      def self.extra_blocks
        {
          CustomBlock1 => {:expire_cache => true},
          CustomBlock2 => {:expire_cache => false},
          CustomBlock3 => {},
        }
      end
    end
    p = Plugin1.new
    assert_equal([CustomBlock1], p.extra_blocks(:expire_cache => true))
    assert_equal([], [CustomBlock2, CustomBlock3] - p.extra_blocks(:expire_cache => false))
    assert_equal([], [CustomBlock1, CustomBlock2, CustomBlock3] - p.extra_blocks)
  end

end
