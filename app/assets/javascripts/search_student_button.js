var student_full_name = $("#student_full_name").val()
var student_nickname = $("#student_nickname").val()
var student_full_name_english = $("#student_full_name_english").val()
var student_nickname_english = $("#student_nickname_english").val()
var student_nickname_english = $("#student_nickname_english").val()
var student_gender_id = $("#student_gender_id").val()
var student_birthdate = $("#student_birthdate").val()
var student_grade_id = $("#student_grade_id").val()
var student_classroom_id = $("#student_classroom_id").val()
var student_classroom_number = $("#student_classroom_number").val()
var student_student_number = $("#student_student_number").val()
var student_national_id = $("#student_national_id").val()
var parents = []
for(var i = 0; i < $('select[name="parent[]"]').length; i++) {
  if($('#parent' + i).val()){
    parents.push({
      parent_id: $('#parent' + i).val(),
      relationship_id: $('#relationship' + i).val(),
      mobile: $('#mobile' + i).val()
    })
  }
}
var student_remark = $("#student_remark").val()

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
  $.get( "/students.json", { search: searchTerm, autocomplete: true } ).done(function( data ) {
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
      student_full_name != $("#student_full_name").val() ||
      student_nickname != $("#student_nickname").val() ||
      student_full_name_english != $("#student_full_name_english").val() ||
      student_nickname_english != $("#student_nickname_english").val() ||
      student_nickname_english != $("#student_nickname_english").val() ||
      student_gender_id != $("#student_gender_id").val() ||
      student_birthdate != $("#student_birthdate").val() ||
      student_grade_id != $("#student_grade_id").val() ||
      student_classroom_id != $("#student_classroom_id").val() ||
      student_classroom_number != $("#student_classroom_number").val() ||
      student_student_number != $("#student_student_number").val() ||
      student_national_id != $("#student_national_id").val())
  {
    return true
  }


  // get current parent
  var parentsNew = []
  $('[name="parent[]"]').each(function(){
    if($(this).val()){
      var index = $(this).attr("index")

      parentsNew.push({
        parent_id: $('#parent' + index).val(),
        relationship_id: $('#relationship' + index).val(),
        mobile: $('#mobile' + index).val()
      })
    }
  })

  // check parent change?
  if(parents.length == parentsNew.length){
    for(var i = 0; i < parents.length; i++) {
      var found_matching = false
      for(var j = 0; j < parentsNew.length; j++) {
        if( parents[i]["parent_id"] == parentsNew[j]["parent_id"] &&
            parents[i]["relationship_id"] == parentsNew[j]["relationship_id"] &&
            parents[i]["mobile"] == parentsNew[j]["mobile"])
        {
          // parent property are change
          found_matching = true
        }
      }
      if(!found_matching){
        return true
      }
    }
  }else{
    // number of valid parent not same
    return true
  }
  return false
}
var selected = function(item){
  searchInput.val("")
  goToUrl("/students/" + item.id + "/edit#/")
}

function goToUrl(url){
  if(isChange()){
    $("#warningModal").modal()
    $("#force-change-page").click(function(){
      window.location = url
    })
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
