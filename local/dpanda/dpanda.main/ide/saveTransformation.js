var hm = require('header-metadata');
hm.current.set('Content-Type', 'application/json');

session.input.readAsJSON (function (readAsJSONError, json) {
    if (readAsJSONError) { console.log(readAsJSONError); }
    else {

        var urlopen = require('urlopen');

        var filedomain = "dpanda";
        var filename = "";
        if (json.transformationType == "XSL") filename = "local:///dpanda.ide/transform.xsl";
        else if (json.transformationType == "GatewayScript") filename = "local:///dpanda.ide/transform.js";
        var base64content = new Buffer(json.content).toString('base64');

        var somaRequest =
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="http://www.datapower.com/schemas/management">' +
              '<soapenv:Header/>' +
              '<soapenv:Body>' +
                '<man:request domain="' + filedomain + '">' +
                  '<man:set-file name="' + filename + '">' + base64content + '</man:set-file>' +
                '</man:request>' +
              '</soapenv:Body>' +
            '</soapenv:Envelope>';
        session.output.write (somaRequest);
        // var somaUrl = "https://dpanda.xml.mgmt:5550/service/mgmt/3.0";
        // var options = {
        //     target: somaUrl,
        //     method: 'POST',
        //     contentType: 'text/xml',
        //     timeout: 60,
        //     data: somaRequest};

        // urlopen.open(options, function(error, response) {
        //     if (error) {
        //         console.error("urlopen error: " + JSON.stringify(error));
        //     }
        //     else {
        //         response.readAsBuffer(function(error, responseData){
        //             if (error){
        //                 console.error("urlopen error: " + JSON.stringify(error));
        //             }
        //             else {
        //               var responseMessage = new Array();
        //               if (responseData.indexOf("<dp:result>OK</dp:result>") !== -1) session.output.write(JSON.stringify({"status": "ok"}));
        //               else session.output.write(JSON.stringify({"status": "failed"}));
        //             }
        //         });
        //     }
        // });
    }
});
