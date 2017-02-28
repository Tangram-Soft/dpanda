var updateTime;
var currentTime;
var dpandaGetDateTime = '/dpanda/api/status/dateTime';

function displayClock() {
  if (currentTime - updateTime > 300000) {
    $.get(dpandaGetDateTime)
    .fail(function(){
      //Handle error
    })
    .done(function(dateTimeResponse) {
      updateTime = new Date(Date.parse(dateTimeResponse["timestamp"]));
      currentTime = updateTime;
    });
  };
  currentTime =  new Date(currentTime.getTime() + 1000);
  document.getElementById("clock").innerHTML = currentTime.toUTCString();
  proceed=setTimeout(displayClock,1000);
};


var initFunc = function(){
  $.get(dpandaGetDateTime)
  .fail(function(){
    //Handle error
  })
  .done(function(dateTimeResponse) {
    updateTime = new Date(Date.parse(dateTimeResponse["timestamp"]));
    currentTime = updateTime;
    document.getElementById("clock").innerHTML = currentTime.toUTCString();
    proceed=setTimeout(displayClock,1000);
  });

}
$(initFunc);
