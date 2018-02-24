/*
 * ProfileRequest.hpp
 *
 *  Created on: 09/lug/2017
 *      Author: Simone
 */

//#include <src/app.hpp>

#ifndef PROFILEREQUEST_HPP_
#define PROFILEREQUEST_HPP_

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>
#include <bb/system/InvokeManager>
#include <bb/system/SystemProgressToast>
#include <bb/system/SystemUiProgressState>
#include <bb/system/SystemUiPosition>

using namespace bb::cascades;
using namespace bb::system;

class ProfileRequest : public QObject
{
    Q_OBJECT

public:
    ProfileRequest(QNetworkAccessManager* qnam, QVariantMap* profile, bb::cascades::GroupDataModel* tickets, QObject* parent=0);

    void getData();
    void login(QString user, QString pass);
    void openTicket(const QString &id, const QString &tsid);

    //QVariantMap profile();


Q_SIGNALS:

    void finished();
    void badResponse(QString errorMessage);
    //void downloadComplete();

private:

    void downloadTicket(const QString &id, const QString &tsid);
    void openAdobeReader(const QString &filename);

private Q_SLOTS:

    void onTicketsComplete(const QString &info, bool success, int i);
    void onProfileComplete(const QString &info, bool success, int i);
    void onLogin(const QString &info, bool success, int i);
    void badCredentials();


private:
    int m_openRequests;
    QVariantMap* m_profile;
    QNetworkAccessManager* m_qnam;
    bb::cascades::GroupDataModel* m_tickets;
};



#endif /* PROFILEREQUEST_HPP_ */
