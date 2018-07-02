/* AtCore-BBK  QML GUI for 3D Printer
    Copyright (C) <2017>
    Author: furax44@free.fr

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

#include "graphtemp.h"
#include <QtCharts/QXYSeries>
#include <QtCharts/QAreaSeries>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QtCore/QDebug>
#include <QtCore/QtMath>
#include <QtCore/QDateTime>

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries *)
Q_DECLARE_METATYPE(QAbstractAxis *)

GraphTemp::GraphTemp(QQuickView *appViewer, QObject *parent) :
    QObject(parent),
    m_appViewer(appViewer)
{
    qRegisterMetaType<QAbstractSeries*>();
    qRegisterMetaType<QAbstractAxis*>();
    // 15 mn =15*12
    initData( 2, 180);
}

void GraphTemp::addTemp(QAbstractSeries *series,int serieNum,qreal Temp)
{
    // TODO : find index of serie ....
    if (qIsNaN(Temp)) Temp=0;
    if (series) {
        if (serieNum<m_data.count()) {
            QXYSeries *xySeries = static_cast<QXYSeries *>(series);
            QVector<QPointF> vp = m_data.at(serieNum);
            QPointF p;
            int max = vp.size()-1;
            for (int i(0); i <max; i++) {
                p=vp.at(i+1);
                p.setX(i);
                vp.replace(i,p);
            }
            vp.replace(max,QPointF(max,Temp));
            m_data.replace(serieNum,vp);
            xySeries->replace(vp);
        } else {
            qDebug() << "Error index series in GraphTemp.addTemp()";
        }
    }

}

void GraphTemp::initData(int serieCount, int MesCount)
{
    m_data.clear();
    for (int i(0); i < serieCount; i++) {
        QVector<QPointF> points;
        points.reserve(MesCount);
        qreal x(0);
        qreal y(0);
        for (int j(0); j < MesCount; j++) {
            x = j;
            points.append(QPointF(x, y));
        }
        m_data.append(points);
    }

}
