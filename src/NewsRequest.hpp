/*
 * NewsRequest.hpp
 *
 *  Created on: 30/apr/2017
 *      Author: Simone
 */

#ifndef NEWSREQUEST_HPP_
#define NEWSREQUEST_HPP_

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>

class NewsRequest : public QObject
{
    Q_OBJECT

public:
    NewsRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* newsPtr, QObject *parent);

    void getNews();

 Q_SIGNALS:

    void finished();
    void badResponse(QString errorMessage);

private Q_SLOTS:

    void onFSNewsComplete(const QString &info, bool success, int i);

private:

    QNetworkAccessManager * m_qnam;
    bb::cascades::GroupDataModel* m_news;

};

#endif /* NEWSREQUEST_HPP_ */
