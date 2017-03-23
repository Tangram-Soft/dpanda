
// This is a new GatewayScript transformation file.
var sm = require('service-metadata');
var routingUrl = sm.getVar('var://service/routing-url');

session.input.readAsJSON (function (readAsJSONError, json) {
    if (readAsJSONError) {

        session.output.write(readAsJSONError);
    }
    else {

        session.output.write(JSON.stringify({"status": "ok"}));
    }
});
