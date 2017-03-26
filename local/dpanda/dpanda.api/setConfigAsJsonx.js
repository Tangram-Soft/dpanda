var urlopen = require('urlopen');

session.input.readAsBuffer(function(error, buffer){
  if(error){
      console.error(error.errorMessage);
  } else {
    var base64String = buffer.toString('base64');
    var json = {"filename":"local://dpanda/dpanda/configuration.jsonx.xml", "data": base64String};

    var options = {
            target: 'http://127.0.0.1:65011/dpanda/api/uploadFile',
            method: 'POST',
            contentType: 'text/plain',
           timeout: 2,
           data: json
         };
     urlopen.open(options, function(error, response) {
     if (error) {
       // an error occurred during the request sending or response header parsing
       console.log("urlopen error: "+JSON.stringify(error));
     } else {
       var responseStatusCode = response.statusCode;
       console.log("Response status code: " + responseStatusCode);
       response.readAsJSON(function(error, responseData){
          if (error){
            throw error ;
          } else {
            session.output.write(responseData) ;
          }
        });

     };

   });
 }
});
