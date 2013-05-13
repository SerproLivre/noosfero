function mark_comment_as_read(comment_id) {
  $comment = jQuery('#comment-'+comment_id);
  $comment.find('.comment-content').first().addClass('comment-mark-read');
}
