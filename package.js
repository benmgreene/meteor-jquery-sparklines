Package.describe({
    summary: "A reactive blaze component for rendering live jQuery Sparklines.",
    version: '1.1.1',
    git: 'https://github.com/benmgreene/meteor-jquery-sparklines',
    name: "benmgreene:jquery-sparklines"

});

Package.on_use(function (api) {
  api.use([
    'coffeescript@1.0.3'
  ],['client', 'server']);

  // for helpers
  api.use([
    'jquery@1.0.0',
    'ui@1.0.3',
    'templating@1.0.7',
    'spacebars@1.0.2'
  ], 'client');

  api.add_files([
    'vendor/jquery.sparklines.js',
    'lib/sparklines.html',
    'lib/sparklines.coffee'
  ], [ 'client' ]);
});

Package.on_test(function (api) {
  api.use([
    'coffeescript',
    'benmgreene:jquery-sparklines',
    'tinytest',
    'test-helpers'
  ], ['client', 'server']);

  api.add_files([
    'tests/sparklines.tests.coffee'
  ], ['client', 'server']);
});