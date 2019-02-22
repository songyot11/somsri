(function() {
  'use strict';
  angular.module('somsri.somsri.vacation.calendar.service', [
  ])
  .service('calendarService', ['$http', function($http) {

    this.getHolidays = function() {
      return $http.get('/holidays')
    }
    this.newHoliday = function(data) {
      return $http.post('/holidays', data)
    }
    this.deleteHoliday = function(id) {
      return $http.delete('/holidays/' + id)
    }
    this.getVacations = function() {
      return $http.get('/vacations')
    }
  }]);
})();
