jQuery(document).ready(function() {
  $('<a>',{
    text: 'Отказать',
    href: '/issue/' + $('body').data('issue-id') + '/refusal_response',
  }).appendTo($('#content .contextual').first());
});
