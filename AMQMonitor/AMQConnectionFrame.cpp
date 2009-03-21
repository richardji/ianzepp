/*
 * AMQConnectionFrame.cpp
 *
 *  Created on: Mar 20, 2009
 *      Author: Ian Zepp
 */

#include "AMQConnectionFrame.h"
#include "AMQConnection.h"

AMQConnectionFrame::AMQConnectionFrame(AMQConnection *connection)
{
	this->connection = connection;
}

AMQConnectionFrame::AMQConnectionFrame(AMQConnection *connection, QByteArray data)
{
	this->connection = connection;
}

AMQConnectionFrame::~AMQConnectionFrame()
{
}

QByteArray AMQConnectionFrame::toFrame()
{
	if (getCachedFrameSize() > 0)
		return getCachedFrame();

	QByteArray data;

	// Append command
	data.append(getCommand());
	data.append('\n');

	// Append headers
	QHashIterator<QString, QString> iterator(getHeaders());

	while (iterator.hasNext())
	{
		data.append(iterator.key());
		data.append(':');
		data.append(' ');
		data.append(iterator.value());
		data.append('\n');
	}

	// Append content length header
	data.append(QString("content-length"));
	data.append(':');
	data.append(' ');
	data.append(QString::number(getPayload().size()));
	data.append('\n');

	// Linebreak between headers and payload
	data.append('\n');

	// Append payload
	data.append(getPayload());
	data.append('\0');
	data.append('\n');

	// Save to cached frame
	setCachedFrame(data);

	// Done.
	return data;
}

void AMQConnectionFrame::acknowledge()
{
	if (getCommandType() != Message)
		return; // must be a message type to acknowledge
	if (getMessageId().isEmpty())
		return; // must have a message id

	AMQConnectionFrame frame(getConnection());
	frame.setCommandType(AMQConnectionFrame::Acknowledge);
	frame.setMessageId(getMessageId());
	frame.setTransactionId(getTransactionId());
	frame.send();
}

void AMQConnectionFrame::send()
{
	getConnection()->sendFrameData(toFrame());
}

