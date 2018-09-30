/*
 * ItaloApiRequest.cpp
 *
 *  Created on: 23/giu/2018
 *      Author: Simone
 */

#include <src/ItaloApiRequest.hpp>
#include <src/ArtifactRequest.hpp>
#include <src/App.hpp>
#include <QtCore/Qobject>
#include <bb/data/JsonDataAccess>

using namespace bb::data;

#define SEARCH_WINDOW 3

QVariantMap ItaloApiRequest::detailedOffers;


ItaloApiRequest::ItaloApiRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QObject* parent=NULL) : QObject(parent)
{
    m_qnam = qnamPtr;
    m_model = modelPtr;

}

void ItaloApiRequest::getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini){

    QDateTime dt = t;
    QTime time = t.time();
    time.setHMS(time.hour(),0,0,0);
    dt.setTime(time);

    detailedOffers.clear();

    ArtifactRequest* italoRequest = new ArtifactRequest(m_qnam, this);

    QMap<QString, QVariant> parameters;
    QByteArray postData;
    QVariantMap innerParameters, loginParameters;

    loginParameters["Domain"] = "WWW";
    loginParameters["Username"] = "WWW_Anonymous";
    loginParameters["Password"] = "Accenture$1";

    parameters["Login"] = loginParameters;

    innerParameters["AdultNumber"] = adulti.toInt();
    innerParameters["ArrivalStation"] = a;
    innerParameters["AvailabilityFilter"] = 0;
    innerParameters["ChildNumber"] = bambini.toInt();
    innerParameters["CurrencyCode"] = "EUR";
    innerParameters["DepartureStation"] = da;
    innerParameters["FareClassControl"] = 0;
    innerParameters["InfantNumber"] = 0;
    innerParameters["IntervalStartDateTime"] = "/Date(" + QString::number(t.toMSecsSinceEpoch()) + "+0000)/";
    innerParameters["IsGuest"] = true;
    innerParameters["OverrideIntervalTimeRestriction"] = true;
    innerParameters["RoundTrip"] = false;
    innerParameters["SeniorNumber"] = 0;
    innerParameters["SourceSystem"] = 2;

    innerParameters["IntervalEndDateTime"] = "/Date(" + QString::number(t.toMSecsSinceEpoch()+3600000*SEARCH_WINDOW) + "+0000)/";
    parameters["GetAvailableTrains"] = innerParameters;

   dataAccess.saveToBuffer(QVariant(parameters), &postData);

   //qDebug()<<parameters;


#ifdef QT_DEBUG     //only in debug builds

    QFile file("./data/postData.txt");
        if(!file.open(QIODevice::WriteOnly))
            return;
        QTextStream stream(&file); // Open stream
        stream << postData;
        file.close();

#endif

   connect(italoRequest, SIGNAL(complete(QString, bool, int)), this, SLOT(onResponse(QString, bool, int)));
   italoRequest->postJson("https://big.ntvspa.it/BIG/v6/rest/BookingManager.svc/GetAvailableTrains", postData);

}

void ItaloApiRequest::onResponse(const QString &info, bool success, int i){
    ArtifactRequest* request = qobject_cast<ArtifactRequest*>(sender());

    if(success){
        parse(info);
        emit finished();
    }
    else
        emit badResponse(info);

    request->deleteLater();
    this->deleteLater();
}

void ItaloApiRequest::parse(const QString &response_){
    //TODO: support multi-segment solutions

    QVariantMap response = dataAccess.loadFromBuffer(response_).toMap();
    QVariantList solutions = response["JourneyDateMarkets"].toList()[0].toMap()["Journeys"].toList();


    qDebug()<<"italo solutions found: "<<solutions.size();
    foreach(QVariant element, solutions){
        QVariantMap solution = element.toMap()["Segments"].toList()[0].toMap();
        QVariantMap soluzione;
        QRegExp reg;

        reg.setPattern("\\d+");
        reg.indexIn(solution["STD"].toString());
        QDateTime part = QDateTime::fromMSecsSinceEpoch(reg.capturedTexts()[0].toLongLong());
        soluzione["orarioPartenza"] = part.toString("hh:mm");
        soluzione["departuretime"] = (qulonglong)part.toMSecsSinceEpoch();

        reg.indexIn(solution["STA"].toString());
        QDateTime arr = QDateTime::fromMSecsSinceEpoch(reg.capturedTexts()[0].toLongLong());
        soluzione["orarioArrivo"] = arr.toString("hh:mm");
        soluzione["arrivaltime"] = reg.capturedTexts()[0].toLongLong();

        soluzione["numeroTreno"] = solution["TrainNumber"];

        int duration_hours = part.secsTo(arr)/3600;
        int duration_minutes = (part.secsTo(arr)-3600*duration_hours)/60;

        if(duration_minutes < 10)
            soluzione["duration"] = QString::number(duration_hours) + ":0" + QString::number(duration_minutes);
        else
            soluzione["duration"] = QString::number(duration_hours) + ":" + QString::number(duration_minutes);

        if(solution["Fares"].toList().size()){
            float minprice = solution["Fares"].toList()[0].toMap()["DiscountedFarePrice"].toFloat();
            for(int i = 1; i<solution["Fares"].toList().size(); i++){
                if(solution["Fares"].toList()[i].toMap()["DiscountedFarePrice"].toFloat() < minprice)
                    minprice = solution["Fares"].toList()[i].toMap()["DiscountedFarePrice"].toFloat();
            }
            soluzione["minprice"] = minprice;
            soluzione["saleable"] = true;
        }
        else
            soluzione["saleable"] = false;

        //STAZIONI PARTENZA E ARRIVO

        QString departureCode = solution["Legs"].toList()[0].toMap()["DepartureStation"].toString();
        QString arrivalCode = solution["Legs"].toList()[solution["Legs"].toList().size()-1].toMap()["ArrivalStation"].toString();

        QStringList nomestaz, sigle;
        nomestaz << "Bologna Centrale" << "Brescia" << "Ferrara" << "Firenze S. M. Novella" << "Milano Centrale" << "Rho-Fiera Milano" << "Milano Rogoredo" << "Napoli Centrale" << "Padova" << "Reggio Emilia AV" << "Roma Termini" << "Roma Tiburtina" << "Salerno" << "Torino Porta Nuova"
                << "Torino Porta Susa" << "Venezia Mestre" << "Venezia S. Lucia" << "Verona Porta Nuova" << "Milano ( tutte le stazioni )" << "Roma ( tutte le stazioni )";
        sigle << "BC_" << "BSC" << "F__" << "SMN" << "MC_" << "RRO" << "RG_" << "NAC" << "PD_" << "AAV" << "RMT" << "RTB" << "SAL" << "TOP" << "OUE" << "VEM" << "VSL" << "VPN" << "MI0" << "RM0";

        int indexDa = -1, indexA = -1;
        indexDa = sigle.indexOf(departureCode);
        indexA = sigle.indexOf(arrivalCode);
        if(indexDa != -1)
            soluzione["origin"] = nomestaz[indexDa];
        else
            soluzione["origin"] = "";
        if(indexA != -1)
            soluzione["destination"] = nomestaz[indexA];
        else
            soluzione["destination"] = "";

        //ALTRI CAMPI

        soluzione["changesno"] = element.toMap()["Segments"].toList().size()-1;
        soluzione["traintype"] = "italo";
        soluzione["trainacronym"] = "Italo";    //
        soluzione["categoriaDescrizione"] = 0;
        soluzione["trainidentifier"] = soluzione["numeroTreno"];    //

        //DETAILED OFFERS

        QVariantList serviceList, smartOfferList, comfortOfferList, primaOfferList, clubOfferList;
        QVariantMap smartOfferMap, comfortOfferMap, primaOfferMap, clubOfferMap;

        foreach(QVariant fare, solution["Fares"].toList()){
            QVariantMap offer;

            offer["saleable"] = true;
            offer["price"] = fare.toMap()["DiscountedFarePrice"];
            offer["description"] = fare.toMap()["Description"];
            offer["available"] = -1;

            if(fare.toMap()["ProductClass"].toString() == "S"){
                offer["name"] = fare.toMap()["ClassOfServiceName"];
                smartOfferList.append(offer);
            }
            else if (fare.toMap()["ProductClass"].toString() == "T"){
                offer["name"] = fare.toMap()["ClassOfServiceName"];
                comfortOfferList.append(offer);
            }
            else if(fare.toMap()["ProductClass"].toString() == "P"){
                offer["name"] = fare.toMap()["ClassOfServiceName"];
                primaOfferList.append(offer);
            }
            else if(fare.toMap()["ProductClass"].toString() == "C"){
                offer["name"] = fare.toMap()["ClassOfServiceName"];
                clubOfferList.append(offer);
            }

        }

        smartOfferMap["name"] = "SMART";
        comfortOfferMap["name"] = "COMFORT";
        primaOfferMap["name"] = "PRIMA";
        clubOfferMap["name"] = "CLUB";
        smartOfferMap["offerlist"] = smartOfferList;
        comfortOfferMap["offerlist"] = comfortOfferList;
        primaOfferMap["offerlist"] = primaOfferList;
        clubOfferMap["offerlist"] = clubOfferList;

        serviceList << smartOfferMap << comfortOfferMap << primaOfferMap << clubOfferMap;

        QVariantMap treno;
        treno["servicelist"] = serviceList;

        detailedOffers.insert(soluzione["numeroTreno"].toString(), treno);

        m_model->insert(soluzione);
    }
}
