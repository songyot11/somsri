function printStudent(){
  var params_string = window.location.search.substring(1);
  $.get("/students?" + params_string, { for_print: true })
    .done(function( data ) {
      var html = "";
      var size = 50;
      var order = 1;
      for (var i=0; i<data.student_list.length; i+=size) {
        var dataPerPage = data.student_list.slice(i,i+size);
        html +=
          '<div class="list-page">' +
            '<div class="row">' +
              '<div id="student-list-header" class="col-xs-12 text-center">' +
                'บัญชีรายชื่อนักเรียน  ชั้น.......................................... ภาคเรียนที่ .../'+ data.school_year +
              '</div>' +
            '</div>' +
            '<div class="space10"></div>' +
            '<div class="row">' +
              '<div class="col-xs-12">' +
                '<table style="width:100%">' +
                  '<thead>' +
                    '<tr>' +
                      '<th>ลำดับ</th>' +
                      '<th>เลขประจำตัว</th>' +
                      '<th>ชื่อ - นามสกุล</th>' +
                      '<th>รหัสเลขประจำตัวประชาชน 13 หลัก</th>' +
                      '<th>วัน เดือน ปีเกิด</th>' +
                    '</tr>' +
                  '</thead>' +
                  '<tbody>';
        for (var j=0; j<dataPerPage.length; j++) {
          html +=
                    '<tr>' +
                      '<td>' + order + '</td>' +
                      '<td>' + dataPerPage[j].student_number + '</td>' +
                      '<td>' + dataPerPage[j].full_name + '</td>' +
                      '<td>' + dataPerPage[j].national_id + '</td>' +
                      '<td>' + dataPerPage[j].birthdate + '</td>' +
                    '</tr>';
          order = order + 1;
        }
        html +=
                  '</tbody>' +
                '</table>' +
              '</div>' +
            '</div>' +
          '</div>';
        if(i + size < data.student_list.length){
          html += "<div class='pagebreak'></div>";
        }
      }
      $("#student-list-for-print").html(html);
      window.print();
    });
}
