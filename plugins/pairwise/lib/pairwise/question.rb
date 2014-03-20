class Pairwise::Question < ActiveResource::Base
  extend Pairwise::Resource

  self.element_name = "question"

  def get_choices
    Pairwise::Choice.find(:all, :params => {:question_id => self.id })
  end

  def choices_include_inactive
    Pairwise::Choice.find(:all, :params => {:question_id => self.id , :include_inactive => true})
  end

  def choices_inactive_ignore_flagged
    Pairwise::Choice.find(:all, :params => {:question_id => self.id , :inactive_ignore_flagged => true})
  end
  

  def find_choice(id)
    Pairwise::Choice.find(id, :params => {:question_id => self.id, :include_inactive => true })
  end

  alias_method :choices, :get_choices

  def has_choice_with_text?(text)
    return filter_choices_with_text(text).size > 0
  end

  def get_choice_with_text(text)
    choices_selected = filter_choices_with_text(text)
    nil if choices_selected.size == 0
    choices_selected.first
  end

  def filter_choices_with_text(text)
    get_choices.select { |c| c if c.data.eql?(text) }
  end

  # return visitors whom suggested ideas
  def get_ideas_contributors(options=nil)
    options = {:page => 1}
    options.merge!(options) if options.is_a? Hash
    Pairwise::Visitor.find(:all, :params => {:question_id => id, :ideas_count => 1, :page => options[:page]})
  end

  def add_choice(text, visitor=nil)
    if(visitor.nil?)
      Pairwise::Choice.create(:data => text, :question_id => self.id, :active => "true")
    else
      Pairwise::Choice.create(:data => text, :question_id => self.id, :active => "true", :visitor_identifier => visitor)
    end
  end

  def self.find_with_prompt(id, creator_id, visitor_id)#, prompt_id=nil)
     question = Pairwise::Question.find(id,
                   :params => {
                                :creator_id => creator_id,
                                :with_prompt => true,
                                :with_appearance => true,
                                :visitor_identifier => visitor_id
                              })
     question.set_prompt(Pairwise::Prompt.find(question.picked_prompt_id, :params => {:question_id => id}))
     question
  end

  def set_prompt(prompt_object)
    @prompt = prompt_object
  end

  def prompt
    @prompt
  end

  def appearance_id
    if attributes["appearance_id"]
      attributes["appearance_id"]
    elsif prompt and prompt.respond_to? :appearance_id
      prompt.appearance_id
    else
       nil
    end
  end
end