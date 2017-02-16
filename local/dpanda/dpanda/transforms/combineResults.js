function createJson(context, i){
  /*this function extract the binary data from the Result action response and
   convert it to valid JSON object*/
    session.name(context + '_' + i).readAsBuffer(function (error, buffer) {
    if (error)
    {
        // Handle Error
        session.output.write (error.errorMessage);
      } else {
        var buffer = buffer.toString();
        //put the json object in context variable name 'data'
        session.name(context + '_' + i).setVariable('data', buffer);
        //transfer the json to function that arrange it in a Array and write
        createArray(context, i);
      }});

    };

function createArray(context, i){
      /*this function create an array that contains the result action responses. if
      last response is pushed into the array, write to output*/
        var currentArray = session.name(context).getVariable('Array');
        var currentData = JSON.parse(session.name(context + '_' + i).getVariable('data'));
        //pushed current response into the array
        if (session.name(context + '_' + i).getVariable('data'))
        {
          currentData.applianceId = session.name(context + '_' + i).getVariable('_extension/response-header/dpanda.id') ;
          currentArray.push(currentData);
        } else {
          currentArray.push({"error": "unable to parse json response"});};
        //rewrite the array into the context variable
        session.name(context).setVariable('Array', currentArray);
        i = i+1;
        //if i+1 response context does not exist, write output
        if(session.name(context + '_' + i) == undefined);
        session.output.write(
          {
            "data" :  session.name(context).getVariable('Array')
          }
        )
      };

function handleMultiResponse(context){
  /*this function calls for createJson function for each asyncoutput valid context*/
    var i = 1;
    while(session.name(context + '_' + i) != undefined){
      createJson(context, i);
      i =  i + 1;
    };

};



  //create an array variable for the formed json responses
  var dataArray = [];
  // set a variable named context, which has the value of the relevent output context.
  var context = 'asyncoutput';
  //put the array variable in dp context variable
  session.name(context).setVariable('Array', dataArray);
  //begin handling the result action responses
  handleMultiResponse(context);
