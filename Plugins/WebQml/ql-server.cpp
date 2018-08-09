#include "ql-server.hpp"
#include <stdint.h>

 // HttpDaemon is the the class that implements the simple HTTP server.
QlServer::QlServer(QObject* parent) : QTcpServer(parent), disabled(true) {
	response_ = QString();
	blob_ = QByteArray();
    //std::cout << "QlServer create...\n";
}

void QlServer::incomingConnection(qintptr socket){
	if (disabled) return;

	QTcpSocket* s = new QTcpSocket(this);
	connect(s, SIGNAL(readyRead()), this, SLOT(readClient()));
	connect(s, SIGNAL(disconnected()), this, SLOT(discardClient()));
	s->setSocketDescriptor(socket);

    //qWarning() << "QlServer new connection...\n";
}

void QlServer::listenPort(quint16 port){
	if (!isListening()){
		listen(QHostAddress::Any, port);
        qWarning() << "QlServer listening on http port "  << port ;
        resume();
	}
}

void QlServer::pause(){ disabled = true; }
void QlServer::resume(){ disabled = false; }

bool QlServer::paused(){ return disabled; }
bool QlServer::listening(){ return isListening(); }

void QlServer::close(){
    qWarning() << "QlServer closing...\n";
	QTcpServer::close();
}

void QlServer::respond(const QString &response){
	response_.clear();
	response_ = response;
    //qWarning() << "QlServer response set to ...\n";
}
void QlServer::blob(const QList<QVariant> &blob){
	blob_.clear();
	for (int i=0; i<blob.length(); i++) blob_.append((uint8_t)blob[i].toInt(0) & 0xFF);
}

void QlServer::readClient(){
	if (disabled) return;

    //std::cout << "QlServer request...\n";

	QTcpSocket* socket = (QTcpSocket*)sender();
	if (socket->canReadLine()){
		QByteArray bytes = socket->readAll();
		QList<int> request = QList<int>();
		for (int i=0; i<bytes.length(); i++) request.append(bytes[i]);
		response_.clear(); blob_.clear();
		emit requestHandler(request);
        QDataStream os(socket);
		QByteArray b = response_.toUtf8();
		for (int i=0; i<b.length(); i++) os << (uint8_t)b[i];
		for (int i=0; i<blob_.length(); i++) os << (uint8_t)blob_[i];
		socket->close();
		if (socket->state() == QTcpSocket::UnconnectedState) delete socket;
	}
}
void QlServer::discardClient(){
    //qWarning() << "QlServer request discarded...\n";
	QTcpSocket* socket = (QTcpSocket*)sender();
	socket->deleteLater();
}

