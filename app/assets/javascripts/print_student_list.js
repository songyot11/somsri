function printStudent(){
  var params_string = window.location.search.substring(1);
  var print_params = { for_print: true }
  print_params["order"] = window.paramOder
  print_params["sort"] = window.paramSort
  print_params["search"] = $("input#search").val()
  print_params["grade_select"] = $("#grade_select").val()
  print_params["class_select"] = $("#class_select").val()
  $.get("/students.json?" + params_string, print_params)
    .done(function( data ) {
      var html = "";
      var size = 39;
      var order = 1;
      for (var i=0; i<data.student_list.length; i+=size) {
        var dataPerPage = data.student_list.slice(i,i+size);
        html +=
          '<div class="list-page">' +
            '<div class="row">' +
              '<div id="student-list-header" class="col-xs-12 text-center">' +I18n.t("topic")+ data.school_year +
              '</div>' +
            '</div>' +
            '<div class="space10"></div>' +
            '<div class="row">' +
              '<div class="col-xs-12">' +
                '<table style="width:100%">' +
                  '<thead>' +
                    '<tr>' +
                      '<th class="text-center">'+I18n.t("item_no")+'</th>' +
                      '<th class="text-center">'+I18n.t("student_id1")+'</th>' +
                      '<th class="text-center">'+I18n.t("full_name")+'</th>' +
                      '<th class="text-center">'+I18n.t("personal_id")+'</th>' +
                      '<th class="text-center">'+I18n.t("birthday_1")+'</th>' +
                    '</tr>' +
                  '</thead>' +
                  '<tbody>';
        for (var j=0; j<dataPerPage.length; j++) {
          html +=
                    '<tr>' +
                      '<td class="text-center">' + order + '</td>' +
                      '<td class="text-center">' + dataPerPage[j].student_number + '</td>' +
                      '<td>' + dataPerPage[j].full_name + '</td>' +
                      '<td class="text-center">' + dataPerPage[j].national_id + '</td>' +
                      '<td class="text-center">' + dataPerPage[j].birthdate + '</td>' +
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
