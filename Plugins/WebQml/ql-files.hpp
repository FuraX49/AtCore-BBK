#ifndef QL_FILES_H
    #define QL_FILES_H

#include <QString>
#include <QStringList>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QByteArray>
#include <QList>
#include <QVariant>
#include <QUrl>

#include <QtWidgets/QApplication>

class QlFiles : public QObject {
    Q_OBJECT

    public:
        QlFiles(QObject* parent=0);

        // convert url object to string local path
        Q_INVOKABLE QString urlToLocalFile(const QUrl &path);

		// get list of files in dir
        Q_INVOKABLE QStringList entryList(const QString &dir, const QStringList &nameFilters);

		// path separator
        Q_INVOKABLE QString separator();
        // current path
        Q_INVOKABLE QString currentPath();
        // convert path to absolute (starting from root)
        Q_INVOKABLE QString absolutePath(const QString &path);
        // convert path to canonic (starting from root, without relative links)
        Q_INVOKABLE QString canonicalPath(const QString &path);

		// check if file/dir exists
        Q_INVOKABLE bool exists(const QString &path);
        // check if path matches glob filter
        Q_INVOKABLE bool match(const QString &filter, const QString &path);
        // check if path is file
        Q_INVOKABLE bool isFile(const QString &path);
        // check if path is dir
        Q_INVOKABLE bool isDir(const QString &path);

		// get file size
        Q_INVOKABLE qint64  size(const QString &path);
        // get path
        Q_INVOKABLE QString path(const QString &path);
        // get name
        Q_INVOKABLE QString name(const QString &path);
        // get extension
        Q_INVOKABLE QString ext(const QString &path);

		// read string from file
        Q_INVOKABLE QString readString(const QString &path, const QString &codec);
        // write string to file
        Q_INVOKABLE bool    writeString(const QString &path, const QString &s, const QString &codec);

		// read bytes from file
        Q_INVOKABLE QList<QVariant> readBytes(const QString &path);
        // write bytes to file
        Q_INVOKABLE bool            writeBytes(const QString &path, const QList<QVariant> &b);

		// get array of command line parameters
		Q_INVOKABLE QStringList argv();

		static QStringList argv_;
		// initialize ARGV array

		static void argvSet(QApplication *app);


    private:
};

#endif

