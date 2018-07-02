.pragma library

var JobFile = {
    name : "",
    origine : "",
    size : 0,
    date : "",
    fileselected : false
};

var JobProgress = {
    completion : 0,
    estimatedTime : "",
    finishTime :"",
    remainingTime:""
};

var JobState = {
    state : "",
    connected : false,
    print : false,
    pause : false,
    resume: false,
    cancel : false,
    error : false
};

var  started = new Date();

function initTime() {
    started =  Date.now();
    JobProgress.completion=0;
}

function updateTime(progress) {
    JobProgress.completion=progress;

    var elapsed =  Date.now() - started ;
    var estimated = new Date();
    estimated.setTime(Math.round(elapsed/(progress/100)));
    var finishing = new Date(started + estimated.getTime());
    var remaining = new Date();
    remaining.setTime(Math.round(estimated.getTime() - elapsed));

    JobProgress.estimatedTime=formatMachineTimeString(estimated);
    JobProgress.remainingTime=formatMachineTimeString(remaining);
    JobProgress.finishTime=finishing.toLocaleDateString('fr-FR') + " " +finishing.toLocaleTimeString('fr-FR');
}

function finishTime() {
    updateTime(100);
    JobProgress.remainingTime="finished";
}

function formatMachineTimeString(milliseconds)
{
    var minutes = Math.floor(milliseconds / 60000)
    var hours = Math.floor(minutes / 60);

    var timeString = (minutes < 1) ? "~ 1 min" : "> ";

    if (hours   > 0){timeString   += (hours + " h ");}
    if (minutes > 0){timeString   += ((minutes % 60) + " min");}

    return timeString;
}
