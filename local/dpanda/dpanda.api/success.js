var hm = require('header-metadata');
hm.current.set('Content-Type', 'application/json');
session.output.write(JSON.stringify({"status": "ok"}));
