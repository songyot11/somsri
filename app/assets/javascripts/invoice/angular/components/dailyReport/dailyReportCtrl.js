(function() {
  'use strict';
  angular.module('somsri.invoice.daily_report', [
  ])
  .controller('dailyReportCtrl', ['$scope', '$http', '$rootScope', 'dailyReportService', function($scope, $http, $rootScope, service) {
      $rootScope.menu = "การเงิน"
    var ctrl = this;
    $rootScope.loadAndAuthorizeResource("daily_report", function(){
      ctrl.title = 'Daily Report';

      ctrl.cancel = function() {
        $rootScope.openMenu();
      };

      ctrl.total = function() {
        ctrl.datas.real_total = 0.00;
        if(ctrl.datas.real_start_cash){ ctrl.datas.real_total += ctrl.datas.real_start_cash }
        if(ctrl.datas.real_cash){ ctrl.datas.real_total += ctrl.datas.real_cash }
        if(ctrl.datas.real_credit_card){ ctrl.datas.real_total += ctrl.datas.real_credit_card }
        if(ctrl.datas.real_cheque){ ctrl.datas.real_total += ctrl.datas.real_cheque }
        if(ctrl.datas.real_tranfers){ ctrl.datas.real_total += ctrl.datas.real_tranfers }
      };

      ctrl.submit = function() {
        service.createDailyReport({ daily_report: ctrl.datas }).then(function(resp) {
          $rootScope.openDailyReportPreview(resp.data.id);
        },function(resp) {

        }); ;
      };

      (function init() {
        // Attempt to load invoice from local storage
        service.newDailyReport().then(function(resp) {
          ctrl.datas = resp.data;
          ctrl.datas.real_total = 0;
        },function(resp) {
        });
      })()

      // Runs on document.ready
      angular.element(document).ready(function () {
        document.getElementById('startCash').focus();
      });
    });
  }]);
})();
