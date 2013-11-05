function toggle_like(button, value, url) {
  var $ = jQuery;
  var $button = $(button);
  $button.addClass('like-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      mark_like_button($button, value, true);
    }
  });
}

function mark_like_button(button, value, verify) {
  button.removeClass('like-button-loading');
  var counter = button.find('.like-action-counter');
  if(button.hasClass('like-action-active')) value = -value;
  var count = parseInt(counter.html());
  counter.html(count+value);
  button.toggleClass('like-action-active');

  if(verify) {
    console.log(button.closest('.action').parent().find('.action a'));
    button.closest('.action').parent().find('a').each(function(index, el) {
      if(el!=button[0]) {
        var other = jQuery(el);
        if(other.hasClass('like-action-active')) {
          mark_like_button(other, value, false);
        }
      }
    });
  }
}

