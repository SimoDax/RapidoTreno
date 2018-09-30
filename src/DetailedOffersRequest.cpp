/*
 * DetailedOffersRequest.cpp
 *
 *  Created on: 10/ott/2017
 *      Author: Simone
 */

#include "DetailedOffersRequest.hpp"
#include <src/ArtifactRequest.hpp>
#include <bb/data/JsonDataAccess>
#include <src/ItaloApiRequest.hpp>

using namespace bb::data;

DetailedOffersRequest::DetailedOffersRequest(QNetworkAccessManager* qnam, QVariantList* trainsDetails)
{
    // TODO Auto-generated constructor stub
    m_qnam = qnam;
    m_trainsDetails = trainsDetails;
}


void DetailedOffersRequest::getDetails(const QString& id, bool custom){

    m_trainsDetails->clear();

    if(id.toInt() > 8900 && id.toInt() < 10000){
        if(ItaloApiRequest::detailedOffers.contains(id)){
            m_trainsDetails->append(ItaloApiRequest::detailedOffers.value(id));
            emit finished();
        }
        else
            emit badResponse("Impossibile recuperare i dettagli delle offerte");
        this->deleteLater();
    }
    else
    {
        ArtifactRequest* request = new ArtifactRequest(m_qnam, this);
        bool ok = connect(request, SIGNAL(complete(QString, bool, int)), this, SLOT(onResponse(QString, bool, int)), Qt::UniqueConnection);
        if(ok)
            request->requestArtifactline("https://www.lefrecce.it/msite/api/solutions/" + id +"/standardoffers");
        else
            request->deleteLater();
    }
}

void DetailedOffersRequest::onResponse(const QString& info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(success){
        if(!info.isEmpty() && !info.isNull()){
            JsonDataAccess dataAccess;
            QVariantMap details = dataAccess.loadFromBuffer(info).toMap();
            foreach(QVariant leg, details["leglist"].toList()){
                m_trainsDetails->append(leg.toMap());      //TODO: append just the services data, not all the details
                //qDebug()<<leg.toMap();
            }
            emit finished();
        }
        else emit badResponse("Impossibile recuperare i dettagli delle offerte");
    }
    else emit badResponse(info);

    request->deleteLater();
    this->deleteLater();
}
