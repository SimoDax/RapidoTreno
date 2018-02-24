/*
 * TicketRequest.hpp
 *
 *  Created on: 20/feb/2018
 *      Author: Simone
 */

#ifndef TICKETREQUEST_HPP_
#define TICKETREQUEST_HPP_

#include <QtCore/QObject>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTargetReply>
#include <bb/system/SystemProgressToast>
#include <bb/system/SystemUiProgressState>
#include <bb/system/SystemUiPosition>

//using namespace bb::cascades;
using namespace bb::system;

class TicketRequest : public QObject
{
    Q_OBJECT


public:
    TicketRequest(QNetworkAccessManager* qnam, QObject* parent=0);

    void openTicket(const QString &id, const QString &tsid);

Q_SIGNALS:

    void badResponse(QString errorMessage);

private:

    void downloadTicket();
    void openAdobeReader(const QString &filename);

private Q_SLOTS:

    void onDownloadComplete(QByteArray &data, QString filename, bool success);
    void onDownloadProgress(qint64 received, qint64 total);
    void onSaleComplete(const QString &info, bool success, int i);
    void onInvokeResult();

private:
    QNetworkAccessManager* m_qnam;
    SystemProgressToast* m_progresstoast;
    InvokeTargetReply* m_reply;
    QString m_id, m_tsid;
};

#endif /* TICKETREQUEST_HPP_ */
