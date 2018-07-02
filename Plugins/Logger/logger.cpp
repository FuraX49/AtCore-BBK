

#include "logger.h"
#include <QVariant>


LogModel::LogModel(QObject *parent) : QObject(parent)
{
    connect( this, SIGNAL( getLatest()),
             this, SLOT( onGetLatest()),
             Qt::DirectConnection );
    m_count = 50;
    m_myData.clear();
}

void LogModel::setLogLines()
{
    QString item("Name: %1");
    for(int i = 0; i < 5; ++i)
    {
        m_myData.append(item.arg(i+1));
    }
    emit dataListChanged();
}

void LogModel::addLogLine(const QString& value)
{

    m_myData.append(value);
    while (m_myData.count()>m_count) m_myData.pop_front();
    emit dataListChanged();
}

void LogModel::onGetLatest()
{
    /// Update the model and emit the signal. So that QML will update.
    addLogLine("from C++");
}

QStringList LogModel::dataList()
{
    return m_myData;
}

int LogModel::linecount()
{
    return m_count;
}

void LogModel::setlinecount(int number)
{
    if (m_count != number) {
        m_count = number;
        emit linecountChanged();
    }
}
