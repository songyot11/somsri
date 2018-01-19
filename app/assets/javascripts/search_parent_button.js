var parent_full_name = $("#parent_full_name").val()
var parent_nickname = $("#parent_nickname").val()
var parent_id_card_no = $("#parent_id_card_no").val()
var parent_mobile = $("#parent_mobile").val()
var parent_email = $("#parent_email").val()
var parent_line_id = $("#parent_line_id").val()
var students = []
for(var i = 0; i < $('select[name="student[]"]').length; i++) {
  if($('#student' + i).val()){
    students.push({
      student_id: $('#student' + i).val(),
      relationship_id: $('#relationship' + i).val()
    })
  }
}

var searchInputDisplay = false;
var searchInput = $('#search-by-name');
var nameLabel = $('#full-name-label');
var delayTimer;

function imgTag(value){
  if (value) {
    return '<div class="img-bg circle" style="background: url('+ value +')"></div>';
  }
  return '<div class="img-bg bg-light-gray circle"><i class="fa fa-user icon-default-img" aria-hidden="true"></i></div>'
}

function displaySearchInput(){
  nameLabel.hide();
  // searchInput.show();
  $('.rich-autocomplete').show();
  searchInput.focus();
  searchInputDisplay = true;
}

function displayNameLabel(){
  nameLabel.show();
  // searchInput.hide();
  $('.rich-autocomplete').hide();
  searchInputDisplay = false;
}

function toggleSearchInput(){
  if(searchInputDisplay){
    displayNameLabel();
  }else{
    displaySearchInput();
  }
}

var loadServerPage = function(searchTerm, pageNumber, pageSize) {
  var deferred = $.Deferred();
  $.get( "/parents/get_autocomplete", { search: searchTerm } ).done(function( data ) {
    deferred.resolve(data);
  });
  return deferred.promise();
};

var renderSearch = function(item){
  var html = "<div class='row'>"
  html += "<div class='col-xs-2'>"
  html += imgTag(item.img_url)
  html += "</div>"
  html += "<div class='col-xs-10 text-label'>"
  html += "<a class='search-autocomplete'>" + item.full_name_label + "</a>"
  html += "</div>"
  return html
}

var isChange = function(){
  if( $("#imageUpload").val() ||
      parent_full_name != $("#parent_full_name").val() ||
      parent_nickname != $("#parent_nickname").val() ||
      parent_id_card_no != $("#parent_id_card_no").val() ||
      parent_mobile != $("#parent_mobile").val() ||
      parent_email != $("#parent_email").val() ||
      parent_line_id != $("#parent_line_id").val() )
  {
    return true
  }

  // get current student
  var studentsNew = []
  var index = 0
  $('select[name="student[]"]').each(function(){
    if($(this).val()){
      studentsNew.push({
        student_id: $('#student' + index).val(),
        relationship_id: $('#relationship' + index).val()
      })
      index++
    }
  })

  // check student change?
  if(students.length == studentsNew.length){
    for(var i = 0; i < students.length; i++) {
      var found_matching = false
      for(var j = 0; j < studentsNew.length; j++) {
        if( students[i]["student_id"] == studentsNew[j]["student_id"] &&
            students[i]["relationship_id"] == studentsNew[j]["relationship_id"] )
        {
          // student property are change
          found_matching = true
        }
      }
      if(!found_matching){
        return true
      }
    }
  }else{
    // number of valid student not same
    return true
  }
  return false
}
var selected = function(item){
  searchInput.val("")
  goToUrl("/parents/" + item.id + "/edit#/")
}

function goToUrl(url){
  if(isChange()){
    $("#force-change-page").click(function(){
      window.location = url
    })
    $("#warningModal").modal()
  }else{
    window.location = url
  }
}

searchInput.richAutocomplete({
  loadPage: loadServerPage,
  render: renderSearch,
  select: selected,
  paging: true,
  pageSize: 20
});

$('.rich-autocomplete').hide();

searchInput.blur(function(){
  displayNameLabel();
});
