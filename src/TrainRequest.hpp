/*
 * TrainRequest.hpp
 *
 *  Created on: 18/feb/2017
 *      Author: Simone
 */

#ifndef TRAINREQUEST_HPP_
#define TRAINREQUEST_HPP_

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>

class TrainRequest: public QObject
{
    Q_OBJECT

public:
    TrainRequest(QNetworkAccessManager* qnamPtr, bb::cascades::GroupDataModel* modelPtr, QVector<QVariantList>* preloadedPtr, bool italo, QObject *parent);

    void getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini, const QString &frecce, bool italo);

    Q_SIGNALS:

    void finished();
    void removeWait();
    void badResponse(QString errorString);

private Q_SLOTS:

    void onResponse(const QString &info, bool success, int i);
    void onSolutionDetailsComplete(const QString &info, bool success, int i);
    void startAsyncLoad();

private:

    void parse(const QString &response);
    void decreaseOpenRequests();
    //bool lessThan(QVariantList l1, QVariantList l2);

private:

    bb::cascades::GroupDataModel* m_model;
    QVector<QVariantList>* m_preloaded;
    QNetworkAccessManager * m_qnam;
    int m_openRequests;
};

bool orderByTime(QVariantList l1, QVariantList l2);

#endif /* TRAINREQUEST_HPP_ */
