#include "quickgcode.h"
//#include <qsgflatcolormaterial.h>
#include <QtQuick/QSGVertexColorMaterial>
#include <QtCore/QtMath>
#include <QColor>
#include <QElapsedTimer>

namespace
{
const static QString _commentChar = QStringLiteral(";");
const static QStringList _moveCommands = {QStringLiteral("G0"), QStringLiteral("G1")};
// G2 G3 for arc ?
const static QString _space = QStringLiteral(" ");

const static QString __X = QStringLiteral("X");
const static QString __Y = QStringLiteral("Y");
const static QString __Z = QStringLiteral("Z");
const static QString __E = QStringLiteral("E");
const static QString __F = QStringLiteral("F");
}




QuickGCode::QuickGCode(QQuickItem *parent)
    : QQuickItem(parent)
    ,m_filename(nullptr)
    ,m_nozzlesize(0.4f)
    ,m_pathcolor("blue")
    ,m_extcolor("red")
    ,m_layer(0)
    ,m_maxsegments(0)
{
    setFlag(QQuickItem::ItemHasContents , true);
    setAcceptTouchEvents(true);

}

QuickGCode::~QuickGCode()
{
    if(m_file.isOpen())  m_file.close();
}

int QuickGCode::layer() const
{
    return m_layer;
}

void QuickGCode::drawLayer(const int layer )
{
    if (layer == m_layer ) {
        return;
    }
    m_layer =layer;
    if (m_layer>m_layerPos.count())
        m_layer=m_layerPos.count();
    if (m_layer<0)
        m_layer=0;
    update();
    emit layerChanged();
}


QSGNode *QuickGCode::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    QSGGeometryNode *pathnode = nullptr;
    QSGGeometry *pathgeometry = nullptr;

    uchar re = m_extcolor.red(), ge = m_extcolor.green(), be = m_extcolor.blue(), ae = m_extcolor.alpha();
    uchar rp = m_pathcolor.red(), gp = m_pathcolor.green(), bp = m_pathcolor.blue(), ap = m_pathcolor.alpha();

    if (!oldNode) {

        pathnode = new QSGGeometryNode;
        pathgeometry = new QSGGeometry(QSGGeometry::defaultAttributes_ColoredPoint2D(),m_maxsegments); //bug on firts layer ! vertices are no

        pathgeometry->setLineWidth(m_nozzlesize*1.20f);
        pathgeometry->setDrawingMode(QSGGeometry::DrawLineStrip);
        pathnode->setGeometry(pathgeometry);
        pathnode->setFlag(QSGNode::OwnsGeometry);
        QSGVertexColorMaterial *material = new QSGVertexColorMaterial();

        pathnode->setMaterial(material);
        pathnode->setFlag(QSGNode::OwnsMaterial);



    } else {
        pathnode = static_cast<QSGGeometryNode *>(oldNode);
        pathgeometry = pathnode->geometry();
        pathgeometry->allocate(m_layerPos[m_layer].num_segment);
        pathgeometry->setLineWidth(m_nozzlesize*1.20f);

        QSGGeometry::ColoredPoint2D *vertices = pathgeometry->vertexDataAsColoredPoint2D();
        int min = m_layerPos[m_layer].pos_layer;
        int max = m_layerPos[m_layer].num_segment;
        for (int i = 0; i < max; ++i) {
            if (m_PathBuffer.at(i+min).Ext) {
                vertices[i].set(m_PathBuffer.at(i+min).X, m_PathBuffer.at(i+min).Y,re,ge,be,ae);
            } else {
                vertices[i].set(m_PathBuffer.at(i+min).X, m_PathBuffer.at(i+min).Y,rp,gp,bp,ap);

            }
        }
        pathnode->markDirty(QSGNode::DirtyGeometry);
    }

    return pathnode;
}


void QuickGCode::setSource(const QUrl &url)
{
    if (url.isEmpty()) {
        qWarning() << "GCodeParser empty fileName";
        return;
    }
    if (url == m_filename ) {
        return;
    }
    if(m_file.isOpen())  m_file.close();
    QString FileName = url.path();
    m_file.setFileName(FileName);
    if (!m_file.exists()) {
        qWarning() << "GCodeParser " + FileName + " not exist" ;
        return;
    }
    m_filename= url  ;

    emit sourceChanged(m_filename);
    emit layercountChanged(m_layerPos.size());
}


QUrl QuickGCode::source() const
{
    return m_filename;
}


float QuickGCode::nozzlesize() const
{
    return m_nozzlesize;
}

void QuickGCode::setnozzlesize(const float &size)
{
    if (size == m_nozzlesize) {
        return;
    }
    m_nozzlesize = size;
    update();
    emit nozzlesizeChanged(m_nozzlesize);
}


QColor  QuickGCode::pathcolor() const
{
    return m_pathcolor;

}
QColor  QuickGCode::extcolor() const
{
    return m_extcolor;
}


void QuickGCode::setPathColor(QColor arg)
{
    if (arg==m_pathcolor){
        return;
    }
    m_pathcolor=arg;
    update();
    emit pathcolorChanged();
}


void QuickGCode::setExtColor(QColor arg)
{
    if (arg==m_extcolor){
        return;
    }
    m_extcolor=arg;
    update();
    emit extcolorChanged();
}


qint32 QuickGCode::layercount() const
{
    return m_layerPos.size();
}



void QuickGCode::parseLayers()
{

    segment_struct actualPos;
    layer_struct layerinfo;

    m_layerPos.clear();
    m_layerPos.reserve(100);

    m_PathBuffer.clear();
    m_PathBuffer.reserve(25000);


    layerinfo.pos_layer=0;
    layerinfo.num_segment=0;

    m_maxsegments=0;
    QElapsedTimer timer;

    if (m_file.open(QIODevice::ReadOnly| QIODevice::Text)) {

        timer.start();
        QTextStream in(&m_file);
        while (!in.atEnd()) {

            //Get each line
            QString line = in.readLine().simplified();

            //Is it a comment ? Drop it
            if (line.isEmpty()) {
                continue;
            }

            //Remove comment in the end of command
            if (line.indexOf(_commentChar) != -1) {
                line.resize(line.indexOf(_commentChar));
                //Remove trailing spaces
                line = line.simplified();
            }

            //Split command and args
            QStringList commAndArgs = line.split(_space);

            if (_moveCommands.contains(commAndArgs[0],Qt::CaseSensitive )) {

                //Compute args
                commAndArgs.removeFirst();
                for (QString element : commAndArgs) {
                    if (element.contains(__X,Qt::CaseSensitive )) {
                        actualPos.X=element.mid(1).toFloat() ;
                        continue;
                    }

                    if (element.contains(__Y,Qt::CaseSensitive)) {
                        actualPos.Y=element.mid(1).toFloat() ;
                        continue;
                    }

                    // Detect extruded segment
                    if (element.contains(__E,Qt::CaseSensitive)) {
                        actualPos.Ext=true;
                    } else {
                        actualPos.Ext=false;
                    }

                    /* Use gradient color for rate ?
                    if (element.contains(__F,Qt::CaseSensitive)) {
                        actualPos.Rate=round(element.mid(1).toFloat()/1000) ;
                        continue;
                    }
                    */

                    if (element.contains(__Z,Qt::CaseSensitive)) {
                        layerinfo.pos_layer=m_PathBuffer.count();
                        m_layerPos.append( layerinfo);
                        if (layerinfo.num_segment>m_maxsegments)
                            m_maxsegments=layerinfo.num_segment;
                        layerinfo.num_segment=0;
                        continue;
                    }

                }
                m_PathBuffer.append(actualPos);
                layerinfo.num_segment++;


            }
        }

    }
    m_file.close();

    qWarning() << "Parselayers Time:" << timer.elapsed()  <<  "ms \tLayers:" << m_layerPos.count() << " \tSegments:" << m_PathBuffer.count()  << " \tMax segment/layer:" << m_maxsegments <<"\t File:" << m_filename ;

    emit layercountChanged(m_layerPos.size());

    update();
    emit parseFinish();

}

