/*
 * StazioneStatusRequest.cpp
 *
 *  Created on: 07/apr/2017
 *      Author: Simone
 */

#include <src/StazioneStatusRequest.hpp>
#include <src/ArtifactRequest.hpp>

#include <bb/data/JsonDataAccess>

using namespace bb::data;
using namespace bb::cascades;

StazioneStatusRequest::StazioneStatusRequest(QNetworkAccessManager * qnamPtr, GroupDataModel* modelPtr, QObject *parent) : QObject(parent)
{
    m_qnam = qnamPtr;
    m_stationModel = modelPtr;

}

void StazioneStatusRequest::getStationData(QString &cod){

    ArtifactRequest * request = new ArtifactRequest(m_qnam, this);

    request->connect(request, SIGNAL(complete(QString, bool, int)), this, SLOT(onStatusDataResponse(QString, bool, int)));

    QDateTime t = QDateTime::currentDateTime();
    QDate date = QDate::currentDate();
    QStringList engMonths, engDays;
    engMonths << "Jan" << "Feb" << "Mar" << "Apr" << "May" << "Jun" << "Jul" << "Aug" << "Sep" << "Oct" << "Nov" << "Dec";
    engDays << "Mon" << "Tue" << "Wed" << "Thu" << "Fri" << "Sat" << "Sun";

    QString time = t.toString("dd yyyy hh:mm:ss");

    time.prepend(engMonths[date.month()-1] + " ");
    time.prepend(engDays[date.dayOfWeek()-1] + " ");

    request->requestArtifactline("http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/partenze/"+ cod +"/"+ time);

}

void StazioneStatusRequest::onStatusDataResponse(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if(!m_stationModel->isEmpty())
        m_stationModel->clear();

    if(success){
        if(!info.isEmpty()){

            JsonDataAccess dataAccess;
            QVariantList treni = dataAccess.loadFromBuffer(info).toList();  //God bless blackberry for making this class

            foreach (QVariant treno, treni) {
                QVariantMap temp;
                QDateTime t;

                /*t = QDateTime::fromMSecsSinceEpoch(treno.toMap()["orarioPartenza"].toInt());
        temp["orarioPartenza"] = t.toString("hh:mm");*/

                temp["orarioPartenza"] = treno.toMap()["compOrarioPartenza"];
                temp["status"] = treno.toMap()["compRitardo"].toList()[0].toString();
                temp["ritardo"] = treno.toMap()["ritardo"];
                temp["image"] = treno.toMap()["compImgRitardo"];

                temp["destinazione"] = treno.toMap()["destinazione"];
                temp["destinazioneEstera"] = treno.toMap()["destinazioneEstera"];
                temp["compNumeroTreno"] = treno.toMap()["compNumeroTreno"];
                temp["numeroTreno"] = treno.toMap()["numeroTreno"];
                temp["categoria"] = treno.toMap()["categoria"];

                temp["binarioProg"] = treno.toMap()["binarioProgrammatoPartenzaDescrizione"].toString().trimmed();
                temp["binarioEff"] = treno.toMap()["binarioEffettivoPartenzaDescrizione"].toString().trimmed();

                temp["orientamento"] = treno.toMap()["compOrientamento"];

                m_stationModel->insert(temp);
            }

            emit finished();

        }else emit badResponse("Dati di questa stazione momentaneamente non disponibili");

    } else emit badResponse("Errore di rete: "+ info);

    request->deleteLater();
    this->deleteLater();    //just preparing to hang myself
}
