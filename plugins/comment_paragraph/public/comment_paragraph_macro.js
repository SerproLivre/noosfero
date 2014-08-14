var comment_paragraph_anchor;
var lastParagraph = [];
var lastSelectedArea = [];

function getIdCommentParagraph(paragraphId){
  var idx = paragraphId.lastIndexOf('_');
  return paragraphId.substring(idx+1, paragraphId.length)
}

jQuery(document).ready(function($) {
  rangy.init();
  cssApplier = rangy.createCssClassApplier("commented-area", {normalize: false});
  
  //Add marked text bubble
  $("body").append('\
      <a href="#" id="comment-bubble" style="width:120px;height:105px;">\
          <div  align="center"  class="triangle-right" >Comentar<br>+</div>\
      </a>');
  $("#comment-bubble").hide();
  //Undo previous highlight from the paragraph
  $('.comment_paragraph').mousedown(function(){
    var paragraphId = getIdCommentParagraph($(this)[0].id);
    $(this).find('.commented-area').replaceWith(function() {
      return $(this).html();
    });
    var rootElement = $(this).get(0);
    if(lastParagraph[paragraphId]){
      rootElement.innerHTML = lastParagraph[paragraphId];
    }
  });
  
  $('#comment-bubble').mouseleave(function(){
      this.hide();
      $("#comment-bubble").css({top: 0, left: 0, position:'absolute'});
//      $("#comment-bubble").css({top: 0, left: 0, position:'absolute', 'background-color': 'yellow'});
  });
 
   //highlight area from the paragraph
  $('.comment_paragraph').mouseup(function(event){
      var paragraphId = getIdCommentParagraph($(this)[0].id);
      var currentMousePos = { x: -1, y: -1 };
      currentMousePos.x = event.pageX;
      currentMousePos.y = event.pageY;
      $("#comment-bubble").css({top: event.pageY-100, left: event.pageX-70, position:'absolute'});      
      $("#comment-bubble").data("paragraphId", paragraphId)
      var url = $('#link_to_ajax_comments_' + paragraphId).data('url');      
      $("#comment-bubble").data("url", url)
//      $("#comment-bubble").css({top: event.pageY-100, left: event.pageX-70, position:'absolute', 'background-color': 'yellow'});
      $("#comment-bubble").show();
     // var onclickContent = $('#link_to_ajax_comments_' + paragraphId).attr('onclick');
     // $("#comment-bubble").attr('onclick', onclickContent);
      var rootElement = $(this).get(0);
      lastParagraph[paragraphId] = rootElement.innerHTML;
      var selObj = rangy.getSelection();
      var selected_area = rangy.serializeSelection(selObj, true,rootElement); 
      cssApplier.toggleSelection();
      lastSelectedArea[paragraphId] = selected_area;   
      form = jQuery(this).parent().find('form');
      if (form.find('input.selected_area').length === 0){
        jQuery('<input>').attr({
          class: 'selected_area',
          type: 'hidden',
          name: 'comment[comment_paragraph_selected_area]',
          value: selected_area
        }).appendTo(form)
      }else{
        form.find('input.selected_area').val(selected_area)
      }   
      rootElement.focus();
  });
 
  $('#comment-bubble').click(function(){
    this.hide();
    $("#comment-bubble").css({top: 0, left: 0, position:'absolute'});
    var url = $("#comment-bubble").data('url');
    var paragraphId = $("#comment-bubble").data("paragraphId");
    console.log(url);
    $('.comments_list_toggle_paragraph_' + paragraphId).show();
    $.ajax({
      dataType: "script",
      url: url
    }).done(function() {
        var button = jQuery('#page-comment-form-' + paragraphId +  ' a')[0];
        //console.log(button);
        button.click();
        //$('body').scrollTo('#page-comment-form-' + paragraphId +  ' a');
    });
  });

  function processAnchor(){
    var anchor = window.location.hash;
    if(anchor.length==0) return;

    var val = anchor.split('-'); //anchor format = #comment-\d+
    if(val.length!=2 || val[0]!='#comment') return;
    if($('div[data-macro=comment_paragraph_plugin\\/allow_comment]').length==0) return; //comment_paragraph_plugin/allow_comment div must exists
    var comment_id = val[1];
    if(!/^\d+$/.test(comment_id)) return; //test for integer

    comment_paragraph_anchor = anchor;
    var url = '/plugin/comment_paragraph/public/comment_paragraph/'+comment_id;
    $.getJSON(url, function(data) {
      if(data.paragraph_id!=null) {
        var button = $('div.comment_paragraph_'+ data.paragraph_id + ' a');
        button.click();
        $.scrollTo(button);
      }
    });
  }
 
  processAnchor();
 
  $(document).on('mouseover', 'li.article-comment', function(){
    var selected_area = $(this).find('input.paragraph_comment_area').val();
    var paragraph_id =  $(this).find('input.paragraph_id').val();
    var rootElement = $('#comment_paragraph_'+ paragraph_id).get(0);
   
    if(lastParagraph[paragraph_id] == null || lastParagraph[paragraph_id] == 'undefined'){
      lastParagraph[paragraph_id] = rootElement.innerHTML;
    }
    else {
      rootElement.innerHTML = lastParagraph[paragraph_id] ;
    }
    if(selected_area != ""){
      rangy.deserializeSelection(selected_area, rootElement);
      cssApplier.toggleSelection();
    }
  });
 
  $(document).on('mouseout', 'li.article-comment', function(){
    var paragraph_id =  $(this).find('input.paragraph_id').val();
    var rootElement = $('#comment_paragraph_'+ paragraph_id).get(0);
  
    if(lastSelectedArea[paragraph_id] != null && lastSelectedArea[paragraph_id] != 'undefined' ){
      rootElement = $('#comment_paragraph_'+ paragraph_id).get(0);
      rootElement.innerHTML = lastParagraph[paragraph_id];
      rangy.deserializeSelection(lastSelectedArea[paragraph_id], rootElement);
      cssApplier.toggleSelection();
    } else {
      cssApplier.toggleSelection();
      var sel = rangy.getSelection();
      sel.removeAllRanges();
    }
  });
});

function toggleParagraph(paragraph) {
  var div = jQuery('div.comments_list_toggle_paragraph_'+paragraph);
  var visible = div.is(':visible');
  if(!visible)
    jQuery('div.comment-paragraph-loading-'+paragraph).addClass('comment-button-loading');

  div.toggle('fast');
  return visible;
}

function loadCompleted(paragraph) {
  jQuery('div.comment-paragraph-loading-'+paragraph).removeClass('comment-button-loading')
  if(comment_paragraph_anchor) {
    jQuery.scrollTo(jQuery(comment_paragraph_anchor));
    comment_paragraph_anchor = null;
  }
}
