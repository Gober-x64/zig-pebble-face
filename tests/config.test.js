const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const cp = require('node:child_process');
const path = require('node:path');
const os = require('node:os');
const out = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'royale-js-')), 'app.js');
cp.execFileSync(process.execPath, ['scripts/build-js.js', out]);
const events = {};
let opened;
let sent;
const storage = {};
vm.runInNewContext(fs.readFileSync(out, 'utf8'), {
  console,
  localStorage: {getItem: key => storage[key] || null, setItem: (key, value) => { storage[key] = value; }},
  Pebble: {
    platform: 'test',
    getActiveWatchInfo: () => ({platform: 'emery'}),
    getAccountToken: () => 'test',
    getWatchToken: () => 'test',
    addEventListener: (name, handler) => { events[name] = handler; },
    openURL: url => { opened = url; },
    sendAppMessage: values => { sent = values; }
  }
});
events.showConfiguration();
const html = decodeURIComponent(opened);
for (const label of ['24-hour', 'Per 30 Seconds', 'wrist flick']) assert.ok(html.includes(label), label);
events.webviewclosed({response: encodeURIComponent(JSON.stringify({
  SettingsEnableSeconds: {value: '3'},
  SettingsTimeZone: {value: '20'},
  SettingsHourFormat: {value: '2'},
  SettingsFlickSeconds: {value: '5'}
}))});
assert.deepEqual(JSON.parse(JSON.stringify(sent)), {'10000': '3', '10001': '20', '10002': '2', '10003': '5'});
console.log('Bundled Clay settings and message-key round trip passed');
