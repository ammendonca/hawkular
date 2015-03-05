/**
 * Sidebar plugin & directive
 *
 * @module Sidebar
 */
module Sidebar {
  var pluginName = 'sidebar';

  export var _module = angular.module(pluginName, []);

  _module.directive('hawkularSidebar', function () {
      return new Sidebar.SidebarDirective();
  });

  hawtioPluginLoader.addModule(pluginName);
}
