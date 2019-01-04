(function() {
  'use strict';
  angular.module('somsri.somsri.vacation.leave_rules.service', [
  ])
  .service('leaveRulesService', ['$http', function($http) {

    this.getLeaveRules = function() {
      return $http.get('/vacation_leave_rules')
    }

    this.updateLeaveRules = function(id, message) {
      return $http.put('/vacation_leave_rules/' + id, { message: message })
    }
  }]);
})();
