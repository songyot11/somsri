(function() {
  'use strict';
  angular.module('somsri.invoice.invoice_slip', [
  ])
  .controller('invoiceSlipCtrl', ['$scope', '$http', '$state', 'DEFAULT_LOGO', 'invoiceSlipService', '$rootScope', function($scope, $http, $state, DEFAULT_LOGO, service, $rootScope) {
    var ctrl = this;
    $rootScope.loadAndAuthorizeResource("invoice", function(){
      ctrl.title = 'Invoice Slip';
      var invoiceId = $state.params.id;
      var page = $state.params.page;

      service.getSlip(invoiceId).then(function(resp) {
        ctrl.datas = resp.data;
        var item_count = 0;
        if(ctrl.datas.line_items){ item_count = ctrl.datas.line_items.length; }
        var heigth = 240 - (item_count * 34);
        if(heigth < 0){ heigth = 0; }
        ctrl.autoHeigth = heigth.toString() + 'px';
      });

      ctrl.goBack = function(){
        if(page){
          $rootScope.openPage(page);
        }else{
          $rootScope.openPayment();
        }
      };
    });
  }]);
})();
