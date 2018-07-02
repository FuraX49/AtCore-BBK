#include "ql-files.hpp"
#include <stdint.h>

QlFiles::QlFiles(QObject* parent) : QObject(parent) { }

QString QlFiles::urlToLocalFile(const QUrl &path){ return path.toLocalFile(); }

QStringList QlFiles::entryList(const QString &dir, const QStringList &nameFilters){ return QDir(dir).entryList(nameFilters); }

QString QlFiles::separator(){ return QDir::separator(); }
QString QlFiles::currentPath(){ return QDir::currentPath(); }
QString QlFiles::absolutePath(const QString &path){ return QFileInfo(path).absolutePath(); }
QString QlFiles::canonicalPath(const QString &path){ return QFileInfo(path).canonicalPath(); }

bool QlFiles::exists(const QString &path){ return QFileInfo(path).exists(); }
bool QlFiles::match(const QString &filter, const QString &path){ return QDir::match(filter,path); }
bool QlFiles::isFile(const QString &path){ return QFileInfo(path).isFile(); }
bool QlFiles::isDir(const QString &path){ return QFileInfo(path).isDir(); }

qint64  QlFiles::size(const QString &path){ return QFileInfo(path).size(); }
QString QlFiles::path(const QString &path){ return QFileInfo(path).path(); }
QString QlFiles::name(const QString &path){ return QFileInfo(path).fileName(); }
QString QlFiles::ext(const QString &path){ return QFileInfo(path).suffix(); }

QString QlFiles::readString(const QString &path, const QString &codec){
    QFile f(path);
    if (!f.open(QFile::ReadOnly)) return QString("");
    QTextStream fin(&f);
    fin.setCodec(codec.toLatin1().data());
    QString s = fin.readAll();
    f.close();
    return s;
}

bool QlFiles::writeString(const QString &path, const QString &s, const QString &codec){
    QFile f(path);
    if (!f.open(QFile::WriteOnly)) return false;
    QTextStream fout(&f);
    fout.setCodec(codec.toLatin1().data());
    fout << s;
    f.close();
    return true;
}

QList<QVariant> QlFiles::readBytes(const QString &path){
    QFile f(path);
    QList<QVariant> l = QList<QVariant>();
    if (f.open(QFile::ReadOnly)){
        QByteArray b = f.readAll();
        f.close();
        for (int i=0; i<b.size(); i++) l.append(QVariant(b[i]));
    }
    return l;
}

bool QlFiles::writeBytes(const QString &path, const QList<QVariant> &b){
    QFile f(path);
    if (!f.open(QFile::WriteOnly)) return false;
    QDataStream fout(&f);
    for (int i=0; i<b.size(); i++)
    	fout << (uint8_t)(b[i].toInt(0) & 0xFF);
    f.close();
    return true;
}

QStringList QlFiles::argv_ = QStringList();
void QlFiles::argvSet(QApplication *app){ argv_.append( app->arguments() ); }
QStringList QlFiles::argv(){ return QlFiles::argv_; }

Q_DECLARE_METATYPE(QlFiles*)
