

var sm = require('service-metadata');
var uri = sm.getVar('var://service/URI');

var hm = require('header-metadata');
hm.current.set('Content-Type', 'text/html');

var urlopen = require('urlopen');

var baseUrl = "http://dpanda.localhost:65010/dpanda/";
var options = { method: 'GET', contentType: 'text/html'};

var page = uri.replace("/dpanda/", "");
session.output.write("URI: " + uri.replace("/dpanda/", ""));

options.target = baseUrl + "header.html";
urlopen.open(options, function(headerError, header) {
    if (headerError) console.error("urlopen error: " + JSON.stringify(error));
    else {
        header.readAsBuffer(function(headerReadAsBufferError, headerContent){
            if (headerReadAsBufferError) console.error("urlopen error: " + JSON.stringify(headerReadAsBufferError));
            else {
                options.target = baseUrl + page;
                urlopen.open(options, function(pageError, page) {
                    if (pageError) console.error("urlopen error: " + JSON.stringify(error));
                    else {
                        page.readAsBuffer(function(pageReadAsBufferError, pageContent){
                            if (pageReadAsBufferError) console.error("urlopen error: " + JSON.stringify(error));
                            else {
                                options.target = baseUrl + "footer.html";
                                urlopen.open(options, function(footerError, footer) {
                                    if (footerError) console.error("urlopen error: " + JSON.stringify(error));
                                    else {
                                        footer.readAsBuffer(function(footerReadAsBufferError, footerContent){
                                            if (footerReadAsBufferError) console.error("urlopen error: " + JSON.stringify(error));
                                            else {
                                                session.output.write(headerContent + "\n" + pageContent + "\n" + footerContent);
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }
});
