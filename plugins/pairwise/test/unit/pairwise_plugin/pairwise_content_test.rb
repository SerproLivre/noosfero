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

  should 'send question to pairwise service' do
    question = Pairwise::Question.new(:id => 3, :name => 'Question 1')
    #expectations
    pairwise_content = PairwiseContentFixtures.new_pairwise_content
    pairwise_content.profile = @profile
    pairwise_content.expects(:valid?).returns(true)  
    pairwise_content.expects(:create_pairwise_question).returns(question)
    
    #save should call before_save which sends the question to pairwise
    pairwise_content.save!
    
    #after save pairwise_question_id should store question id generated by pairwise
    assert_equal question.id, pairwise_content.pairwise_question_id
  end 

  should 'call pairwise service to remove if removed' do
    pairwise_question = PairwiseContentFixtures.pairwise_content
    pairwise_question.profile = @profile
    pairwise_question.expects(:call_destroy_in_pairwise).once
    pairwise_question.destroy
  end

  should 'send changes in choices to pairwise service' do
    @pairwise_content.profile = @profile
    @question = Pairwise::Question.new(:id => @pairwise_content.pairwise_question_id, :name => 'Question 1', :active => false)
    @pairwise_content.expects(:question).returns(@question).at_least_once
    @pairwise_content.expects(:pairwise_client).returns(@pairwise_client).at_least_once
    @pairwise_content.expects('new_record?').returns(false).at_least_once
    @pairwise_content.expects('valid?').returns(true).at_least_once
    @pairwise_content.choices = []
    @pairwise_content.choices_saved = {'1' => 'Choice 1', '2' => 'Choice 2'}
    #save should call update_choice in pairwise_client for each choice already saved
    @pairwise_client.expects(:update_choice).returns(true).times(2)
    @pairwise_content.save
  end

  should 'send new choices to pairwise_service' do
    @pairwise_content.profile = @profile

    @question = Pairwise::Question.new(:id => @pairwise_content.pairwise_question_id, :name => 'Question 1', :active => false)  
    @pairwise_content.expects('new_record?').returns(false).at_least_once
    @pairwise_content.expects('valid?').returns(true).at_least_once

    @pairwise_content.expects(:pairwise_client).returns(@pairwise_client).at_least_once

    @pairwise_content.choices = ['New Choice 1', 'New Choice 2']
    @pairwise_content.choices_saved = []

    @pairwise_client.expects(:add_choice).with(@pairwise_content.pairwise_question_id, "New Choice 1")
    @pairwise_client.expects(:add_choice).with(@pairwise_content.pairwise_question_id, "New Choice 2")
    @pairwise_content.save
  end

end