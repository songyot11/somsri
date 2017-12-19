$(document).ready(function(){
  rePositionImage($('#img-change'))
});

function rePositionImage($image){
  $image.on('load', function() {
    portraitOrLandscape($image);
  });
  $image.trigger('load');
  if($image.prop('complete')){
    portraitOrLandscape($image);
  }
}

function portraitOrLandscape($image){
  var height = $image.height();
  var width = $image.width();
  if (width > height) {
    $image.parents('.img-upload-display').removeClass('hide');
    $image.parents('.img-upload-display').removeClass('circular-portrait');
    $image.parents('.img-upload-display').addClass('circular-landscape');
  }else{
    $image.parents('.img-upload-display').removeClass('hide');
    $image.parents('.img-upload-display').removeClass('circular-landscape');
    $image.parents('.img-upload-display').addClass('circular-portrait');
  }
}


function readURL(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    if($('label.img-default').find('div').length){
      $('label.img-default').html('<div class="img-upload-display hide"><img id="img-change"></div>')
    }

    reader.onload = function (e) {
      $('#img-change').attr('src', e.target.result);
      rePositionImage($('#img-change'));
    };

    reader.readAsDataURL(input.files[0]);
  }
}
