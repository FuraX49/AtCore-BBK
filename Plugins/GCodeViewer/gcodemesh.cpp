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

#include "gcodemesh.h"
#include "gcodegeometry.h"

#include <QVector3D>
#include <Qt3DRender/QGeometryRenderer>

GCodeMesh::GCodeMesh(Qt3DCore::QNode *parent)
    : Qt3DRender::QGeometryRenderer(parent)
    , _lineMeshGeo(nullptr)
    , m_source(nullptr)
{
    setInstanceCount(1);
    setIndexOffset(0);
    setFirstInstance(0);
//    setPrimitiveType(Qt3DRender::QGeometryRenderer::LineStrip);
        setPrimitiveType(Qt3DRender::QGeometryRenderer::Lines);
}

GCodeMesh::~GCodeMesh()
{
}


QUrl GCodeMesh::source() const
{
    return m_source;
}


void GCodeMesh::setSource(const QUrl &source)
{
    if (source.isEmpty()) {
        qWarning() << "GCodeGeometry empty URL";
        return;
    }
    QString path = QUrl(source).path();
    if (m_source == path)  return;
    m_source = path;

    if ( _lineMeshGeo!=nullptr) {
        delete (_lineMeshGeo);
    }
    _lineMeshGeo = new GCodeGeometry(path, this);
    setVertexCount(_lineMeshGeo->vertexCount());
    setGeometry(_lineMeshGeo);
    _vertices.clear();
    emit finished();
    emit sourceChanged(m_source);
 }

void GCodeMesh::posUpdate(const QVector<QVector3D> &pos)
{
    _vertices = pos;
    if ( _lineMeshGeo!=nullptr) {
        delete (_lineMeshGeo);
    }
    setVertexCount(_lineMeshGeo->vertexCount());
    setGeometry(_lineMeshGeo);
    _vertices.clear();
    emit finished();
    emit sourceChanged(m_source);
}

