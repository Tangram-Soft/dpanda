// input json:
//   {"filename":"local://dpanda/local/...", "data": "base 64 encoded data"}
//
session.input.readAsJSON(function(error, json){
  if(error){
      console.error(error.errorMessage);
  } else {
    var ctx = session.createContext('uploadFile');
    ctx.setVariable('fileName', json.filename);
    ctx.setVariable('data', json.data);
    console.log(json.data);
    session.output.write('<output/>');
  }
});
