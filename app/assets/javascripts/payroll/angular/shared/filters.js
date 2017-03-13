(function() {
  'use strict';
  angular.module('somsri.payroll.filters', [])
  .filter('encodeString', [function() {
    return function(date_string) {
      return  encodeURIComponent(date_string);
    }
  }])
  .filter('dateThai', ['moment', function(moment) {
    return function(date_string) {
      return moment(date_string).add(543, 'years').format('DD/MM/YYYY');
    }
  }])
})();
