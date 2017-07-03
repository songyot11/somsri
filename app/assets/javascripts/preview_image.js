function readURL(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    if($('label.img-default').find('div').length){
      $('label.img-default').html('<img class="circle" id="img-change">')
    }

    reader.onload = function (e) {
      $('#img-change').attr('src', e.target.result);
    };

    reader.readAsDataURL(input.files[0]);
  }
}
