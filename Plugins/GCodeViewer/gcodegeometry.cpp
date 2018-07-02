/* Atelier KDE Printer Host for 3D Printing
    Copyright (C) <2017>
    Author: Patrick José Pereira - patrickelectric@gmail.com

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 3 of
    the License or any later version accepted by the membership of
    KDE e.V. (or its successor approved by the membership of KDE
    e.V.), which shall act as a proxy defined in Section 14 of
    version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "gcodegeometry.h"

#include <QList>
#include <QFile>
#include <QVector3D>
#include <QString>
#include <QTextStream>
#include <QVariant>
#include <QDebug>



#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/sysinfo.h>

quint64 getTotalMem() {
    struct sysinfo meminfo;
    sysinfo(&meminfo);
#ifdef DESKTOP // 64bits
    return meminfo.totalram;
#else // 32bits
    return meminfo.totalram / 1024 ;
#endif
}

quint64 getFreeMem() {
    struct sysinfo meminfo;
    sysinfo(&meminfo);
#ifdef DESKTOP // 64bits
    return meminfo.freeram;
#else // 32bits
    return meminfo.freeram / 1024 ;
#endif
}



namespace
{
const static QString _commentChar = QStringLiteral(";");
const static QStringList _moveCommands = {QStringLiteral("G0"), QStringLiteral("G1")};
const static QString _space = QStringLiteral(" ");

const static QString __X = QStringLiteral("X");
const static QString __Y = QStringLiteral("Y");
const static QString __Z = QStringLiteral("Z");
const static QString __E = QStringLiteral("E");
}

GCodeGeometry::GCodeGeometry(const QString &name, Qt3DCore::QNode *parent) :
    Qt3DRender::QGeometry(parent)
  , _positionAttribute(new Qt3DRender::QAttribute(this))
  , _vertexBuffer(new Qt3DRender::QBuffer(this))
{
    QFile _file(name);
    if (_file.open(QIODevice::ReadOnly)) {
        qint64 fileSize = _file.bytesAvailable();
        int estimedVectors = fileSize/ 30;
        qint32 freemem = getFreeMem()  ;

        qint32 possibleVectors=freemem/( sizeof(float));
        int stepsize = estimedVectors / possibleVectors ;

        if (stepsize<1) {
            stepsize= 1;
        } else {
            estimedVectors = estimedVectors / stepsize;
        }

        int step=stepsize; //
        qint32 idx =0;
        _vertices_count =0;
        _vertexBufferData.resize(estimedVectors * 3 * sizeof(float));
        float *_rawVertexArray = reinterpret_cast<float *>(_vertexBufferData.data());

        QTextStream in(&_file);
        QVector3D lastlPos;
        lastlPos=QVector3D(0,0,0);
        while (!in.atEnd()) {
            //Get each line
            QString line = in.readLine();

            line = line.simplified();
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

            if (_moveCommands.contains(commAndArgs[0])) {
                QVector3D actualPos;

                //Compute args
                commAndArgs.removeFirst();
                for (QString element : commAndArgs) {
                    if (element.contains(__X)) {
                        actualPos.setX(element.remove(0, 1).toFloat() / 10);
                    }

                    if (element.contains(__Y)) {
                        actualPos.setY(element.remove(0, 1).toFloat() / 10);
                    }

                    if (element.contains(__Z)) {
                        actualPos.setZ(element.remove(0, 1).toFloat() / 10);
                    }

                }

                if (!line.contains(__X)) {
                    actualPos.setX(lastlPos.x());
                }

                if (!line.contains(__Y)) {
                    actualPos.setY(lastlPos.y());
                }

                if (!line.contains(__Z)) {
                    actualPos.setZ(lastlPos.z());
                }
                step++;

                if (step>=stepsize) {
                    step=0;
                    _rawVertexArray[idx++] = actualPos.x();
                    _rawVertexArray[idx++] = actualPos.y();
                    _rawVertexArray[idx++] = actualPos.z();
                    lastlPos=actualPos;
                    _vertices_count++;
                    if (_vertices_count>=estimedVectors) {
                        estimedVectors=estimedVectors+30;
                        _vertexBufferData.resize(estimedVectors * 3 * sizeof(float));
                        qDebug()<< " RESIZE vertexBufferData :" << estimedVectors;
                    }
                }
            }
        }
        _file.close();

        _vertexBuffer->setData(_vertexBufferData);

        _positionAttribute->setAttributeType(Qt3DRender::QAttribute::VertexAttribute);
        _positionAttribute->setBuffer(_vertexBuffer);
        _positionAttribute->setVertexBaseType(Qt3DRender::QAttribute::Float);
        _positionAttribute->setVertexSize(3);
        _positionAttribute->setCount(idx++);
        _positionAttribute->setByteOffset(0);
        _positionAttribute->setName(Qt3DRender::QAttribute::defaultPositionAttributeName());
        addAttribute(_positionAttribute);
    }
}

GCodeGeometry::~GCodeGeometry()
{
    removeAttribute(_positionAttribute);
}


int GCodeGeometry::vertexCount()
{
    return _vertices_count;
}


