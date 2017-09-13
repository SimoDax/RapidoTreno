/*
 * ItaloRequest.hpp
 *
 *  Created on: 10/mar/2017
 *      Author: Simone
 */

#ifndef ITALOREQUEST_HPP_
#define ITALOREQUEST_HPP_

#include <bb/cascades/GroupDataModel>

class ItaloRequest : public QObject
{
    Q_OBJECT

public:
    ItaloRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QList<QVariantList>* preloadedPtr, QObject *parent);

    void getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini);

Q_SIGNALS:

    //void badResponse();

    void finished();

private Q_SLOTS:

    void pageMoved();

    void onResponse(const QString &info, bool success, int i);

private:

    void parse(const QString &response);

private:

    bb::cascades::GroupDataModel* m_model;
    QList<QVariantList>* m_preloaded;
    QNetworkAccessManager * m_qnam;
    int m_openRequests;
};


#endif /* ITALOREQUEST_HPP_ */
