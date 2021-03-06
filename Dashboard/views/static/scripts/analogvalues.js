CanvasJS.addCultureInfo("de",
                {
                    days: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"],
                    shortDays: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"],
                    months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
                    shortMonths: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
               });

 function calculateAverage(data){
   var sum = data.reduce(function(sum, value){
     return sum + value;
   }, 0);

   var avg = sum / data.length;
   return avg;
 }

 function calculatePercentageOfValuesInRange(values, rangeLowerBound, rangeUpperBound){
   var countValuesInRange = values.reduce((prevVal, value) => {
     if (value <= rangeUpperBound && value >= rangeLowerBound){
       return prevVal + 1;
     }
     return prevVal;
   });

   return (countValuesInRange/values.length)*100;
 }

 function getNextHighestValue(arr, value) {
    var i = arr.length;
    while (arr[--i] > value);
    return arr[++i];
}

 function calculateNormalRange(data){
   var firstDate = data[0].x;
   var lastDate = data[data.length - 1].x;
   var values = data.map(entry => {return entry.y});
   var average = calculateAverage(values);
   var negativeValuesExist = false;
   for(var i = 0; i < values.length; i++){
     if(values[i] < 0){
       negativeValuesExist = true;
       values = values.map(entry => {return Math.abs(entry)});
       break;
     }
   }
   values.sort(function(a, b){return a-b});

   var deviation = 0;
   while(calculatePercentageOfValuesInRange(values, average - deviation, average + deviation) < 80){
     deviation = getNextHighestValue(values, average + deviation) - average;
   }

   var lowerBound = average - deviation;
   if(!negativeValuesExist){
     lowerBound = Math.max(0, lowerBound);
   }

   var dataSeries = { type: "rangeSplineArea" };
   dataSeries.dataPoints = [
     {x: firstDate, y: [lowerBound, average + deviation]},
     {x: lastDate, y: [lowerBound, average + deviation]}
   ];

   $("#text").text("Ca 80% der Werte liegen im blauen Bereich zwischen " + addCommas(lowerBound + "") + " und " + addCommas(average + deviation + ""));
   return dataSeries;
 }

function addCommas(nStr) {
    var valueAfterPoint = "";
    if(nStr.includes(".")){
      valueAfterPoint = "," + nStr.split(".")[1];
      if(valueAfterPoint.length > 3){
        valueAfterPoint = valueAfterPoint.substring(0, 3);
      }
      nStr = nStr.split(".")[0];
    }

    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + '.' + '$2');
    }

    return x1 + x2 + valueAfterPoint;
}

function loadData(value, dingroup, dateStart, dateEnd, type){
  $.ajax({
    url: "/api/analogValues",
    contentType: "application/json",
    type: "get", //send it through get method
    data: {
      value: value,
      dingroup: dingroup,
      dateStart: dateStart,
      dateEnd: dateEnd,
      includeZeros: $("#checkboxZero").parent().hasClass('checked')
    },
    success: function(response) {
      if(response.length == 0){
        $("#loadingImage").css("visibility", "hidden");
        alert("Zu diesem Filter existieren keine Daten");
        return;
      }
      var data = [];
      var dataSeries = { type: type };

      dataSeries.dataPoints = response.map((entry) => {
        entry.x = new Date(entry.x);
        return entry;
      });

      if($("#checkboxRange").parent().hasClass('checked')){
        data.push(calculateNormalRange(dataSeries.dataPoints));
      }
      data.push(dataSeries);
      drawChart(data);
    },
    error: function(err) {
      console.log("Error" + err);
    }
  });
}

function drawChart(data){
  var chart = new CanvasJS.Chart("chart1", {
    culture:  "de",
  	animationEnabled: true,
  	zoomEnabled: true,
    zoomType: "xy",
  	data: data
  });
  chart.render();
}

function drawPieChart(){
  var chart = new CanvasJS.Chart("chart2",
	{
		legend: {
			maxWidth: 350,
			itemWidth: 120
		},
		data: [
		{
			type: "pie",
			showInLegend: true,
			legendText: "{indexLabel}",
			dataPoints: [
				{ y: 145553, indexLabel: "DinGroup 34" },
				{ y: 1467952, indexLabel: "DinGroup 35" },
				{ y: 2881345, indexLabel: "DinGroup 36" },
				{ y: 9855, indexLabel: "DinGroup 37" },
				{ y: 218268, indexLabel: "DinGroup 38" },
				{ y: 1059028, indexLabel: "DinGroup 39" },
				{ y: 1097817, indexLabel: "DinGroup 40" },
				{ y: 49126, indexLabel: "DinGroup 41" },
				{ y: 3722, indexLabel: "DinGroup 42" },
				{ y: 23716, indexLabel: "DinGroup 43" },
				{ y: 9395, indexLabel: "DinGroup 44" },
				{ y: 811166, indexLabel: "DinGroup 2034" },
				{ y: 282138, indexLabel: "DinGroup 2035" },
				{ y: 572312, indexLabel: "DinGroup 2036" },
				{ y: 2141, indexLabel: "DinGroup 2037" },
				{ y: 38304, indexLabel: "DinGroup 2038" },
				{ y: 210181, indexLabel: "DinGroup 2039" },
				{ y: 9631, indexLabel: "DinGroup 2040" },
				{ y: 578, indexLabel: "DinGroup 2041" },
				{ y: 4627, indexLabel: "DinGroup 2042" },
				{ y: 2128, indexLabel: "DinGroup 2043" },
				{ y: 504262, indexLabel: "DinGroup 2044" },
				{ y: 710531, indexLabel: "DinGroup 2045" },
				{ y: 229, indexLabel: "DinGroup 2046" }
			]
		}
		]
	});
	chart.render();
}

function showLoadingView(){
  $("#chart1").empty();
  $("#chart1").append('<div id="loadingImage" ></div>');
  $("#loadingImage").css("visibility", "visible");
}

function updateValueNames(){
  $("#inputValue").empty();
  var selectedDingroup = $("#inputDingroup").val();
  if (!dingroupValues.hasOwnProperty(selectedDingroup)) {
    selectedDingroup = "default";
  }
  dingroupValues[selectedDingroup].forEach(entry => {
    $("#inputValue").append("<option>" + entry + "</option>");
  });
}

$( document ).ready(function() {
  $("#loadingImage").css("visibility", "hidden");
  drawPieChart();
  $('.input-daterange').datepicker({
    format: 'dd.mm.yyyy'
  });

  $( "#buttonShow" ).click(function() {
    showLoadingView();
    var dingroup = $("#inputDingroup").val();
    if (dingroup.includes("(")){
      dingroup = dingroup.substring(dingroup.lastIndexOf("(")+1,dingroup.lastIndexOf(")"));
    }
    $("#text").text("");
    loadData(parseInt(($("#inputValue").prop('selectedIndex') + 1) + ""), dingroup, $("#dateStart").val(), $("#dateEnd").val(), $("#inputVisualize").val())
  });

  $( "#inputDingroup" ).change(function() {
    updateValueNames();
  });

  updateValueNames();

  $(".checkbox").each(function() {
    $(this).iCheck({
      checkboxClass: 'icheckbox_line-blue',
      insert: '<div class="icheck_line-icon"></div>' + $(this).attr("text")
    });
  });
});
