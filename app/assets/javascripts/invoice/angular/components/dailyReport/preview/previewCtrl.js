(function() {
  'use strict';
  angular.module('somsri.invoice.daily_report_preview', [
  ])
  .controller('dailyReportPreviewCtrl', ['$scope', '$http', '$rootScope', 'dailyReportService', '$state', function($scope, $http, $rootScope, service, $state) {
    var ctrl = this;
    $rootScope.loadAndAuthorizeResource("daily_report", function(){
      ctrl.title = 'Daily Report Preview';
      var id = $state.params.id;

      ctrl.goBack = function(){
        $rootScope.openDailyReport();
      };

      service.getDailyReport(id).then(function(resp) {
        ctrl.datas = resp.data;
        ctrl.total = resp.data.real_total - resp.data.total
      },function(resp) {
        $rootScope.openDailyReport();
      });
    });
  }]);
})();
