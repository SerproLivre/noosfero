function mark_comment_as_read(comment_id) {
  $comment = jQuery('#comment-'+comment_id);
  $comment.find('.comment-content').first().addClass('comment-mark-read');
}

jQuery(window).bind("userDataLoaded", function(event, data) {
  for(var i=0; i<data.read_comments.length; i++) {
    mark_comment_as_read(data.read_comments[i]);
  }
});

function toggle_comment_read(button, url, mark) {
  var $ = jQuery;
  var $button = $(button);
  $button.addClass('comment-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      var $comment = $button.closest('.article-comment');
      var $content = $comment.find('.comment-balloon-content').first();
      if(mark)
        $content.addClass('comment-mark-read');
      else
        $content.removeClass('comment-mark-read');
      $button.removeClass('comment-button-loading');
      return;
    }
  });
}

