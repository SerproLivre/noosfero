function toggle_comment_like(button, value, url) {
  var $ = jQuery;
  var $button = $(button);
  $button.addClass('comment-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      mark_like_button($button, value, true);
    }
  });
}

function mark_like_button(button, value, verify) {
  button.removeClass('comment-button-loading');
  var counter = button.find('.like-comment-action-counter');
  if(button.hasClass('like-comment-action-active')) value = -value;
  var count = parseInt(counter.html());
  counter.html(count+value);
  button.toggleClass('like-comment-action-active');

  if(verify) {
    button.closest('.comments-action-bar').find('.like-comment-action a').each(function(index, el) {
      if(el!=button[0]) {
        var other = jQuery(el);
        if(other.hasClass('like-comment-action-active')) {
          mark_like_button(other, value, false);
        }
      }
    });
  }
}

