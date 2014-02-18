require 'will_paginate/array'

class PairwisePluginSuggestionsController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  before_filter :load_pairwise_question

  def index
    return no_result if @pairwise_content.nil?
    return no_result if @pairwise_content.question.nil?
    @choices = list_choices
    @choices = WillPaginate::Collection.create(params[:page] || 1, 2, @choices.length) do |pager|
      #raise "Offset: #{pager.offset} - PerPage: #{pager.per_page}"
      #raise @choices.slice(pager.offset, pager.per_page).inspect
      pager.replace(@choices.slice(pager.offset, pager.per_page))
    end
  end

  def update
    return no_result if @pairwise_content.nil?
    @pairwise_content.update_choice(params[:choice][:id], params[:choice][:text])
  end

  def approve 
    return no_result if @pairwise_content.nil?
    @pairwise_content.approve_choice(params[:choice][:id])
    redirect_to :index
  end

  def inactivate
    return no_result if @pairwise_content.nil?
    @pairwise_content.inactivate(params[:choice][:id])
    redirect_to :index
  end

private

  def list_choices
    params[:innactives] ? @pairwise_content.inactive_choices : @pairwise_content.raw_choices
  end

  def no_result
    render :no_result
  end

  def load_pairwise_question
    @pairwise_content ||= profile.articles.find(params[:id])
  end
end