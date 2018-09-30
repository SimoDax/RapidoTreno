/*
 * TrainRequest.cpp
 *
 *  Created on: 18/feb/2017
 *      Author: Simone
 */

#include "TrainRequest.hpp"
#include "ArtifactRequest.hpp"
#include "ItaloApiRequest.hpp"

#include <bb/data/JsonDataAccess>
#include <QDateTime>
#include <QVariant>
#include <QtCore/QObject>

using namespace bb::data;

TrainRequest::TrainRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QVector<QVariantList>* preloadedPtr, bool italo, QObject *parent = NULL) :
        QObject(parent), m_openRequests(0)
{
    m_model = modelPtr;
    m_qnam = qnamPtr;
    m_preloaded = preloadedPtr;
}

void TrainRequest::getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini, const QString &frecce, bool italo)
{

    QString url = "https://www.lefrecce.it/msite/api/solutions?origin=" + da + "&destination=" + a + "&arflag=A&adate=" + t.toString("dd/MM/yyyy") + "&atime=" + t.toString("h") + "&adultno=" + adulti + "&childno=" + bambini + "&direction=A&onlyRegional=false";
    if(frecce == "true")
        url += "&frecce=true";

    ArtifactRequest * request = new ArtifactRequest(m_qnam, this);
    m_openRequests++;

    bool ok = connect(request, SIGNAL(complete(QString, bool, int)), this, SLOT(onResponse(QString, bool, int)), Qt::UniqueConnection);

    request->requestArtifactline(url);

    if (italo) {
        QStringList nomestaz, sigle;
        nomestaz << "Bologna Centrale" << "Brescia" << "Ferrara" << "Firenze S. M. Novella" << "Milano Centrale" << "Rho-Fiera Milano" << "Milano Rogoredo" << "Napoli Centrale" << "Padova" << "Reggio Emilia AV" << "Roma Termini" << "Roma Tiburtina" << "Salerno" << "Torino Porta Nuova"
                << "Torino Porta Susa" << "Venezia Mestre" << "Venezia S. Lucia" << "Verona Porta Nuova" << "Milano ( tutte le stazioni )" << "Roma ( tutte le stazioni )";
        sigle << "BC_" << "BSC" << "F__" << "SMN" << "MC_" << "RRO" << "RG_" << "NAC" << "PD_" << "AAV" << "RMT" << "RTB" << "SAL" << "TOP" << "OUE" << "VEM" << "VSL" << "VPN" << "MI0" << "RM0";

        int indexDa = -1, indexA = -1;
        for (int i = 0; i < nomestaz.size(); i++) {
            if (da.compare(nomestaz[i], Qt::CaseInsensitive) == 0)
                indexDa = i;
            if (a.compare(nomestaz[i], Qt::CaseInsensitive) == 0)
                indexA = i;
        }

        if (indexDa == -1 || indexA == -1)
            return;

        ItaloApiRequest * italoRequest = new ItaloApiRequest(m_qnam, m_model, this);
        m_openRequests++;
        connect(italoRequest, SIGNAL(finished()), this, SLOT(startAsyncLoad()), Qt::UniqueConnection);

        italoRequest->getSolutions(sigle[indexDa], sigle[indexA], t, adulti, bambini);
    }

}

void TrainRequest::onResponse(const QString &info, bool success, int i)
{
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

     if (success) {
        parse(info);
        if(m_model->size())
            startAsyncLoad();
        else
            emit badResponse("Non esistono soluzioni per il viaggio cercato");
    } else {    //potrebbe esserci un errore http o la risposta è vuota

        if (info.isEmpty() || info.contains("500")) {   //no response or error 500

            emit badResponse("Richiesta non valida. Riprovare con altri dati");
            this->deleteLater();

        } else {
            emit badResponse("Errore di connessione: " + info);     //todo: se fs fallisce italo viene ignorato..
            this->deleteLater();
        }
    }

    request->deleteLater();
}

void TrainRequest::parse(const QString &response)
{
    //m_model->clear();

    if (response.trimmed().isEmpty())
        return;

    // Parse the json response with JsonDataAccess
    JsonDataAccess dataAccess;
    QVariantList soluzioni = dataAccess.loadFromBuffer(response).toList();

    //reverse list
    for (int k = 0, s = soluzioni.size(), max = (s / 2); k < max; k++)
        soluzioni.swap(k, s - (1 + k));

    // For each object in the array, push the variantmap
    // into the ListView
    QVariantMap dativeicolo;
    QDateTime t;
    QDateTime t_;
    foreach (QVariant artifact, soluzioni){
    QVariantMap soluzione = artifact.toMap();
    qDebug()<<"Trenitalia departureTime: "<<soluzione["departuretime"];
    t = QDateTime::fromMSecsSinceEpoch(soluzione["arrivaltime"].toLongLong());
    soluzione["orarioArrivo"] = t.toString("hh:mm");
    t_ = QDateTime::fromMSecsSinceEpoch(soluzione["departuretime"].toLongLong());
    soluzione["orarioPartenza"] = t_.toString("hh:mm");

    QVariantList veicoli = soluzione["trainlist"].toList();
    soluzione["sameday"] = 0;
    if(veicoli.size()==1) {
        dativeicolo = veicoli[0].toMap();
        soluzione["categoriaDescrizione"] = dativeicolo["trainacronym"];
        soluzione["numeroTreno"] = dativeicolo["trainidentifier"].toString().replace(QRegExp("\\s+"), " ");
        soluzione["traintype"] = dativeicolo["traintype"];

        //old viaggiatreno code.. i worked so much on it i don't want to delete it

        /*t = QDateTime::fromMSecsSinceEpoch(soluzione["arrivaltime"]);
         dativeicolo["orarioArrivo"] = t.toString("hh:mm");
         t_ = QDateTime::fromMSecsSinceEpoch(soluzione["departuretime"]);
         dativeicolo["orarioPartenza"] = t_.toString("hh:mm");
         dativeicolo["duration"] = soluzione["duration"];
         dativeicolo["size"] = 1;
         dativeicolo["data"] = t_.toString("yyyy-MM-dd");*/
        //dativeicolo["ora"] = dativeicolo["orarioPartenza"];
        /*if(t.toString("yyyy-MM-dd")!=t_.toString("yyyy-MM-dd"))
         dativeicolo["sameday"] = false;*/

    }
    else if (veicoli.size()>1) {
        QVariantMap temp;
        QString orarioArrivo, orarioPartenza, origine, destinazione, categoria, categoriaDescrizione, numeroTreno;
        temp = veicoli[0].toMap();
        //dativeicolo["orarioArrivo"].convert(QVariant::String);
        /*t = QDateTime::fromString(temp["orarioArrivo"].toString(), Qt::ISODate);
         orarioArrivo = t.toString("hh:mm");
         t = QDateTime::fromString(temp["orarioPartenza"].toString(), Qt::ISODate);
         orarioPartenza = t.toString("hh:mm");
         dativeicolo["data"] = t.toString("yyyy-MM-dd");
         dativeicolo["ora"] = orarioPartenza;
         origine = temp["origine"].toString();
         destinazione = temp["destinazione"].toString();*/
        categoria = temp["traintype"].toString();
        categoriaDescrizione = temp["trainacronym"].toString();
        numeroTreno = temp["trainidentifier"].toString().replace(QRegExp("\\s+"), " ");
        for (int i=1; i<veicoli.size(); i++) {
            temp = veicoli[i].toMap();
            //t = QDateTime::fromString(temp["orarioArrivo"].toString(), Qt::ISODate);
            //orarioArrivo += "," + t.toString("hh:mm");
            /*if(t.toString("yyyy-MM-dd")!=dativeicolo["data"])
             dativeicolo["sameday"] = false;*/
            //t = QDateTime::fromString(temp["orarioPartenza"].toString(), Qt::ISODate);
            //orarioPartenza += "," + t.toString("hh:mm");
            //origine += "," + temp["origine"].toString();
            //destinazione += "," + temp["destinazione"].toString();
            categoria += "," + temp["traintype"].toString();
            categoriaDescrizione += "," + temp["trainacronym"].toString();
            numeroTreno += "," + temp["trainidentifier"].toString().replace(QRegExp("\\s+"), " ");
            /*t = QDateTime::fromString(temp["orarioArrivo"].toString(), Qt::ISODate);
             dativeicolo["orarioArrivo" + QString::number(i)] = t.toString("hh:mm");
             t = QDateTime::fromString(temp["orarioPartenza"].toString(), Qt::ISODate);
             dativeicolo["orarioPartenza" + QString::number(i)] = t.toString("hh:mm");
             dativeicolo["origine" + QString::number(i)] = temp["origine"];
             dativeicolo["destinazione" + QString::number(i)] = temp["destinazione"];
             dativeicolo["categoria" + QString::number(i)] = temp["categoria"];
             dativeicolo["categoriaDescrizione" + QString::number(i)] = temp["categoriaDescrizione"];
             dativeicolo["numeroTreno" + QString::number(i)] = temp["numeroTreno"];*/
        }
        /*dativeicolo["durata"] = soluzione["durata"];
         dativeicolo["size"] = veicoli.size();
         dativeicolo["orarioArrivo"] = orarioArrivo;
         dativeicolo["orarioPartenza"] = orarioPartenza;
         dativeicolo["origine"] = origine;
         dativeicolo["destinazione"] = destinazione;*/
        soluzione["traintype"] = categoria;
        soluzione["categoriaDescrizione"] = categoriaDescrizione;
        soluzione["numeroTreno"] = numeroTreno;
    }
    //if(!dativeicolo["categoriaDescrizione"].toString().contains("Autobus"))
    m_model->insert(soluzione);
}
}

void TrainRequest::startAsyncLoad()
{
    m_openRequests--;               //called by either fs or italo response, one less to go
    if (m_openRequests)
        return;     //this function requires fs and italo solutions to be already inside m_model

    m_preloaded->clear();
    QList<QVariantMap> list;
    list += m_model->toListOfMaps();

    //disconnect(m_request, SIGNAL(complete(QString, bool)), this, 0);
    qDebug()<<"tl list size: "<<list.size();
    m_preloaded->resize(list.size());

    for (int i = 0; i < list.size(); i++) {
        QString id = list[i].value("idsolution", "italo").toString();
        if (id != "italo") {
            ArtifactRequest * request = new ArtifactRequest(m_qnam, this, i);
            connect(request, SIGNAL(complete(QString, bool, int)), this, SLOT(onSolutionDetailsComplete(QString, bool, int)), Qt::UniqueConnection);
            m_openRequests++;
            request->requestArtifactline("https://www.lefrecce.it/msite/api/solutions/" + id + "/info");
        }
        else {    //we already have all the details from the first request
            QVariantList italo;
            list[i]["departurestation"] = list[i]["origin"];
            list[i]["arrivalstation"] = list[i]["destination"];
            list[i]["order"] = i;
            italo << list[i];
            //italo[0].toMap()["departurestation"] = list[i]["origin"];
            //italo[0].toMap()["arrivalstation"] = list[i]["destination"];
            (*m_preloaded)[i] = italo;
            qDebug()<<"italo solution inserted at index "<<i;
        }
    }
}

void TrainRequest::onSolutionDetailsComplete(const QString &info, bool success, int i)
{
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    if (success) {
        JsonDataAccess dataAccess;
        QVariantList dati = dataAccess.loadFromBuffer(info).toList();
        qDebug() << "onSolutionDetailsComplete departureTime: "<< dati[0].toMap()["departuretime"];
        //int a = m_preloaded->size();
        //QVariantList indexPath = m_preloaded->size()+1;
        //if(m_model->data(indexPath)["traintype"]!="italo")
        (*m_preloaded)[i] = dati;

        //emit statusDataLoaded();
    } else {
        //TODO: warn the user no solution details are available
        //m_errorMessage = info;
        //m_error = true;
        //emit statusChanged();
        //emit badResponse();
    }

    request->deleteLater();

    //m_active = false;
    m_openRequests--;
    if (m_openRequests == 0) {
        //qSort(m_preloaded->begin(), m_preloaded->end(), orderByTime); //not needed anymore with index-based insertion
        emit finished();
        this->deleteLater();    //i don't wanna live in this world anymore :(
    }
    //emit openChanged();

}

/*
bool orderByTime(QVariantList l1, QVariantList l2)
{
    if (l1[0].toMap().value("idsolution", "italo") == "italo" || l2[0].toMap().value("idsolution", "italo") == "italo")
        return l1[0].toMap()["departuretime"].toString() < l2[0].toMap()["departuretime"].toString();

    return l1[0].toMap()["idsolution"].toString() < l2[0].toMap()["idsolution"].toString();
}
*/
