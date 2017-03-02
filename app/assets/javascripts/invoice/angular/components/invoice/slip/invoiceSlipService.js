(function() {
  'use strict';

  angular.module('somsri.invoice.invoice_slip.service', [
  ])
  .service('invoiceSlipService', ['$http', function($http) {
    this.getSlip = function(id) {
      return $http.get('/invoices/' + id + '/slip');
    }
  }]);
})();
