class PairwisePluginProfileController < ProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def prompt
    prompt_id = params[:prompt_id]
    pairwise_content = find_content(params)
    embeded = params.has_key?("embeded")
    source = params[:source]
    locals = {:pairwise_content => pairwise_content, :embeded => embeded, :source => source, :prompt_id => prompt_id }
    if embeded
      render 'content_viewer/prompt', :layout => false, :locals => locals
    else
      render 'content_viewer/prompt', :locals => locals
    end
  end

  def choose
    @pairwise_content = find_content(params)
    vote = @pairwise_content.vote_to(params[:prompt_id], params[:direction], user_identifier, params[:appearance_id])
    redirect_to after_action_url
  end

  def skip_prompt
    raise 'Invalid request' unless params.has_key?('prompt_id')
    raise 'Invalid request' unless params.has_key?('appearance_id')
    @pairwise_content = find_content(params)
    reason = params[:reason]
    skip = @pairwise_content.skip_prompt(params[:prompt_id], user_identifier, params[:appearance_id], reason)
    redirect_to after_action_url
  end

  def result
    @embeded = params.has_key?("embeded")
    @page = @pairwise_content = find_content(params)
  end

  def suggest_idea
    flash_target = request.xhr? ? flash.now : flash

    if user.nil?
      flash_tager[:error] = _("Only logged user could suggest new ideas")
    else
      @page = @pairwise_content = find_content(params)
      @embeded = params.has_key?("embeded")
      @source = params[:source]
      begin
        if @page.add_new_idea(params[:idea][:text])
          flash_target[:notice] = _("Thanks for your contributtion!")
        else
          if(@page.allow_new_ideas?)
            flash_target[:error] = _("Unfortunatelly we could register your idea.")
          else
            flash_target[:notice] = _("Unfortunatelly new ideas aren't allowed anymore.")
          end
        end
      rescue Exception => e
        flash_target[:error] = _(e.message)
      end
    end
    if request.xhr?
      render 'suggestion_form'
    else
      redirect_to after_action_url
    end
  end

  protected

  def find_content(params)
    @pairwise_content ||= profile.articles.find(params[:id])
  end

  def after_action_url(prompt_id = nil)
    if params.has_key?("embeded")
      redirect_target = {
        :controller => :pairwise_plugin_profile,
        :action => 'prompt',
        :id => find_content(params).id,
        :question_id => find_content(params).pairwise_question_id,
        :prompt_id => params[:prompt_id],
        :embeded => 1
      }
      if params.has_key?("source")
        redirect_target.merge!(:source => params[:source])
      end
      redirect_target
    else
      find_content(params).url
    end
  end

  def is_external_vote
    params.has_key?("source") && !params[:source].empty?
  end

  def external_source
    params[:source]
  end

  def user_identifier
    if user.nil?
      is_external_vote ? "#{external_source}-#{request.session_options[:id]}" : "participa-#{request.session_options[:id]}"
    else
      user.identifier
    end
  end

  def process_error_message message
    message
  end


  def redirect_to_error_page(message)
    message = URI.escape(CGI.escape(process_error_message(message)),'.')
    redirect_to "/profile/#{profile.identifier}/plugin/pairwise/error_page?message=#{message}"
  end


end
