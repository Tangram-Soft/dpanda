var urlopen = require ('urlopen');


function connectionTest(remoteUrl, xmlMgmtUrl, callback){

  var result;
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

  var options = {
    target: remoteUrl,
    timeout: 2,
    // method: 'POST',
    data: {},
  }

  if (remoteUrl.includes('https')){
    options.sslClientProfile = 'dpanda.api.ssl.client.profile'
  };

  console.log(JSON.stringify(options));

  // var options_xmlMgmt = {
  //       target: xmlMgmtUrl,
  //       sslClientProfile: 'dpanda.api.ssl.client.profile',
  //       headers: { 'Authorization' : 'Basic ZHBhbmRhOmRwYW5kYQ=='},
  //       method: 'post',
  //       timeout: 5,
  //       data: doActionTcpTest,
  //
  //   };

    urlopen.open(options, function(error,response){
      if (error){
        console.error(JSON.stringify(error))
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

    // urlopen.open(options_xmlMgmt, function(error,response){
    //   if (error) {
    //     console.error("urlOpen error: " + JSON.stringify(error));
    //     result = 'down';
    //     console.log(result);
    //     callback(result);
    //   } else {
    //     response.readAsBuffer(function(error, responseData) {
    //             if (error) {
    //                 console.error("readAsBuffer response error: " + JSON.stringify(error));
    //                 result = 'down';
    //                 callback(result);
    //                 console.log(result);
    //             } else {
    //                var responseDataAsString = responseData.toString();
    //                if (responseDataAsString.includes('OK')){
    //                  result = 'up';
    //                  console.log(remoteUrl + result);
    //                  callback(result);
    //
    //                } else {
    //                  result = 'down';
    //                  console.log(remoteUrl + result);
    //                  callback(result);
    //                }
    //              }});
    //   }
    //   // console.log(result);
    // });


}

session.input.readAsJSON(function(error, remoteTargets){
  if(error){
      session.output.write (error.errorMessage);
  } else {
    var counter = 0;
    remoteTargets.RemoteHostStatus.forEach(function(remote, index){
      if(remote.objectType != 'MQQM'){
          connectionTest(remote.remoteHost, 'https://dpanda.xml.mgmt:5550/service/mgmt/current', function(result){
          remote.linkStatus = result;
          remoteTargets.RemoteHostStatus[index] = remote;
          counter++;
          console.log(counter);
          if(remoteTargets.RemoteHostStatus.length == counter){
            session.output.write(remoteTargets);
          };
        })} else {
          counter++;
          console.log(counter);
          if(remoteTargets.RemoteHostStatus.length == counter){
            session.output.write(remoteTargets);
          };
        };
  });

}});
