$('#classroom-list').bootstrapTable();

function editBtnFormatter(index, row, element){
  return '<a href="/main#/classroom/' + row.classroom_id + '"><i class="fa fa-pencil" aria-hidden="true"></i></a>';
}
