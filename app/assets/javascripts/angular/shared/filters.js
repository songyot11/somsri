(function() {
  'use strict';
  angular.module('somsri.payroll.filters', [])
  .filter('encodeString', [function() {
    return function(date_string) {
      return  encodeURIComponent(date_string);
    }
  }])
})();
