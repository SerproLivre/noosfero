require "test_helper"

require "#{RAILS_ROOT}/plugins/pairwise/test/fixtures/pairwise_content_fixtures"


class PairwisePlugin::PairwiseContentTest < ActiveSupport::TestCase

 fixtures :environments

  def setup
     pairwise_env_settings = { "api_host" => "http://localhost:3030/",
                                "username" => "abner.oliveira@serpro.gov.br", 
                                "password" => "serpro"
                              }
    @profile = create_user('testing').person
    @profile.environment = environments(:colivre_net)
    @pairwise_client = Pairwise::Client.build(1, pairwise_env_settings)
    @pairwise_content = PairwiseContentFixtures.pairwise_content
  end

  should 'be inactive when created' do
    assert_equal false, @pairwise_content.published?
  end

  # should 'activate question' do
  #   @question = Pairwise::Question.new(:id => @pairwise_content.pairwise_question_id, :name => 'Question 1', :active => false)  
    
  #   #setting pairwise_question
  #   @pairwise_content.profile = @profile

  #   #pretend it is not a new record
  #   @pairwise_content.expects('new_record?').returns(false).at_least_once

  #   #mocking to not call client to get the quest
  #   @pairwise_content.expects(:question).returns(@question).at_least_once

  #   #mocking pairwise_client
  #   @pairwise_content.expects(:pairwise_client).returns(@pairwise_client)

  #   #activating pairwise_content
  #   @pairwise_content.pairwise_question_active = true

  #   #expecting activate to be called in client passing question 
  #   # because the pairwise content pairwise_question_active changed to true
  #   @pairwise_client.expects(:activate).with(@question)

  #   #calling to save in pairwise content so the before save will call 
  #   #pairwise service through pairwise client to activate the question
  #   @pairwise_content.save!
  # end

  should 'provide proper short description' do
    assert_equal 'Pairwise question', PairwisePlugin::PairwiseContent.short_description
  end

  should 'provide proper description' do
    assert_equal 'Question managed by pairwise', PairwisePlugin::PairwiseContent.description
  end

  should 'have an html view' do
    assert_not_nil @pairwise_content.to_html
  end

  should 'get question from pairwise service' do
    @question = Pairwise::Question.new(:id => @pairwise_content.pairwise_question_id, :name => 'Question 1')
    @pairwise_client.expects(:find_question_by_id).with(@question.id).returns(@question)
    @pairwise_content.expects(:pairwise_client).returns(@pairwise_client)
    assert_equal @question, @pairwise_content.question
  end

  should 'add error to base when the question does not exist' do
    Response = Struct.new(:code, :message)   

    @response = Response.new(422, "Any error")

    @pairwise_client.expects(:find_question_by_id).with(@pairwise_content.pairwise_question_id).raises(ActiveResource::ResourceNotFound.new(@response))

    @pairwise_content.expects(:pairwise_client).returns(@pairwise_client)
    assert_nil @pairwise_content.errors[:base]
    @pairwise_content.question

    assert_not_nil @pairwise_content.errors[:base]
    assert_equal 'Failed with 422 Any error', @pairwise_content.errors[:base]
  end

end
