#ifndef QL_SERVER_H
    #define QL_SERVER_H

#include <QTcpServer>
#include <QTcpSocket>
#include <QHostAddress>
#include <QVariant>
#include <QStringList>
#include <iostream>
#include <QDataStream>


class QlServer : public QTcpServer {
	Q_OBJECT
	
	public:
		QlServer(QObject* parent = 0);

		Q_INVOKABLE void listenPort(quint16 port);

		Q_INVOKABLE void pause();
		Q_INVOKABLE void resume();
		Q_INVOKABLE void close();

		Q_INVOKABLE bool paused();
		Q_INVOKABLE bool listening();

		Q_INVOKABLE void respond(const QString &response);
		Q_INVOKABLE void blob(const QList<QVariant> &blob);


	signals:
		void requestHandler(const QList<int> &request);

	private slots:
		void readClient();
		void discardClient();

	protected:
		void incomingConnection(qintptr socket);

	private:
		bool disabled;
		QString response_;
		QByteArray blob_;
};

#endif

