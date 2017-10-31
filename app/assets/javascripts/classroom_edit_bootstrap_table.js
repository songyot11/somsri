

function teacherFormatter(index, row, element){
  return '<a href="/classroom/' + row.classroom_id + '"><i class="fa fa-pencil" aria-hidden="true"></i></a>';
}

function removeBtnFormatter(index, row, element){
  return '<a href="/classroom/' + row.classroom_id + '"><i class="fa fa-pencil" aria-hidden="true"></i></a>';
}
