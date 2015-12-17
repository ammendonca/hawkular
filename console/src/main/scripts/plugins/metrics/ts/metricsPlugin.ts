///
/// Copyright 2015 Red Hat, Inc. and/or its affiliates
/// and other contributors as indicated by the @author tags.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///

/// <reference path='../../includes.ts'/>
/// <reference path='metricsGlobals.ts'/>

module HawkularMetrics {

  export let _module = angular.module(HawkularMetrics.pluginName, ['ngResource', 'ngAnimate', 'ui.select',
    'hawkular.services', 'ui.bootstrap', 'topbar', 'patternfly.select', 'angular-momentjs', 'angular-md5', 'toastr',
    'infinite-scroll', 'mgo-angular-wizard', 'hawkular.charts', 'ngClipboard', 'patternfly.filters',
    'patternfly.charts']);

  _module.config(['$compileProvider', function ($compileProvider) {
    //disable debug info
    //NOTE: tools like Batarang and Protractor may not work properly with this debug info off
    //However, this can be turned back on at runtime in the js console by typing: angular.reloadWithDebugInfo()
    $compileProvider.debugInfoEnabled(true);
  }]);

  _module.config(['$httpProvider', '$locationProvider', '$routeProvider',
    ($httpProvider, $locationProvider) => {
      $locationProvider.html5Mode(true);
    }]);

  _module.config(['$animateProvider', '$locationProvider', '$routeProvider',
    ($animateProvider) => {
      $animateProvider.classNameFilter(/^((?!(fa-spin)).)*$/);
    }]);

  _module.config(['$routeProvider', ($routeProvider) => {
    $routeProvider.
      when('/hawkular-ui/url/url-list/:timeOffset?/:endTime?', {templateUrl: 'plugins/metrics/html/url-list.html'}).
      when('/hawkular-ui/url/response-time/:resourceId/:timeOffset?/:endTime?', {
        templateUrl: 'plugins/metrics/html/url-response-time.html',
        reloadOnSearch: false,
        resolve: {
          resource: ($route, $location, HawkularInventory, NotificationsService:INotificationsService) => {
            let p = HawkularInventory.Resource.get({
              environmentId: globalEnvironmentId, resourcePath: $route.current.params.resourceId
            }).$promise;
            p.then((response:any) => {
                return response.properties.url;
              },
              (error) => {
                NotificationsService.info('You were redirected to this page because you requested an invalid URL.');
                $location.path('/');
              });
            return p;
          }
        }
      }).
      when('/hawkular-ui/url/availability/:resourceId/:timeOffset?/:endTime?', {
        templateUrl: 'plugins/metrics/html/url-availability.html',
        reloadOnSearch: false,
        resolve: {
          resource: ($route, $location, HawkularInventory, NotificationsService:INotificationsService) => {
            let p = HawkularInventory.Resource.get({
              environmentId: globalEnvironmentId, resourcePath: $route.current.params.resourceId
            }).$promise;
            p.then((response:any) => {
                return response.properties.url;
              },
              (error) => {
                NotificationsService.info('You were redirected to this page because you requested an invalid URL.');
                $location.path('/');
              });
            return p;
          }
        }
      }).
      when('/hawkular-ui/url/alerts/:resourceId/:timeOffset?/:endTime?', {
        templateUrl: 'plugins/metrics/html/url-alerts.html',
        reloadOnSearch: false,
        resolve: {
          resource: ($route, $location, HawkularInventory, NotificationsService:INotificationsService) => {
            let p = HawkularInventory.Resource.get({
              environmentId: globalEnvironmentId, resourcePath: $route.current.params.resourceId
            }).$promise;
            p.then((response:any) => {
                return response.properties.url;
              },
              (error) => {
                NotificationsService.info('You were redirected to this page because you requested an invalid URL.');
                $location.path('/');
              });
            return p;
          }
        }
      }).
      when('/hawkular-ui/app/app-list/:timeOffset?/:endTime?',
      {templateUrl: 'plugins/metrics/html/app-server-list.html'}).
      when('/hawkular-ui/app/app-details/:feedId/:resourceId/:tabId/:timeOffset?/:endTime?', {
        templateUrl: 'plugins/metrics/html/app-details/app-server-details.html',
        reloadOnSearch: false,
        resolve: {
          resource: ($route, $location, HawkularInventory, NotificationsService:INotificationsService) => {
            let redirectMissingAppServer = () => {
              NotificationsService.info('You were redirected to this page because you requested an invalid ' +
                'Application Server.');
              $location.path('/hawkular-ui/app/app-list');
            };
            let checkAppServerExists = () => {
              let p = HawkularInventory.ResourceUnderFeed.get({
                feedId: $route.current.params.feedId,
                resourcePath: $route.current.params.resourceId + '~~'
              }).$promise;
              p.then((response) => {
                  return response;
                },
                (error) => redirectMissingAppServer()
              );
              return p;
            };
            return checkAppServerExists();
          }
        }
      }).
      when('/hawkular-ui/alerts-center/:timeOffset?/:endTime?', {
        templateUrl: 'plugins/metrics/html/alerts-center-list.html',
        controller: 'AlertsCenterController',
        controllerAs: 'ac'
      }).
      when('/hawkular-ui/alerts-center-detail/:alertId*', {
        templateUrl: 'plugins/metrics/html/alerts-center-detail.html',
        controller: 'AlertsCenterDetailsController',
        controllerAs: 'acd'
      }).
      when('/hawkular-ui/alerts-center-triggers/:resourceId*?', {
        templateUrl: 'plugins/metrics/html/alerts-center-triggers.html',
        controller: 'AlertsCenterTriggerController',
        controllerAs: 'act'
      }).
      when('/hawkular-ui/alerts-center-triggers', {
        // because the final '/' makes a difference...
        redirectTo: '/hawkular-ui/alerts-center-triggers/'
      }).
      when('/hawkular-ui/alerts-center-triggers-availability/:triggerId', {
        templateUrl: 'plugins/metrics/html/triggers/availability.html',
        controller: 'AvailabilityTriggerSetupController',
        controllerAs: 'tc'
      }).
      when('/hawkular-ui/alerts-center-triggers-range/:triggerId', {
        templateUrl: 'plugins/metrics/html/triggers/range.html',
        controller: 'RangeTriggerSetupController',
        controllerAs: 'tc'
      }).
      when('/hawkular-ui/alerts-center-triggers-range-percent/:triggerId', {
        templateUrl: 'plugins/metrics/html/triggers/range-percent.html',
        controller: 'RangeByPercentTriggerSetupController',
        controllerAs: 'tc'
      }).
      when('/hawkular-ui/alerts-center-triggers-threshold/:triggerId', {
        templateUrl: 'plugins/metrics/html/triggers/threshold.html',
        controller: 'ThresholdTriggerSetupController',
        controllerAs: 'tc'
      }).
      when('/hawkular-ui/alerts-center-triggers-event/:triggerId', {
        templateUrl: 'plugins/metrics/html/triggers/event.html',
        controller: 'EventTriggerSetupController',
        controllerAs: 'tc'
      }).
      when('/hawkular-ui/agent-installer/view', {templateUrl: 'plugins/metrics/html/agent-installer.html'}).
      otherwise({redirectTo: '/hawkular-ui/app/app-list'});
  }]);

  // so the same scroll doesn't trigger multiple times
  angular.module('infinite-scroll').value('THROTTLE_MILLISECONDS', 250);

  hawtioPluginLoader.addModule(HawkularMetrics.pluginName);
}
