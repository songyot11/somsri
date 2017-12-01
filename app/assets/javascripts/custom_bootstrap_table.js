
function search() {
  $('#table').bootstrapTable('refresh', {
    query: {
      search: $("input#search").val()
    }
  });
  $('#table').bootstrapTable('refreshOptions', {
    pageNumber: 1
  });
}

function filter() {
  var print_link = "/students.pdf?for_print=true";
  print_link += "&grade_select=" + $("select#grade_select").val()
  print_link += "&class_select=" + $("select#class_select").val()
  $('#print-student-list-with-image').attr('href', print_link);
  $('#table').bootstrapTable('refresh', {
    query: {
      offset: 0,
      grade_select: $("select#grade_select").val(),
      class_select: $("select#class_select").val()
    }
  });
  $('#table').bootstrapTable('refreshOptions', {
    pageNumber: 1
  });
}

function queryParams(p) {
  window.paramOder = p.order || p.sortOrder
  window.paramSort = p.sort || p.sortName
  return {
    page: p.pageNumber,
    per_page: p.pageSize,
    offset: p.offset,
    limit: p.limit,
    order: window.paramOder,
    sort: window.paramSort,
    search: $("input#search").val(),
    grade_select: $("select#grade_select").val(),
    class_select: $("select#class_select").val()
  };
}

function cellStyle(value, row, index) {
  return {
    css: {"text-align": "center"}
  };
}

function exportTable(tableName){

  var url = tableName+'.json?order='+window.paramOder+'&sort='+window.paramSort+'&search='+$("input#search").val()+'&grade_select='+$("select#grade_select").val()+'&class_select='+$("select#class_select").val()

  $table = $('#tableForExport')
  $.get( url , function( data ) {
    $table.bootstrapTable('load', data)
    $table.tableExport({type:'excel'});
  });
}

function imgTag(value, row, index){
  if (value) {
    return '<div class="img-bg circle" style="background: url('+ value +')"></div>';
  }
  return '<div class="img-bg bg-light-gray circle"><i class="fa fa-user icon-default-img" aria-hidden="true"></i></div>'
}
