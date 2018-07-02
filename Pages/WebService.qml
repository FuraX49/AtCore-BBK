import QtQuick 2.11
import QtQml 2.11
import QlFiles 1.0

import "../Plugins/WebQml"
import "../Components/JobState.js" as JS
import "../Components/ParseMsg.js" as PM

// ************ Web Service *************
QlServer {
    id : qlserver
    port: cfg_WebPort
    enabled: cfg_WebActive
    filesDir: './static';
    QlFiles  { id:m_file }
    callback: function(req,resp){
        try {
            if ((resp.served===false ) && (req.url==="/api/job")) {

                if (req.method === 'POST')  {
                    var jsoncmd = JSON.parse(req.content);
                    var cmd=jsoncmd.command;
                    if (cmd==="start") {
                        terminal.appmsg("web START PRINT");
                        mainpage.tbPrint.clicked();
                    } else if (cmd==="cancel") {
                        terminal.appmsg("web CANCEL PRINT");
                        mainpage.tbCancel.clicked();
                    } else if (cmd==="emergency") {
                        terminal.appmsg("web EMERGENCY");
                        mainpage.tbEmergency.clicked();
                    } else if (cmd==="pause") {
                        var action=jsoncmd.action;
                        if ((action==="pause")  || ((action==="resume"))) {
                            terminal.appmsg("web PAUSE " + action);
                            mainpage.tbPause.clicked();
                        }
                    }
                }
                resp.headers['Content-Type'] = types.json;
                resp.content = JSON.stringify({
                                                  file: {
                                                      name:  JS.JobFile.name,
                                                      origin: JS.JobFile.origine,
                                                      size: JS.JobFile.size,
                                                      date: JS.JobFile.date,
                                                      fileselected : JS.JobFile.fileselected,
                                                  },
                                                  progress: {
                                                      completion: JS.JobProgress.completion,
                                                      estimatedTime: JS.JobProgress.estimatedTime,
                                                      finishTime: JS.JobProgress.finishTime,
                                                      remainingTime: JS.JobProgress.remainingTime
                                                  },
                                                  state: {
                                                      state : JS.JobState.state,
                                                      connected : JS.JobState.connected,
                                                      print : JS.JobState.print,
                                                      pause : JS.JobState.pause,
                                                      resume : JS.JobState.resume,
                                                      cancel : JS.JobState.cancel,
                                                      error : JS.JobState.error
                                                  },
                                                  temperatures: {
                                                      bed : PM.TempHeaters.Bed,
                                                      bedtarget : PM.TempHeaters.TargetBed,
                                                      e0 : PM.TempHeaters.E0,
                                                      e0target : PM.TempHeaters.TargetE0,
                                                      e1 : PM.TempHeaters.E1,
                                                      e1target : PM.TempHeaters.TargetE1,
                                                      e2 : PM.TempHeaters.E2,
                                                      e2target : PM.TempHeaters.TargetE2,
                                                      e3 : PM.TempHeaters.E3,
                                                      e3target : PM.TempHeaters.TargetE3
                                                  }
                                              });
                resp.served  = true;
            }

        }
        catch (E) {
            console.log("WebServer exception on :" + request.method,request.uri)
            resp.content = m_file.readString(filesDir+"/atcore.html",'utf8');
            resp.headers['Content-Type'] = "text/html; charset=UTF-8";
            resp.served  = true;
        }
        finally {
        }
    }

}
