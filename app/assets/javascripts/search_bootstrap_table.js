$(function () {
  var $table = $('#table');

  $table.on('post-body.bs.table', function () {
    var $search = $table.data('bootstrap.table').$toolbar.find('.search input');
    $search.attr('placeholder', "ค้นหา");
  });

  $(".pull-right.search").prepend("<i class='fa fa-search' aria-hidden='true'></i>");
});
