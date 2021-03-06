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

#ifndef GRAPHTEMP_H
#define GRAPHTEMP_H

#include <QtCore/QObject>
#include <QtCore/QtMath>
#include <QQuickView>
#include <QtCharts/QAbstractSeries>

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE

class GraphTemp : public QObject
{
    Q_OBJECT
public:
    explicit GraphTemp(QQuickView *appViewer, QObject *parent = 0);

public slots:
    void initData(int serieCount, int MesCount);
    void addTemp(QAbstractSeries *series, int serieNum, qreal Temp);

private:
    QQuickView *m_appViewer;
    QList<QVector<QPointF> > m_data;
};

#endif // GRAPHTEMP_H
