$('#classroom-list').bootstrapTable();

function editBtnFormatter(index, row, element){
  return '<a herf="/classroom/' + row.classroom_id + '"><i class="fa fa-pencil" aria-hidden="true"></i></a>';
}
