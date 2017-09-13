/*
 * StazioneStatusRequest.hpp
 *
 *  Created on: 07/apr/2017
 *      Author: Simone
 */

#ifndef STAZIONESTATUSREQUEST_HPP_
#define STAZIONESTATUSREQUEST_HPP_

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>

#include <src/ArtifactRequest.hpp>

class StazioneStatusRequest: public QObject
{
Q_OBJECT

public:
    StazioneStatusRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QObject *parent = NULL);

    void getStationData(QString &cod);

Q_SIGNALS:

    void finished();
    void badResponse(QString errorMessage);

private Q_SLOTS:

    void onStatusDataResponse(const QString &info, bool success, int i);

private:

    QNetworkAccessManager * m_qnam;
    bb::cascades::GroupDataModel* m_stationModel;
};

#endif /* STAZIONESTATUSREQUEST_HPP_ */
