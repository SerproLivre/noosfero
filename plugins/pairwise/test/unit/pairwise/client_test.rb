require "test_helper"

class Pairwise::ClientTest < ActiveSupport::TestCase
  def setup
    pairwise_env_settings = { :api_host => "http://localhost:3030/",
      :username => "abner.oliveira@serpro.gov.br",
      :password => "serpro"
    }
    @client = Pairwise::Client.build('1', pairwise_env_settings)
    @choices = "Choice 1\nChoice 2"
    @question = @client.create_question('Q1', @choices)
  end

  should 'create an new question in pairwise service' do
    assert_not_nil @question.id
  end

  should 'update a question' do
    @question_to_be_changed = @client.create_question('Question 1', @choices)
    @client.update_question(@question_to_be_changed.id, "New name")
    assert_equal "New name", @client.find_question_by_id(@question_to_be_changed.id).name
  end

  should "add new choice to a question" do
    assert_equal 2, @question.get_choices.size
  end

  should 'update a choice text' do
    choice = @question.get_choice_with_text("Choice 1")
    assert_not_nil choice
    @client.update_choice(@question, choice.id, 'Choice Renamed')
    @question_after_change  = @client.find_question_by_id(@question.id)
    assert @question_after_change.has_choice_with_text?("Choice Renamed"), "Choice not found"
    assert ! @question_after_change.has_choice_with_text?("Choice 1"), "Choice 1 should not exist"
  end

  should 'not allow change choice to a blank value' do
    choice = @question.get_choice_with_text("Choice 1")
    assert_not_nil choice
    exception = assert_raises Pairwise::Error do
      @client.update_choice(@question, choice.id, '')
    end
    assert_equal "Empty choice text", exception.message
  end


  should 'retrieve question from service' do
    @question_retrieved = @client.find_question_by_id(@question.id)
    assert_not_nil @question_retrieved
    assert_equal @question.id, @question_retrieved.id
  end

  should 'retrieve question with values correct attributes values' do
    @question_retrieved = @client.find_question_by_id(@question.id)
    assert_equal "Q1", @question_retrieved.name
  end

  should 'retrieve question choices' do
    @question_retrieved = @client.find_question_by_id(@question.id)
    assert_not_nil @question_retrieved.choices
    @question_retrieved.choices.each do | choice |
      assert @choices.include?(choice.data), "Choice #{choice} not found in question retrieved"
    end
  end

  should 'register votes' do
    @question = @client.question_with_prompt(@question.id)
    assert_not_nil @question.prompt
    vote = @client.vote(@question.prompt.id, @question.id, 'left', 'guest-tester', @question.appearance_id)
    assert vote.is_a?(Hash)
    assert_not_nil vote["prompt"], "Next prompt hash expected"
    assert_not_nil vote["prompt"]["id"], "Next prompt id expected"
    assert_not_nil vote["prompt"]["question_id"], "question_id expected"
    assert_not_nil vote["prompt"]["appearance_id"], "appearance_id expected"
    assert_not_nil vote["prompt"]["left_choice_text"], "left_choice_text expected"
    assert_not_nil vote["prompt"]["right_choice_text"], "right_choice_text expected"
  end

  should 'not register votes when appearance_id is missing' do
    @question = @client.question_with_prompt(@question.id)
    assert_not_nil @question.prompt
    exception = assert_raises Pairwise::Error do
      @client.vote(@question.prompt.id, @question.id, 'left', 'guest-tester')
    end
    assert_equal "Vote not registered. Please check if all the necessary parameters were passed.", exception.message
  end
end
