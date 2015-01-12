/*jslint indent: 4, maxstatements: 24, unused: false */
/*global d3 */
//= require d3.chart.bubble-matrix

'use strict';

function percentile(array, n) {
    array.sort(function(a, b) {
        return a - b;
    });
    return array[parseInt(0.01 * n * array.length)];
}

function formatSeconds(s) {
    var output = [],
        d, h, m;

    if (s === 0) {
        return '';
    }
    
    d = s / (24 * 3600);
    s -= parseInt(d) * 24 * 3600;
    if (d > 1) {
        output = output.concat([d.toPrecision(2), 'days']);
    } else {
        h = parseInt(s / 3600);
        s -= h * 3600;
        if (h > 1) {
            output = output.concat([h, 'hrs']);
        } else {
            m = parseInt(s / 60);
            s -= m * 60;
            if (m > 1) {
                output = output.concat([m, 'mins']);
            } else {
                output = output.concat([s, 'secs']);
            }
        }
    }
    return output.join(' ');
}

function displayHistogram(where, dataSource, displayLines) {
    var margin, width, height, x, y, n, data, maxY, svg, bars, xAxis, medianValue, percentileValue;

    margin = {top: 10, right: 10, bottom: 30, left: 10};
    width = 960 - margin.left - margin.right;
    height = 500 - margin.top - margin.bottom;

    n = dataSource.length;

    x = d3.scale.linear().domain([0, d3.max(dataSource)]).range([0, width]);
    data = d3.layout.histogram().bins(40)(dataSource);
    maxY = d3.max(data, function(d) { return d.y; });
    y = d3.scale.linear().domain([0, maxY]).range([height, 0]);
    svg = d3.select(where).append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
        .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    bars = svg.selectAll('.bar').data(data).enter().append('g').attr('class', 'bar').attr('transform', function(d) {
        return 'translate(' + x(d.x) + ',' + y(d.y) + ')';
    });
    bars.append('rect').attr('x', 1).attr('width', x(data[0].dx)).attr('height', function(d) { return height - y(d.y); });
    bars.append('text')
        .attr('x', x(data[0].dx / 2))
        .attr('y', -3)
        .attr('font-size', 11)
        .attr('text-anchor', 'middle')
        .text(function(d) { var v = d.y; if (v > 0) { return v; } });
    xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(formatSeconds);
    svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + height + ')')
        .call(xAxis);

    if (n == 0) {
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'no-data-label')
            .attr('transform', 'translate(' + (width - 100) / 2 + ',' + height / 2 + ')')
            .text('No data to display');
        return;
    }

    if (displayLines) {
        medianValue = percentile(dataSource, 50);
        percentileValue = percentile(dataSource, 95);

        svg.append('line')
            .attr('x1', x(3 * 24 * 3600))
            .attr('x2', x(3 * 24 * 3600))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'three-days');
        svg.append('line')
            .attr('x1', x(percentileValue))
            .attr('x2', x(percentileValue))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'percentile');
        svg.append('line')
            .attr('x1', x(medianValue))
            .attr('x2', x(medianValue))
            .attr('y1', y(0))
            .attr('y2', y(maxY))
            .attr('class', 'median');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'three-days-label')
            .attr('transform', 'translate(' + (x(3 * 24 * 3600) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('three days');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'percentile-label')
            .attr('transform', 'translate(' + (x(percentileValue) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('95-th percentile');
        svg.append('text')
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'median-label')
            .attr('transform', 'translate(' + (x(medianValue) + 4) + ',' + y(maxY) + '),rotate(90)')
            .text('median');
    }
}

function displayWeeklyBreakdown(where, rawDataSource) {
    var weekdays, processedData, maxZ, chart, i, z;

    weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    processedData = { columns: [], rows: [] };

    for (i = 0; i < 24; i++) { processedData.columns.push(i); }

    maxZ = 0;
    rawDataSource.forEach(function(row) {
        var max = d3.max(row);
        if (max > maxZ) { maxZ = max; }
    });
    
    z = d3.scale.linear().domain([0, maxZ]).range([0, 1]);

    rawDataSource.forEach(function(row, i) {
        processedData.rows.push({name: weekdays[i], values: row.map(function(f) { return [z(f)]; })});
    });

    chart = d3.select(where).append('svg')
        .chart('BubbleMatrix')
        .width(960)
        .height(300);
    
    chart.draw(processedData);
}
