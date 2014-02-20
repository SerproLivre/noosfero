module PairwisePlugin::Helpers::SuggestionsHelper

  def pagination_for_choices(choices)
    pagination_links choices,
      :params =>  {
                    :controller => 'pairwise_plugin_suggestions',
                    :action => :index,
                    :profile => profile.identifier
                  }
  end

  def link_to_edit_choice(pairwise_content, choice)
    link_to _("Edit"), :action => "edit", :id => pairwise_content.id, :choice_id => choice.id
  end

  def link_to_approve_choice(pairwise_content, choice, params)
    link_to _("Approve"), :action => "approve", :id => pairwise_content.id, :choice_id => choice.id,:page => params[:page], :pending => params[:pending]
  end

end