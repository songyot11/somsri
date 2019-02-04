$(document).ready(function(){
  $('.fixed-table-body > table').on('all.bs.table', function () {
    $('*[data-toggle="popover"]').popover();
  });
});

