/*
 * ItaloApiRequest.hpp
 *
 *  Created on: 23/giu/2018
 *      Author: Simone
 */

#ifndef ITALOAPIREQUEST_HPP_
#define ITALOAPIREQUEST_HPP_

#include <QtCore/Qobject>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>

using namespace bb::data;

class ItaloApiRequest : public QObject
{
    Q_OBJECT

    public:
        ItaloApiRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QObject* parent);

        void getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini);

        static QVariantMap detailedOffers;

    Q_SIGNALS:

        void badResponse(QString errorMessage);

        void finished();

    private Q_SLOTS:

        void onResponse(const QString &info, bool success, int i);

    private:

        void parse(const QString &response);

    private:

        bb::cascades::GroupDataModel* m_model;
        QNetworkAccessManager * m_qnam;
        JsonDataAccess dataAccess;
};

#endif /* ITALOAPIREQUEST_HPP_ */
