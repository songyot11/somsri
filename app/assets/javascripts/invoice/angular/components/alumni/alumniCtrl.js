(function() {
  'use strict';
  angular.module('somsri.invoice.alumni', [
  ])
  .controller('alumniCtrl', ['$scope', '$http', 'DEFAULT_INVOICE', 'DEFAULT_LOGO', 'LocalStorage', 'Currency', 'alumniService', '$rootScope', function($scope, $http, DEFAULT_INVOICE, DEFAULT_LOGO, LocalStorage, Currency, service, $rootScope) {
    var ctrl = this;
    ctrl.alumnis = []
    ctrl.graduated_year = ["ทั้งหมด"]
    ctrl.graduated_status = ["ทั้งหมด"]
    ctrl.year = ""
    ctrl.status = ""
    $rootScope.menu = "ศิษย์เก่า"
    $rootScope.loadAndAuthorizeResource("invoice", function(){
      ctrl.bringBack = function(id){
        service.restore(id).then(function(resp) {
          alumniTable.bootstrapTable("refresh")
        });
      }

      ctrl.switchYear = function(year){
        ctrl.selected_year = year
        alumniTable.bootstrapTable("refresh")
      }

      ctrl.switchStatus = function(status){
        ctrl.selected_status = status
        alumniTable.bootstrapTable("refresh")
      }

      function alumniQueryParams(params){
        params["year"] = ctrl.selected_year
        params["status"] = ctrl.selected_status
        return params
      }

      function bringBackFormatter(value, row, index){
        var alumni = "angular.element(document.getElementById('angularCtrl')).scope().alumni"
        return '<a id="bringBack' + row['student_id'] + '" onclick="' + alumni + '.bringBack(' + row['student_id'] + ')" class="light-blue-color"><i class="fa fa-undo" aria-hidden="true"></i> นำกลับเข้าระบบ</a>'
      }

      var pageSize = 10
      var alumniTable = $('#alumni-table')
      var alumniTableOptions = {
        sidePagination: "server",
        pageSize: pageSize,
        pagination: true,
        search: true,
        toolbar: ".toolbar",
        url: "/alumnis",
        uniqueId: "student_id",
        queryParams: alumniQueryParams,
        columns: [{
          field: 'name',
          title: 'ชื่อ - นามสกุล',
          sortable: true
        },{
          field: 'nickname',
          title: 'ชื่อเล่น',
          sortable: true
        },{
          field: 'student_number',
          title: 'เลขประจำตัวนักเรียน',
          sortable: true
        },{
          field: 'graduated_year',
          title: 'จบปีการศึกษา',
          sortable: true
        },{
          field: 'graduated_semester',
          title: 'ภาคเรียนที่',
          sortable: true
        },{
          field: 'grade_classroom',
          title: 'ระดับชั้นเรียน',
          sortable: true
        },{
          field: 'status',
          title: 'สถานะ',
          sortable: true
        },{
          field: 'bring_back',
          formatter: bringBackFormatter
        }]
      }
      alumniTable.bootstrapTable(alumniTableOptions)

      service.getAlumniYears().then(function(resp) {
        ctrl.graduated_year = ctrl.graduated_year.concat(resp.data)
        ctrl.selected_year = "ทั้งหมด"
      });

      service.getAlumniStatus().then(function(resp) {
        ctrl.graduated_status = ctrl.graduated_status.concat(resp.data)
        ctrl.selected_status = "ทั้งหมด"
      });
    })
  }]);
})();
