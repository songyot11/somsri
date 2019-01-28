(function() {
  'use strict';
  angular.module('somsri.invoice.daily_report_preview', [
  ])
  .controller('dailyReportPreviewCtrl', ['$scope', '$http', '$rootScope', 'dailyReportService', '$state', '$sce', function($scope, $http, $rootScope, service, $state, $sce) {
    $rootScope.menu = I18n.t("print_delivery_money");
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
        ctrl.header = $sce.trustAsHtml(ctrl.datas.header);
      },function(resp) {
        $rootScope.openDailyReport();
      });
    });
  }]);
})();
