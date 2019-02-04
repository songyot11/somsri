(function() {
  'use strict';

  angular.module('somsri.invoice.daily_report.service', [
  ])
  .service('dailyReportService', ['$http', function($http) {
    this.newDailyReport = function() {
      return $http.get('/daily_reports/new', { params: { start_time: moment().startOf('day'), end_time: moment().endOf('day')} })
    };

    this.createDailyReport = function(data) {
      return $http.post('/daily_reports', data)
    };

    this.getDailyReport = function(id) {
      return $http.get('/daily_reports/' + id)
    };
  }]);
})();
