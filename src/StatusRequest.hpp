/*
 * StatusRequest.hpp
 *
 *  Created on: 26/mar/2017
 *      Author: Simone
 */

#ifndef STATUSREQUEST_HPP_
#define STATUSREQUEST_HPP_

#include <src/ArtifactRequest.hpp>

#include <bb/system/SystemListDialog>
#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>
#include <bb/data/JsonDataAccess>


class StatusRequest : public QObject
{
    Q_OBJECT

public:
    StatusRequest(QNetworkAccessManager * qnam, QVariantMap * statusData, QObject * parent = NULL);

    void requestStatusData(const QString &num);

Q_SIGNALS:

    void finished();
    void badResponse(QString errorMessage);
    void abort();

private Q_SLOTS:

    void onNumeroTrenoComplete(const QString &info, bool success, int i);
    void onStatusDataComplete(const QString &info, bool success, int i);
    void onDialogFinished(bb::system::SystemUiResult::Type result);

private:

    void parseStatusData(const QString& response);
    //void salvaRicerca();
    //void caricaRicerche();

private:

    QNetworkAccessManager * m_qnam;
    QVariantMap * m_statusData;
    QStringList m_numStazList;
    QString m_num;

};

#endif /* STATUSREQUEST_HPP_ */

