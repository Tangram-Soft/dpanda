var urlopen = require ('urlopen');


function connectionTest(remoteUrl, xmlMgmtUrl, callback){

  var result;
  var host = remoteUrl.slice(0,remoteUrl.indexOf(':'));
  var port = remoteUrl.slice(remoteUrl.indexOf(':')+1);
  console.log(host + ' ' + port)

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
