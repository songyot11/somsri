(function() {
  'use strict';
  angular.module('somsri.payroll.filters', [])
  .filter('get_month_name', [function() {
    return function(month) {
      return month.name + " " + month.year
    }
  }])
})();
