/*
 * AMQConnectionFrame.h
 *
 *  Created on: Mar 20, 2009
 *      Author: Ian Zepp
 */

#ifndef AMQCONNECTIONFRAME_H_
#define AMQCONNECTIONFRAME_H_

#include <QtCore/QByteArray>
#include <QtCore/QDateTime>
#include <QtCore/QHash>
#include <QtCore/QString>
#include <QtCore/QUuid>
#include <QtXml/QDomDocument>

class AMQConnection;

class AMQConnectionFrame
{
public:
	enum CommandType
	{
		Connect, Connected, Subscribe, Unsubscribe, Acknowledge, Error, Message, Receipt, Disconnect, Unknown
	};

	enum Priority
	{
		Lowest = 0, Low = 1, Normal = 4, Expedited = 5, Highest = 9
	};
public:
	AMQConnectionFrame(AMQConnection *);
	AMQConnectionFrame(AMQConnection *, QByteArray);
	virtual ~AMQConnectionFrame();

	QByteArray toFrame();
	void acknowledge();
	void send();

public:
	AMQConnection *getConnection() const
	{
		return connection;
	}

	bool getAcknowledged() const
	{
		return getHeader("ack") == "client";
	}

	void setAcknowledged(bool acknowledged)
	{
		setHeader("ack", acknowledged ? "client" : "auto");
	}

	CommandType getCommandType() const
	{
		QString command = getCommand();

		if (command == "CONNECT")
			return Connect;
		else if (command == "DISCONNECT")
			return Disconnect;
		else if (command == "SUBSCRIBE")
			return Subscribe;
		else if (command == "UNSUBSCRIBE")
			return Unsubscribe;
		else if (command == "ACK")
			return Acknowledge;
		else if (command == "MESSAGE")
			return Message;
		else if (command == "RECEIPT")
			return Receipt;
		else if (command == "CONNECTED")
			return Connected;
		else if (command == "ERROR")
			return Error;
		else
			return Unknown;
	}

	void setCommandType(CommandType commandType)
	{
		switch (commandType)
		{
		case Connect:
			setCommand("CONNECT");
			break;

		case Disconnect:
			setCommand("DISCONNECT");
			break;

		case Subscribe:
			setCommand("SUBSCRIBE");
			break;

		case Unsubscribe:
			setCommand("UNSUBSCRIBE");
			break;

		case Acknowledge:
			setCommand("ACK");
			break;

		case Message:
			setCommand("MESSAGE");
			break;

		case Receipt:
			setCommand("RECEIPT");
			break;

		case Connected:
			setCommand("CONNECTED");
			break;

		case Error:
			setCommand("Error");
			break;

		default:
			break;
		}
	}

	QString getCorrelationId() const
	{
		return getHeader("correlation-id");
	}

	void setCorrelationId(QString correlationId)
	{
		setHeader("correlation-id", correlationId);
	}

	void setGeneratedCorrelationId()
	{
		setCorrelationId(QUuid::createUuid().toString());
	}

	QString getDestination() const
	{
		return getHeader("destination");
	}

	void setDestination(QString destination)
	{
		setHeader("destination", destination);
	}

	QString getId() const
	{
		return getHeader("id");
	}

	void setId(QString id)
	{
		setHeader("id", id);
	}

	QDateTime getExpiration() const
	{
		QString expiration = getHeader("expiration");

		if (expiration.isEmpty() || expiration == "0")
			return QDateTime::fromString("9999-12-31T23:59:59", Qt::ISODate);
		else
			return QDateTime::fromTime_t(expiration.toUInt());
	}

	void setExpiration(QDateTime expiration)
	{
		setHeader("expiration", QString::number(expiration.toTime_t()));
	}

	QString getMessageId() const
	{
		return getHeader("message-id");
	}

	void setMessageId(QString messageId)
	{
		setHeader("message-id", messageId);
	}

	void setPassword(QString password)
	{
		setHeader("passcode", password);
	}

	QByteArray getPayload() const
	{
		return payload;
	}

	QDomDocument getPayloadDocument() const
	{
		QDomDocument document;

		if (document.setContent(getPayload(), true))
			return document;
		else
			return QDomDocument();
	}

	void setPayload(QByteArray payload)
	{
		this->payload = payload;
		this->resetCachedFrame();
	}

	Priority getPriority() const
	{
		quint16 priority = getHeader("priority").toUInt();

		if (priority >= Highest)
			return Highest;
		else if (priority >= Expedited)
			return Expedited;
		else if (priority >= Normal)
			return Expedited;
		else if (priority >= Low)
			return Expedited;
		else
			return Lowest;
	}

	void setPriority(Priority priority)
	{
		setHeader("priority", QString::number(priority));
	}

	QString getReceipt() const
	{
		if (getCommandType() == Receipt)
			return getHeader("receipt-id");
		else
			return getHeader("receipt");
	}

	bool getReceiptRequired() const
	{
		return false == getReceipt().isEmpty();
	}

	void setReceiptRequired(bool receiptRequired)
	{
		setHeader("receipt", QUuid::createUuid().toString());
	}

	QString getSelector() const
	{
		return getHeader("selector");
	}

	void setSelector(QString selector)
	{
		setHeader("selector", selector);
	}

	QString getTransactionId() const
	{
		return getHeader("transaction");
	}

	void setTransactionId(QString transactionid)
	{
		setHeader("transaction", transactionid);
	}

	void setUser(QString user)
	{
		setHeader("login", user);
	}

protected:
	QByteArray getCachedFrame() const
	{
		return cachedFrame;
	}

	quint32 getCachedFrameSize() const
	{
		return cachedFrame.size();
	}

	void setCachedFrame(QByteArray cachedFrame)
	{
		this->cachedFrame = cachedFrame;
	}

	void resetCachedFrame()
	{
		this->cachedFrame = QByteArray();
	}

	QString getCommand() const
	{
		return command;
	}

	void setCommand(QString command)
	{
		this->command = command;
		this->resetCachedFrame();
	}

	QString getHeader(QString key) const
	{
		return getHeaders().value(key);
	}

	void setHeader(QString key, QString value)
	{
		getHeaders().insert(key, value);
		resetCachedFrame();
	}

	QHash<QString, QString> getHeaders() const
	{
		return headers;
	}

	void setHeaders(QHash<QString, QString> headers)
	{
		this->headers = headers;
		this->resetCachedFrame();
	}

private:
	AMQConnection *connection;
	QString command;
	QHash<QString, QString> headers;
	QByteArray payload;
	QByteArray cachedFrame;
};

#endif /* AMQCONNECTIONFRAME_H_ */