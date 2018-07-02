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

#pragma once

#include <QVector3D>
#include <Qt3DRender/QAttribute>
#include <Qt3DRender/QBuffer>
#include <Qt3DRender/QGeometry>
#include <Qt3DRender/QGeometryRenderer>

class GCodeGeometry : public Qt3DRender::QGeometry
{
    Q_OBJECT
public:
    GCodeGeometry(const QString &name, Qt3DCore::QNode *parent = Q_NULLPTR);
    ~GCodeGeometry();
    int vertexCount();

private:
    Qt3DRender::QAttribute *_positionAttribute;
    Qt3DRender::QBuffer *_vertexBuffer;
    QByteArray _vertexBufferData;
    float *_rawVertexArray;
    int _vertices_count;
};
