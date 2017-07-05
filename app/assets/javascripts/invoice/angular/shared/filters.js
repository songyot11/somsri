(function() {
  'use strict';
  angular.module('somsri.invoice.filters', [])
  .filter('dateFormat', ['moment', function(moment) {
    return function(date) {
      return moment(date).format('DD/MM/YYYY');
    }
  }])
})();
