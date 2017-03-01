var urlopen = require ('urlopen');
var sm = require('service-metadata');

function connectionTest(remoteUrl, objectType,xmlMgmtUrl, callback){

  var result;

  if (objectType == 'MQQM'){
    var host = remoteUrl.slice(0,remoteUrl.indexOf(':'));
    var port = remoteUrl.slice(remoteUrl.indexOf(':')+1);
    console.log(host + ' ' + port)
    var doActionTcpTest =
    '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">' +
      '<env:Body>' +
        '<dp:request domain="default" xmlns:dp="http://www.datapower.com/schemas/management">' +
          '<dp:do-action>' +
            '<TCPConnectionTest>' +
            '<RemoteHost>' + host + '</RemoteHost>' +
            '<RemotePort>' + port + '</RemotePort>' +
            '</TCPConnectionTest>' +
          '</dp:do-action>' +
        '</dp:request>' +
        '</env:Body>' +
      '</env:Envelope>';

        var options_xmlMgmt = {
              target: xmlMgmtUrl,
              sslClientProfile: 'dpanda.api.ssl.client.profile',
              headers: { 'Authorization' : 'Basic ZHBhbmRhOmRwYW5kYQ=='},
              method: 'post',
              timeout: 2,
              data: doActionTcpTest,
          };

    urlopen.open(options_xmlMgmt, function(error,response){
     if (error) {
       console.error("urlOpen error: " + JSON.stringify(error));
       result = 'down';
       console.log(result);
       callback(result);
     } else {
       response.readAsBuffer(function(error, responseData) {
               if (error) {
                   console.error("readAsBuffer response error: " + JSON.stringify(error));
                   result = 'down';
                   callback(result);
                   console.log(result);
               } else {
                  var responseDataAsString = responseData.toString();
                  if (responseDataAsString.includes('OK')){
                    result = 'up';
                    console.log(remoteUrl + result);
                    callback(result);

                  } else {
                    result = 'down';
                    console.log(remoteUrl + result);
                    callback(result);
                  }
                }});
     }
     // console.log(result);
   });
 } else {
      var options = {
        target: remoteUrl,
        timeout: 2,
        // method: 'POST',
        data: {},
      }

      if (remoteUrl.includes('https')){
        options.sslClientProfile = 'dpanda.api.ssl.client.profile'
      };

      urlopen.open(options, function(error,response){
        if (error){
          result = 'down';
          console.log(remoteUrl + ' status: ' + result );
          callback(result);
        } else {
          console.log(JSON.stringify(response))
          result= 'up';
          console.log(remoteUrl + ' status: ' + result );
          callback(result);
        }
      });
    }
}

session.input.readAsJSON(function(error, remoteTargets){
  if(error){
      session.output.write (error.errorMessage);
      } else {

        var queryLocationInUri = [];
        queryLocationInUri[0] = sm.getVar('var://service/URI').lastIndexOf('/');
        var remoteTargetQuery = {"test": sm.getVar('var://service/URI').substr(queryLocationInUri[0]+1)};
        var domain = remoteTargetQuery.test.substr(0,remoteTargetQuery.test.indexOf('-'));
        var object = remoteTargetQuery.test.substr(remoteTargetQuery.test.indexOf('-') + 1);
        console.log(domain+object);

        remoteTargets.RemoteHostStatus.forEach(function(remote, index){
          // console.log(domain+object);
          // console.log(JSON.stringify(remote));
          if(remote.domain == domain && remote.objectName == object){
            console.log(JSON.stringify(remote));
            console.log(domain+object);
            connectionTest(remote.remoteHost, remote.objectType, 'https://dpanda.xml.mgmt:5550/service/mgmt/current', function(result){
            remote.linkStatus = result;
            session.output.write(remote);
          })};
        });
        session.output.write(remoteTargets);
      }
    });
