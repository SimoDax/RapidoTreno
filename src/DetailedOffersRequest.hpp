/*
 * DetailedOffersRequest.hpp
 *
 *  Created on: 10/ott/2017
 *      Author: Simone
 */

#ifndef DETAILEDOFFERSREQUEST_HPP_
#define DETAILEDOFFERSREQUEST_HPP_

#include <QtCore/QObject>

class DetailedOffersRequest: public QObject
{
    Q_OBJECT

public:
    DetailedOffersRequest(QNetworkAccessManager* qnam, QVariantList* offers);

    void getDetails(const QString& id, bool custom = false);

    Q_SIGNALS:

    void badResponse(QString errorString);
    void finished();

private Q_SLOTS:

    void onResponse(const QString& info, bool success, int i);

private:

    QNetworkAccessManager* m_qnam;
    QVariantList* m_trainsDetails;

};

#endif /* DETAILEDOFFERSREQUEST_HPP_ */
