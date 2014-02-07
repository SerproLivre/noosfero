class PairwisePluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def find_content(params)
    profile.articles.find(params[:id])
  end

  def prompt
    prompt_id = params[:prompt_id]
    @pairwise_content = find_content(params)
    @question = @pairwise_content.question_with_prompt_for_visitor(user_identifier, prompt_id)
    @prompt = @question.prompt
    @embeded = params.has_key?("embeded")
    return render :prompt, :layout => false if @embeded
  end

  def choose
    @pairwise_content = find_content(params)
    @question = @pairwise_content.question_with_prompt_for_visitor(user_identifier)
    visitor = user_identifier
    vote = @pairwise_content.vote_to(@question, params[:direction], visitor)
    next_prompt = vote['prompt']
    redirect_target = { :controller => :pairwise_plugin_profile,:action => 'prompt', :id => @pairwise_content.id,  :question_id => @question.id , :prompt_id => next_prompt["id"]}
    redirect_target.merge!(:embeded => 1) if params.has_key?("embeded")
    redirect_to redirect_target
  end

  def show_question
    @embeded = params.has_key?("embeded")
    @article = @pairwise_content = find_content(params)
  end

 protected

   def user_identifier
     if user.nil?
       "guest-#{request.session_options[:id]}"
     else
       user.identifier
     end
   end

  def process_error_message message
    # if message =~ /undefined method `module' for nil:NilClass/
    #   "Kalibro did not return any result. Verify if the selected configuration is correct."
    # else
    #   message
    # end
    message
  end


  def redirect_to_error_page(message)
    message = URI.escape(CGI.escape(process_error_message(message)),'.')
    redirect_to "/profile/#{profile.identifier}/plugin/pairwise/error_page?message=#{message}"
  end


end

