(function () {
  'use strict';

  angular
    .module('somsri.translate')
    .config(config);

  config.$inject = ['$translateProvider', 'languageTh', 'languageEn']

  function config ($translateProvider,languageTh, languageEn) {
    $translateProvider
      .translations('th', languageTh)
      .translations('en', languageEn);

    var language = $('html').attr('lang');

    $translateProvider.preferredLanguage(language);
    $translateProvider.useSanitizeValueStrategy('escape');
  }
})();
