class PairwisePlugin::PairwiseContent < Article
  include ActionView::Helpers::TagHelper
  settings_items :pairwise_question_id
  settings_items :allow_new_ideas, :default => true

  before_save :send_question_to_service

  validate_on_create :validate_choices

  def initialize(*args)
    super(*args)
    self.published = false
  end

  alias_method :original_view_url, :view_url

  def result_url
    profile.url.merge(
                      :controller => :pairwise_plugin_profile,
                     :action => :result,
                      :id => id)
  end

  def self.short_description
    'Pairwise question'
  end

  def self.description
    'Question managed by pairwise'
  end

  def to_html(options = {})
    source = options["source"]
    embeded = options.has_key? "embeded"
    prompt_id = options["prompt_id"]
    pairwise_content = self
    lambda do
      locals = {:pairwise_content =>  pairwise_content, :source => source, :embeded => embeded, :prompt_id => prompt_id }
      render :file => 'content_viewer/prompt.rhtml', :locals => locals
    end
  end

  def pairwise_client
    @pairwise_client ||= Pairwise::Client.build(profile.id, environment.settings[:pairwise_plugin])
    @pairwise_client
  end


  def prepare_prompt(user_identifier, prompt_id=nil)
        question = self.question_with_prompt_for_visitor(user_identifier, prompt_id)
    question
  end

  def question
    begin
      @question ||= pairwise_client.find_question_by_id(pairwise_question_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @question
  end

  def question_with_prompt_for_visitor(visitor='guest', prompt_id=nil)
    pairwise_client.question_with_prompt(pairwise_question_id, visitor, prompt_id)
  end

  def description=(value)
    @description=value
  end

  def description
    begin
      @description ||= question.name
    rescue
      @description = ""
    end
    @description
  end

  def inactive_choices
    if(question)
      @inactive_choices ||= (question.choices_include_inactive - question.get_choices)
    else
      []
    end
  end

  def raw_choices
    @raw_choices ||= question ? question.get_choices : []
  end

  def choices
    if raw_choices.nil?
      @choices = []
    else
      begin
        @choices ||= question.get_choices.map {|q| { q.id.to_s, q.data } }
      rescue
       @choices = []
      end
    end
    @choices
  end

  def choices=(value)
    @choices = value
  end

  def choices_saved
    @choices_saved
  end

  def choices_saved=value
    @choices_saved = value
  end

  def vote_to(prompt_id, direction, visitor, appearance_id)
    raise _("Excepted question not found") if question.nil?
    next_prompt = pairwise_client.vote(question.id, prompt_id, direction, visitor, appearance_id)
    touch #invalidates cache
  end

  def skip_prompt(prompt_id, visitor, appearance_id)
    next_prompt = pairwise_client.skip_prompt(question.id, prompt_id, visitor, appearance_id)
    touch #invalidates cache
  end

   def validate_choices
    errors.add_to_base(_("Choices empty")) if choices.nil?
    errors.add_to_base(_("Choices invalid format")) unless choices.is_a?(Array)
    errors.add_to_base(_("Choices invalid")) if choices.size == 0
    choices.each do | choice |
      if choice.empty?
        errors.add_to_base(_("Choice empty"))
        break
      end
    end
  end

  def update_choice(choice_id, choice_text, active)
    begin
      return pairwise_client.update_choice(question, choice_id, choice_text, active)
    rescue Exception => e
      errors.add_to_base(N_("Choices:") + " " + N_(e.message))
      return false
    end
  end

  def approve_choice(choice_id)
    begin
      return pairwise_client.approve_choice(question, choice_id)
    rescue Exception => e
      errors.add_to_base(N_("Choices:") + " " + N_(e.message))
      return false
    end
  end

  def find_choice id
    return nil if question.nil?
    question.find_choice id
  end

  def toggle_autoactivate_ideas(active_flag)
    pairwise_client.toggle_autoactivate_ideas(question, active_flag)
  end

  def send_question_to_service
    if new_record?
      @question = create_pairwise_question
      toggle_autoactivate_ideas(false)
      self.pairwise_question_id = @question.id
    else
      #add new choices
      unless @choices.nil?
        @choices.each do |choice_text|
          begin
            pairwise_client.add_choice(pairwise_question_id, choice_text) unless choice_text.empty?
          rescue Exception => e
            errors.add_to_base(N_("Choices: Error adding new choice to question") + N_(e.message))
            return false
          end
        end
      end
      #change old choices
      unless @choices_saved.nil?
        @choices_saved.each do |id,data|
          begin
            pairwise_client.update_choice(question, id, data, true)
          rescue Exception => e
            errors.add_to_base(N_("Choices:") + " " + N_(e.message))
            return false
          end
        end
      end
      begin
        pairwise_client.update_question(pairwise_question_id, name)
      rescue Exception => e
        errors.add_to_base(N_("Question not saved:  ") + N_(e.message))
        return false
      end
    end
  end

  def create_pairwise_question
    question = pairwise_client.create_question(name, choices)
    question
  end

  def allow_new_ideas?
    return allow_new_ideas === true
  end

  def add_new_idea(text)
    return false unless allow_new_ideas?
    pairwise_client.add_new_idea(pairwise_question_id, text)
  end
end

