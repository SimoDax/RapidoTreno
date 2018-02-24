/*
 * ProfileRequest.cpp
 *
 *  Created on: 09/lug/2017
 *      Author: Simone
 */

#include <src/ArtifactRequest.hpp>
#include <src/ProfileRequest.hpp>
#include <bb/data/JsonDataAccess>
#include <QtCore/QObject>
#include <QFile>
#include <QMap>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTargetReply>
#include <QDir>

using namespace bb::data;
using namespace bb::system;

ProfileRequest::ProfileRequest(QNetworkAccessManager* qnam, QVariantMap* profile, bb::cascades::GroupDataModel* tickets, QObject* parent) : QObject(parent)
{
    m_qnam = qnam;
    m_profile = profile;
    m_tickets = tickets;
    m_openRequests = 0;
}

void ProfileRequest::login(QString user, QString pass){     //entry point for login button
    ArtifactRequest* login = new ArtifactRequest(m_qnam, this);

    connect(login, SIGNAL(complete(QString, bool, int)), this, SLOT(onLogin(QString, bool, int)));
    connect(login, SIGNAL(moved()), this, SLOT(badCredentials()));

    QByteArray postData;
    postData.append("j_username=" + user + "&j_password=" + pass);

    login->post("https://www.lefrecce.it/msite/api/users/login", postData);

}

void ProfileRequest::badCredentials(){
    emit badResponse("Credenziali di login errate.");
    this->deleteLater();
}

void ProfileRequest::getData(){     //entry point when already logged

    ArtifactRequest* profileRequest = new ArtifactRequest(m_qnam, this);
    connect(profileRequest, SIGNAL(complete(QString, bool, int)), this, SLOT(onProfileComplete(QString, bool, int)));
    m_openRequests++;

    profileRequest->requestArtifactline("https://www.lefrecce.it/msite/api/users/profile");

    ArtifactRequest* lastTickets = new ArtifactRequest(m_qnam, this);
    connect(lastTickets, SIGNAL(complete(QString, bool, int)), this, SLOT(onTicketsComplete(QString, bool, int)));
    m_openRequests++;

    QDate dateTo = QDate::currentDate();
    QDate dateFrom = QDate(dateTo);
    dateFrom = dateFrom.addMonths(-3);

    lastTickets->requestArtifactline("https://www.lefrecce.it/msite/api/users/purchases?finalized=true&datefrom=" + dateFrom.toString("dd/MM/yyyy") + "&dateto=" + dateTo.toString("dd/MM/yyyy"));

}

void ProfileRequest::onLogin(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(success)
        getData();
    else{
        emit badResponse("Credenziali di login errate");
        this->deleteLater();
    }

    request->deleteLater();
}

void ProfileRequest::onProfileComplete(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());
    if(success){
        if(!info.isEmpty() && !info.isNull()){
            m_profile->clear();
            JsonDataAccess dataAccess;
            m_profile->unite(dataAccess.loadFromBuffer(info).toMap());
            m_profile->insert("logged", true);
        }else emit badResponse("Impossibile recuperare i dati di questo utente.");

    }else emit badResponse(info);

    request->deleteLater();

    m_openRequests--;
    if(!m_openRequests){
        emit finished();
        this->deleteLater();
    }
}

void ProfileRequest::onTicketsComplete(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());
    if(success){
        if(!info.isEmpty() && !info.isNull()){
            m_tickets->clear();
            JsonDataAccess dataAccess;
            QVariantList list = dataAccess.loadFromBuffer(info).toList();
            m_tickets->insertList(list);
        }else emit badResponse("Impossibile recuperare gli ultimi viaggi questo utente.");

    }else emit badResponse(info);

    request->deleteLater();

    m_openRequests--;
    if(!m_openRequests){
        emit finished();
        this->deleteLater();
    }
}
