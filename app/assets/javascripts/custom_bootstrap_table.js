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
    return {
      offset: p.offset,
      limit: p.limit,
      order: p.order,
      sort: p.sort,
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
