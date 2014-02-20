require 'test_helper'

require "#{RAILS_ROOT}/plugins/pairwise/test/fixtures/pairwise_content_fixtures"

class PairwisePluginProfileControllerTest < ActionController::TestCase

  def pairwise_env_settings
    { :api_host => "http://localhost:3030/",
      :username => "abner.oliveira@serpro.gov.br",
      :password => "serpro"
    }
  end

  def setup
    @environment = Environment.default
  
    @pairwise_client = Pairwise::Client.build(1, pairwise_env_settings)
    @controller = PairwisePluginProfileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
   
    @profile = fast_create(Community, :environment_id => @environment.id)
    @question = PairwiseContentFixtures.pairwise_question_with_prompt
    @user = create_user('testinguser').person
    @profile.add_admin(@user)
    @content =  PairwiseContentFixtures.pairwise_content
    @profile.articles << @content
  end

  should 'get a first prompt' do
    login_as(@user.user.login)
    PairwisePluginProfileController.any_instance.expects(:find_content).returns(@content)
    @content.expects(:question_with_prompt_for_visitor).with(@user.identifier, nil).returns(@question)
    get :prompt, 
                  :profile => @profile.identifier, 
                  :id => @content.id,
                  :question_id => @question.id         
    assert_not_nil  assigns(:page)
    assert_match /#{@question.name}/, @response.body
    assert_match /#{@question.prompt.left_choice_text}/, @response.body
    assert_match /#{@question.prompt.right_choice_text}/, @response.body
  end

  should 'get a prompt by a prompt id' do
    login_as(@user.user.login)
    PairwisePluginProfileController.any_instance.expects(:find_content).returns(@content)
    @content.expects(:question_with_prompt_for_visitor).with(@user.identifier, @question.prompt.id.to_s).returns(@question)
    get :prompt, 
                  :profile => @profile.identifier, 
                  :id => @content.id,
                  :question_id => @question.id,
                  :prompt_id => @question.prompt.id         
    
    assert_not_nil  assigns(:page)
    
    assert_match /#{@question.name}/, @response.body
    assert_match /#{@question.prompt.left_choice_text}/, @response.body
    assert_match /#{@question.prompt.right_choice_text}/, @response.body
  end

  should 'register a vote' do
    login_as(@user.user.login)
    #next prompt will have id = 33
    next_prompt_id = 33
    vote = { 
                'prompt' => {
                        "id" => next_prompt_id,
                        "left_choice_id" => 3,
                        "left_choice_test" => "Option 3",
                        "right_choice_id" => 4,
                        "right_choice_text" => "Option 4"
              }
            }
    @content.expects(:vote_to).with(@question.prompt.id.to_s, 'left', @user.identifier, @question.appearance_id).returns(vote).at_least_once
    #@content.expects(:question_with_prompt_for_visitor).with(@user.identifier, nil).returns(@question).at_least_once

    PairwisePluginProfileController.any_instance.expects(:find_content).returns(@content).at_least_once
    
    get :choose, 
                  :profile => @profile.identifier,
                  :id => @content.id,
                  :question_id => @question.id,
                  :prompt_id => @question.prompt.id,
                  :appearance_id => @question.appearance_id,
                  :direction => 'left'
    assert_response :redirect
    assert_redirected_to @content.url
  end

  should 'show new ideas elements when new ideas were not allowed' do
    login_as(@user.user.login)
    PairwisePluginProfileController.any_instance.expects(:find_content).returns(@content)
    @content.expects(:question_with_prompt_for_visitor).with(@user.identifier, @question.prompt.id.to_s).returns(@question)
    get :prompt,
                  :profile => @profile.identifier,
                  :id => @content.id,
                  :question_id => @question.id,
                  :prompt_id => @question.prompt.id
    assert_not_nil  assigns(:page)

    assert_select "div[class='show_new_idea_box']", 1
    assert_select "div#suggestions_box", 1
  end

  should 'not show new ideas elements when new ideas were not allowed' do
    login_as(@user.user.login)
    @content.allow_new_ideas = false
    PairwisePluginProfileController.any_instance.expects(:find_content).returns(@content)
    @content.expects(:question_with_prompt_for_visitor).with(@user.identifier, @question.prompt.id.to_s).returns(@question)
    get :prompt,
                  :profile => @profile.identifier,
                  :id => @content.id,
                  :question_id => @question.id,
                  :prompt_id => @question.prompt.id
    assert_not_nil  assigns(:page)

    assert_select "div[class='show_new_idea_box']", 0
    assert_select "div#suggestions_box", 0
  end
end