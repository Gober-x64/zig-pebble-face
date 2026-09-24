// Bundle Clay and regenerate its message-key map from the project metadata.
const esbuild = require('esbuild');
const path = require('path');
const fs = require('fs');
const keys = require('../package.json').pebble.messageKeys;
esbuild.build({
  entryPoints: [path.join(__dirname, '../src/pkjs/index.js')],
  outfile: process.argv[2] || 'zig-out/pebble-js-app.js',
  bundle: true,
  format: 'iife',
  target: 'es5',
  plugins: [{
    name: 'pebble-message-keys',
    setup(build) {
      build.onResolve({ filter: /^@rebble\/clay$/ }, () => ({path: require.resolve('@rebble/clay/src/js/index.js')}));
      // Clay's prebuilt Browserify bundle dynamically loads message_keys.
      // Give that bundle a local resolver instead of leaving a runtime require.
      build.onLoad({ filter: /@rebble[\\/]clay[\\/]src[\\/]js[\\/]index\.js$/ }, args => ({
        contents: "var require = function(name) { if (name === 'message_keys') return " +
          JSON.stringify(keys) + "; throw new Error('Unknown Clay module: ' + name); };\n" +
          fs.readFileSync(args.path, 'utf8')
      }));
    }
  }]
}).catch(() => process.exit(1));
