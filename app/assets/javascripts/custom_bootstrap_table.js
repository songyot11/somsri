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

function selectionStudentFormatter(value, row, index){
  var html =
  '<span class="dropdown float-right">' +
    '<span div data-toggle="dropdown" id="options' + row.id + '">' +
      "<span>ตัวเลือก <i class='fa fa-chevron-down'></i></span>" +
    '</span>' +
    '<ul class="dropdown-menu dropdown-menu-right" aria-labelledby="options' + row.id + '">' +
      '<li>' +
        "<a href='/students/" + row.id + "/edit'>" +
          "<i class='fa fa-pencil-square-o' aria-hidden='true'></i> แก้ไข" +
        '</a>' +
      '</li>' +
      '<li>' +
        "<a onclick='openResignStudentModal(" + row.id + ")'>" +
          "<i class='fa fa-share-square-o color-orange' aria-hidden='true'></i> ลาออกจากโรงเรียน" +
        '</a>' +
      '</li>' +
      '<li>' +
        "<a onclick='openGraduateStudentModal(" + row.id + ")'>" +
          "<i class='fa fa-graduation-cap color-green' aria-hidden='true'></i> จบการศึกษา" +
        '</a>' +
      '</li>' +
      '<li>' +
        "<a onclick='openDeletedStudentModal(" + row.id + ")'>" +
          "<i class='fa fa-trash color-red' aria-hidden='true'></i> ลบข้อมูล" +
        '</a>' +
      '</li>' +
    '</ul>' +
  '</span>';
  return html
}

function openDeletedStudentModal(id){
  $('#warningModal #modal-title').html("คุณต้องการลบนักเรียนคนนี้ใช่หรือไม่?")
  $('#warningModal #actionModalForm').prop("action", "/students/" + id)
  $('#warningModal #actionModalForm').append('<input type="hidden" name="_method" value="delete">')
  $('#warningModal #actionModalForm').prop("method", "post")
  $('#warningModal').modal()
}

function openResignStudentModal(id){
  $('#warningModal #modal-title').html("คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น \"ลาออก\" ใช่หรือไม่?")
  $('#warningModal #actionModalForm').prop("action", "/students/" + id + "/resign")
  $('#warningModal #actionModalForm').prop("method", "post")
  $('#warningModal').modal()
}

function openGraduateStudentModal(id){
  $('#warningModal #modal-title').html("คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น \"จบการศึกษา\" ใช่หรือไม่?")
  $('#warningModal #actionModalForm').prop("action", "/students/" + id + "/graduate")
  $('#warningModal #actionModalForm').prop("method", "post")
  $('#warningModal').modal()
}

function selectionParentFormatter(value, row, index){
  if(row.parents && row.parents.id){
    var id = row.parents.id
    var html =
    '<span class="dropdown float-right">' +
      '<span div data-toggle="dropdown" id="options' + id + '">' +
        "<span>ตัวเลือก <i class='fa fa-chevron-down'></i></span>" +
      '</span>' +
      '<ul class="dropdown-menu dropdown-menu-right" aria-labelledby="options' + id + '">' +
        '<li>' +
          "<a href='/parents/" + id + "/edit'>" +
            "<i class='fa fa-pencil-square-o' aria-hidden='true'></i> แก้ไข" +
          '</a>' +
        '</li>' +
        '<li>' +
          "<a onclick='openDeletedParentModal(" + id + ")'>" +
            "<i class='fa fa-trash color-red' aria-hidden='true'></i> ลบข้อมูล" +
          '</a>' +
        '</li>' +
      '</ul>' +
    '</span>';
    return html
  }else{
    return ""
  }
}

function openDeletedParentModal(id){
  $('#warningModal #modal-title').html("คุณต้องการลบผู้ปกครองคนนี้ใช่หรือไม่?")
  $('#warningModal #actionModalForm').prop("action", "/parents/" + id)
  $('#warningModal #actionModalForm').append('<input type="hidden" name="_method" value="delete">')
  $('#warningModal #actionModalForm').prop("method", "post")
  $('#warningModal').modal()
}
