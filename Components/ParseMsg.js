.pragma library
var strmsg =""
var mreg
var tempdata


// test if begin with Ok
var regOk = new RegExp(/^ok/i)
var isOk = false
function testOk() {
    isOk=Boolean(false);
    if (regOk.test(strmsg)) {
        isOk=Boolean(true);
    }
    return isOk;
}

// ************************ M105 *************************************
// ok T:0.0/0.0 T1:0.0/0.0 T0:0.0/0.0 B:0.0/0.0 @:0.0
// test if contains "B:" & "T:"
var regTest105 = new RegExp(/T:.+B:|B:.+T:/i)
var isM105 = false
var reg105 = new RegExp(/([BT]\d?:)(\d+\.\d{0,2})\/(\d+\.\d{0,2})/i)
var TempHeaters = {
    Bed: 0.0,
    TargetBed : 0.0,
    E0: 0.0,
    TargetE0 : 0.0,
    E1: 0.0,
    TargetE1 : 0.0,
    E2: 0.0,
    TargetE2 : 0.0,
    E3: 0.0,
    TargetE3 : 0.0
}

function testM105() {
    isM105 = false;
    if (regTest105.test(strmsg) ) {
        tempdata = strmsg.split(" ");
        for (var i = 0; i < tempdata.length; i++) {
            mreg =reg105.exec(tempdata[i]);
            if (mreg ) {
                isM105 = true;
                switch (mreg[1][0] ) {
                case  'B' :
                    TempHeaters.Bed =parseFloat(mreg[2]);
                    TempHeaters.TargetBed =parseFloat(mreg[3]);
                    break;
                case  'T' :
                    var ExtNum =mreg[1][1]===":"?0:mreg[1][1].valueOf();
                    TempHeaters["E"+ExtNum]=parseFloat(mreg[2]);
                    TempHeaters["TargetE"+ExtNum]=parseFloat(mreg[3]);
                    break;
                }
            }
        }
    }
    return isM105;
}


// ************************ M114 ********************************************
// ok  A:0.0 mm B:0.0 mm C:0.0 mm E:0.0 mm H:0.0 mm X:0.0 mm Y:0.0 mm Z:0.0 mm
// test if contains "E:" & "Z:"
var regTest114 = new RegExp(/E:.+Z:|Z:.+E:/i)
var isM114 = false
var reg114 = new RegExp(/([ABCEHXYZ]:)\s?([+-]?\d+\.\d{0,3})/gi)
var AxesPos = {
    A : 0.0,
    B : 0.0,
    C : 0.0,
    E : 0.0,
    H : 0.0,
    X : 0.0,
    Y : 0.0,
    Z : 0.0
}

function testM114() {
    isM114 = false;
    if (regTest114.test(strmsg) ) {
        tempdata = strmsg.split(" ");
        for (var i = 0; i < tempdata.length; i++) {
            mreg =reg114.exec(tempdata[i]);
            if (mreg ) {
                isM114 = true;
                AxesPos[mreg[1][0]]=parseFloat(mreg[2]);
            }
        }
    }
    return isM114;
}



//************************************  M119 ****************************
// ok X1: True, X2: False, Y1: True, Y2: False, Z1: True, Z2: True
// test if contains "X1:" & "X2:"
var regTest119 = new RegExp(/X1:.+Z2:/i)
var isM119 = false
var reg119 = new RegExp(/([ABCEHXYZ]:)\s?([+-]?\d+\.\d{0,3})/gi)
var EndStop = {
    X1 : false,
    X2 : false,
    Y1 : false,
    Y2 : false,
    Z1 : false,
    Z2 : false
}

function testM119() {
    isM119 = false;
    if (regTest119.test(strmsg) ) {
        mreg = strmsg.match(/(X1)\s?:\s?(False|True)..?(X2)\s?:\s?(False|True)..?(Y1)\s?:\s?(False|True)..?(Y2)\s?:\s?(False|True)..?(Z1)\s?:\s?(False|True)..?(Z2)\s?:\s?(False|True)/i);
        if (mreg) {
            if (mreg.index>1) {
                isM119 = true;
                EndStop.X1=mreg[2];
                EndStop.X2=mreg[4];
                EndStop.Y1=mreg[6];
                EndStop.Y2=mreg[8];
                EndStop.Z1=mreg[10];
                EndStop.Z2=mreg[12];
            }
        }
    }
    return isM119;
}


// ************* probe_point ************************
// G29 S (macro dor bed leveling)
// M561 (Reset bed matrix...but no message, so detect a G28
// Homing done
// G30 (Probe the bed at the current position, or if specified, a point)
// Found Z probe distance -0.08 mm at (X, Y) = (188.00, 120.00)
// M561 S ;(show bed matrix)
// Current bed compensation matrix: [[1.0, 0.0, 0.03382736610020862], [0.0, 1.0, 0.05115659072992756], [-0.03271925522123609, -0.04866334125223939, 1.0]]

var ProbeMatrix = []
var isM561 = false
var isG30=false
var isM561_S = false

function testM561() {
    isM561= false;
    if (strmsg.startsWith("Homing done",0 ) >0 ) {
        isM561 = true;
        ProbeMatrix = [];
    }
    return isM561 ;

}


function testG30() {
    isG30=false;
    if (strmsg.startsWith("Found Z probe distance",0 ) >0 ) {
        mreg = strmsg.match(/([+-]?\d+\.\d{0,3})\s?mm.*\(\s?([+-]?\d+\.\d{0,3})\s?,\s?([+-]?\d+\.\d{0,3})\s?\)/i );
        if (mreg) {
            isG30=true;
            ProbeMatrix.push({ X: parseFloat(mreg[2]) , Y : parseFloat(mreg[3]) , Z  : parseFloat(mreg[1]) });
        }
        return isG30;
    }
}

function testM561_S() {
    isM561_S=false;
    if (strmsg.startsWith("Current bed compensation matrix",0 ) >0 ) {
        isM561_S=true;
    }
    return  isM561_S;
}


// ************* File Descriptor ************************
var FileDesc = {
    fileName : "",
    fileSize : 0
}
var isEF = false;
var isBF = false;
var isFile = false;
var isSDPrinting = false;

var FileList = false;
// Begin file list:
// /lcl/.metadata.yaml 182
// /lcl/treefrog.stl 11810826
// /lcl/calibration-cube.stl 1627
// End file list

function testBeginFile() {
    isBF = false;
    if (strmsg.startsWith("Begin file list",0 ) >0 ) {
        isBF=true;
        FileList=true;
    }
    return isBF;
}


function testFileDesc() {
    isFile = false;
    var regex = /^(.+)\s+(\d+)$/;
    var mreg = new RegExp(regex);
    var  m = strmsg.match(mreg) ;
    if (m) {
        FileDesc.fileName=m[1];
        FileDesc.fileSize=m[2];
        isFile = true;
    }
    return isFile;
}

function testEndFile() {
    isEF = false;
    if (strmsg.startsWith("End file list",0 ) >0 ) {
        isEF=true;
        FileList=false;
    }
    return isEF;
}

function testSDPrinting() {
    isSDPrinting = false;
    if (strmsg.startsWith("SD printing byte",0 ) >0 ) {
        isSDPrinting=true;
    }
    return isSDPrinting;
}


// match file gcode extension in FileDesc.FileName
function isGcodeFile() {
    var isGCode = false;
    var regex = /\.(gcode|gco)/i;
    var mreg = new RegExp(regex);
    var  m = FileDesc.fileName.match(mreg) ;
    if (m) {
        isGCode=true;
    }
    return isGCode;

}
