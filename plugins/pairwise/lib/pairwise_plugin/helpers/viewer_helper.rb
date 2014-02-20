module PairwisePlugin::Helpers::ViewerHelper

  def pairwise_plugin_stylesheet
    plugin_style_sheet_path = PairwisePlugin.public_path('style.css')
    stylesheet_link_tag  plugin_style_sheet_path, :cache => "cache/plugins-#{Digest::MD5.hexdigest plugin_style_sheet_path.to_s}"
  end

  def choose_left_link(pairwise_content, question, prompt, embeded = false, source = nil, appearance_id = nil)
    link_target = {:controller => 'pairwise_plugin_profile',
          :action => 'choose', :id => pairwise_content.id,:question_id => question.id , :prompt_id => prompt.id,
          :choice_id => prompt.left_choice_id , :direction => 'left', :appearance_id => appearance_id}
     link_target.merge!(:embeded => 1) if embeded
     link_target.merge!(:source => source) if source
     link_to prompt.left_choice_text,  link_target
  end

  def skip_vote_link(pairwise_content, question, prompt, embeded = false, source = nil, appearance_id = nil)
    link_target = {:controller => 'pairwise_plugin_profile',
          :action => 'skip_prompt', :id => pairwise_content.id,:question_id => question.id , :prompt_id => prompt.id,
          :appearance_id => appearance_id}
     link_target.merge!(:embeded => 1) if embeded
     link_target.merge!(:source => source) if source
     link_target.merge!(:appearance_id => appearance_id) if appearance_id
     link_to _('Skip vote'),  link_target
  end

  def pairwise_user_identifier(user)
     if user.nil?
      is_external_vote ? "#{params[:source]}-#{request.session_options[:id]}" : "participa-#{request.session_options[:id]}"
     else
       user.identifier
     end
   end

  def pairwise_embeded_code(pairwise_content)
    embeded_url = url_for({:controller => "pairwise_plugin_profile",
                                        :profile => pairwise_content.profile.identifier,
                                        :action => "prompt",
                                        :id => pairwise_content.id,
                                        :question_id => pairwise_content.question.id,
                                        :embeded => 1,
                                        :source => "SOURCE_NAME",
                                        :only_path => false})
    embeded_code = "<iframe src='#{embeded_url}' style='width:100%;height:400px'  frameborder='0' allowfullscreen ></iframe>"

    label = "<hr/>"
    label += content_tag :h5, _('Pairwise Embeded')
    textarea =  text_area_tag 'embeded_code', embeded_code, {:style => "width: 100%; background-color: #ccc; font-weight:bold", :rows => 7}
    hint = content_tag :quote, _("You can put this iframe in your site. Replace <b>source</b> param with your site address and make any needed adjusts in width and height.")
    label + textarea + hint + "<hr/>"
  end

  def choose_right_link(pairwise_content, question, prompt, embeded = false, source = nil, appearance_id = nil)
    link_target = { :controller => 'pairwise_plugin_profile',
          :action => 'choose', :id => pairwise_content.id,  :question_id => question.id , :prompt_id => prompt.id,
          :choice_id => prompt.right_choice_id , :direction => 'right' , :appearance_id => appearance_id}
    link_target.merge!(:embeded => 1) if embeded
    link_target.merge!(:source => source) if source
    link_to prompt.right_choice_text,  link_target
  end

  def pairwise_edit_link(label, pairwise_content)
    link_target = myprofile_path(:controller => :cms, :action => :edit, :id => pairwise_content.id)
    link_to label, link_target
  end

  def pairwise_result_link(label, pairwise_content, embeded = false)
    link_target = pairwise_content.result_url
    link_target.merge!(:embeded => 1) if embeded
    link_to  label, link_target
  end

  def pairwise_suggestion_url(question, embeded = false, source = nil)
    target =  { :controller => :pairwise_plugin_profile, :action => 'suggest_idea', :id => question.id }
    target.merge!({ :embeded => 1 }) if embeded
    target.merge!({ :source => source }) if source
    target
  end

  def is_external_vote
    params.has_key?("source") && !params[:source].empty?
  end

  def ideas_management_link(label, pairwise_content, user)
    return "" unless user
    return "" unless pairwise_content.allow_edit?(user)
    link_to label, :controller => :pairwise_plugin_suggestions, :action => :index, :id => pairwise_content.id
  end

  def has_param_pending_choices?
    params.has_key?("pending") && "1".eql?(params[:pending])
  end

  def choices_showing_text
    ideas_or_suggestions_text = has_param_pending_choices? ? "Suggestions" : "Ideas"
    _("Showing")  + " " + ideas_or_suggestions_text
  end
end

