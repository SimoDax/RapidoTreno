/*
 * ItaloStatusRequest.hpp
 *
 *  Created on: 28/mar/2017
 *      Author: Simone
 */

#ifndef ITALOstatusREQUEST_HPP_
#define ITALOstatusREQUEST_HPP_

#include <src/ArtifactRequest.hpp>

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>

class ItaloStatusRequest : public QObject
{
    Q_OBJECT

public:
    ItaloStatusRequest(QNetworkAccessManager * qnam, QVariantMap * statusData, QObject * parent = NULL);

    void requestStatusData(const QString &num);

Q_SIGNALS:

    void finished();
    void badResponse(QString errorMessage);

private Q_SLOTS:

    void onStatusDataComplete(const QString &info, bool success, int i);

private:

    void parseStatusData(QString& response);

private:

    QNetworkAccessManager * m_qnam;
    QVariantMap * m_statusData;
    QString m_num;

};

#endif /* ITALOstatusREQUEST_HPP_ */
