function mark_comment_as_read(comment_id) {
  $comment = jQuery('#comment-'+comment_id);
  $comment.find('.comment-content').first().addClass('comment-mark-read');
}

jQuery(window).bind("userDataLoaded", function(event, data) {
  for(var i=0; i<data.read_comments.length; i++) {
    mark_comment_as_read(data.read_comments[i]);
  }
});
