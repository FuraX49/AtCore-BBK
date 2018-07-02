import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtCharts 2.0


Page {
    id : charttemp
    width: 800
    height: 480
    property bool replace :  false
    property int  maxtime:  180
    property int  maxtemp:  300

    function addTemps(sonde,temp,target) {

        switch (sonde ) {
        case 0 : // E0
            graphTemp.addTemp(chart.series(0),0,temp);
            graphTemp.addTemp(chart.series(1),1,target);
            break

        case 1 : // Bed
            graphTemp.addTemp(chart.series(2),2,temp);
            graphTemp.addTemp(chart.series(3),3,target);
            break

        case 2 : // T1
            graphTemp.addTemp(chart.series(4),4,temp);
            graphTemp.addTemp(chart.series(5),5,target);
            break

        case 3 : // T2
            graphTemp.addTemp(chart.series(6),6,temp);
            graphTemp.addTemp(chart.series(7),7,target);
            break

        case 4 : // T3
            graphTemp.addTemp(chart.series(8),8,temp);
            graphTemp.addTemp(chart.series(9),9,target);
            break
        }
    }


    ChartView {
        id : chart
        anchors.margins: 0
        localizeNumbers: false
        visible: true
        enabled: false
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        anchors.fill: parent
        antialiasing: true
        animationOptions :ChartView.NoAnimation
        legend {
            alignment : Qt.AlignBottom
            showToolTips : true
        }


        // TODO DateTimeAxis
        ValueAxis{
            id: valueAxisX
            labelsAngle: -90
            min:0
            max:  charttemp.maxtime
            titleText: "mn"
            tickCount: 12
            labelFormat:  "%i"
        }

        ValueAxis{
            id: valueAxisY
            min:0
            max: charttemp.maxtemp
            titleText: "°C"
            tickCount: (maxtemp/25)+1
            labelsVisible : true
          }


        LineSeries {
            id: serieExt0
            style : Qt.SolidLine
            name : "E0"
            axisX: valueAxisX
            axisY: valueAxisY
            width : 2

        }

        LineSeries {
            id: serieExt0Target
            style : Qt.DashLine
            name : "TargetE0"
            axisX: valueAxisX
            axisY: valueAxisY
        }
    }

    function init(){
        chart.removeAllSeries();



        var seriesE0 = chart.createSeries(ChartView.SeriesTypeLine, "E0", valueAxisX, valueAxisY);
        var seriesTargetE0 = chart.createSeries(ChartView.SeriesTypeLine, "TargetE0", valueAxisX, valueAxisY);
        seriesTargetE0.style =  Qt.DashLine
        seriesE0.useOpenGL=false

        if ( cfg_HeatBed) {
            var seriesBed = chart.createSeries(ChartView.SeriesTypeLine, "Bed", valueAxisX, valueAxisY);
            var seriesTargetBed = chart.createSeries(ChartView.SeriesTypeLine, "TargetBed", valueAxisX, valueAxisY);
            seriesTargetBed.style=  Qt.DashLine
        }

        if (cfg_ExtCount.valueOf()>1) {
            var seriesE1 = chart.createSeries(ChartView.SeriesTypeLine, "E1", valueAxisX, valueAxisY);
            var seriesTargetE1 = chart.createSeries(ChartView.SeriesTypeLine, "TargetE1", valueAxisX, valueAxisY);
            seriesTargetE1.style=  Qt.DashLine
        }

        if (cfg_ExtCount.valueOf()>2) {
            var seriesE2 = chart.createSeries(ChartView.SeriesTypeLine, "E2", valueAxisX, valueAxisY);
            var seriesTargetE2 = chart.createSeries(ChartView.SeriesTypeLine, "TargetE2", valueAxisX, valueAxisY);
            seriesTargetE2.style=  Qt.DashLine
        }

        if (cfg_ExtCount.valueOf()>3) {
            var seriesE3 = chart.createSeries(ChartView.SeriesTypeLine, "E3", valueAxisX, valueAxisY);
            var seriesTargetE3 = chart.createSeries(ChartView.SeriesTypeLine, "TargetE3", valueAxisX, valueAxisY);
            seriesTargetE3.style=  Qt.DashLine
        }


        graphTemp.initData(chart.count,charttemp.maxtime)
        // TODO update Ext (on/off & T°) on first M105 ?
    }

}
