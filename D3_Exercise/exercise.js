window.onload = function() {
    d3.csv("PedestrianCountingSystemWeekdaysAndWeekends.csv") 
        .row(function(d) { return { Day:String(d.Day),TimeofDay:Number(d.TimeOfDay), HourlyAverage:Number(d.HourlyAverage) };})
        .get(function(error,data){
        
        console.log(data);
        var height = 600;
        var width = 400;
        
        //var maxTime = d3.max(data, d => d.TimeOfDay)/*d3.max(data, function(d) { return d.TimeOfDay});
        //var day = d3.extend(data, function(d) {return d.Day});
        
        var keys = ["Weekday", "Weekend"];
        var maxHourlyAverage = d3.max(data, function(d) { return d.HourlyAverage});
        console.log(maxHourlyAverage);
        
        var y = d3.scaleLinear()
                .domain([0,maxHourlyAverage])
                .range([height,0]);
                        
        var x = d3.scaleTime()
                .domain([0,23])
                .range([0,width]);
        
        var yAxis = d3.axisLeft(y);
        var xAxis = d3.axisBottom(x);
        
        var svg = d3.select('body').append('svg')
                    .attr('height','100%')
                    .attr('width','100%')
        
        var chartGroup = svg.append('g')    
                            .attr('transform','translate(50,0)');
        var line1 = d3.line()
                        .x(function(d) {return x(d.TimeofDay);})
                        .y(function(d) {return y(d.HourlyAverage);})
        
        chartGroup.append('path').attr('d',line1(data));
        
        var dataNest = d3.nest()
        .key(function(d) {return d.Day;})
        .entries(data);

        
        chartGroup.append('g').attr('class','x axis').attr('transform','translate(0,'+height+')').call(xAxis);
        chartGroup.append('g').attr('class','y axis').call(yAxis);
    }) 
       
        
    
   /* svgCanvas.append("path")
      .attr("fill", "none")
      .attr("stroke", "steelblue")
      .attr("stroke-width", 1.5)
      .attr("d", d3.line()
        .x(function(d) { return x(d.TimeOfDay) })
        .y(function(d) { return y(d.HourlyAverage) })
        )*/
};