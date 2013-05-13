function show_comment_as_read(comment_id) {
  $comment = jQuery('#comment-'+comment_id);
  $comment.find('.comment-content').first().addClass('comment-mark-read');
}
/*
function mark_comment_as_not_read(button, url, msg) {
  toggle_comment_read(button, url, true, msg);
}

function mark_comment_as_read(button, url, msg) {
  toggle_comment_read(button, url, true, msg);
}

function toggle_comment_read(button, url, mark, msg) {
  var $ = jQuery;
  var $button = $(button);
  if (msg && !confirm(msg)) {
    $button.removeClass('comment-button-loading');
    return;
  }
  $button.addClass('comment-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      var $comment = $button.closest('.article-comment');
      if(mark)
        $comment.find('.comment-balloon-content').addClass('comment-mark-read');
      else
        $comment.find('.comment-balloon-content').removeClass('comment-mark-read');
    }else{
      $button.removeClass('comment-button-loading');
      return;
    }
  });
}
*/
