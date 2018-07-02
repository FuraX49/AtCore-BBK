#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>

class LogModel : public QObject
{
    Q_OBJECT
public:
    explicit LogModel(QObject *parent = 0);
    Q_PROPERTY(QStringList dataList READ dataList NOTIFY dataListChanged)
    Q_PROPERTY(int  linecount READ linecount WRITE setlinecount NOTIFY linecountChanged)
    Q_INVOKABLE void setLogLines();
    Q_INVOKABLE void addLogLine(const QString& value);
    QStringList dataList();
    int linecount();

signals:
    void getLatest();
    void dataListChanged();
    void linecountChanged();

public slots:
    void onGetLatest();
    void setlinecount(int number);

private:
    QStringList m_myData;
    int m_count;
};
#endif // LOGGER_H
