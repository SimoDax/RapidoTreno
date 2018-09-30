/*
 * ItaloRequest.cpp
 *
 *  Created on: 10/mar/2017
 *      Author: Simone
 */

#include "ItaloRequest.hpp"
#include "ArtifactRequest.hpp"

#include <QtCore/QObject>

#define SEARCH_WINDOW 3

ItaloRequest::ItaloRequest(QNetworkAccessManager * qnamPtr, bb::cascades::GroupDataModel* modelPtr, QList<QVariantList>* preloadedPtr, QObject *parent=NULL) : QObject(parent)
, m_openRequests(0)
{
    m_model = modelPtr;
    m_qnam = qnamPtr;
    m_preloaded = preloadedPtr;
}

void ItaloRequest::getSolutions(const QString &da, const QString &a, const QDateTime &t, const QString &adulti, const QString &bambini)
{

    QDateTime t2 = QDateTime(t);
    t2 = t2.addSecs(SEARCH_WINDOW*3600);


    QByteArray postData;

    postData.append("BookingRicercaRestylingBookingAcquistoRicercaView%24RadioButtonMarketStructure=OneWay&BookingRicercaRestylingBookingAcquistoRicercaView%24TextBoxMarketOrigin1="+da+"&BookingRicercaRestylingBookingAcquistoRicercaView%24TextBoxMarketDestination1="+a+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListMarketDay1="+t.toString("dd")+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListMarketMonth1="+t.toString("MM-yyyy")+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownDepartureTimeHoursBegin_1="+t.toString("hh")+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownDepartureTimeHoursEnd_1="+t2.toString("hh")+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListPassengerType_ADT="+adulti+"&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListPassengerType_SNR=0&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListPassengerType_CHD="+bambini+"&BookingRicercaRestylingBookingAcquistoRicercaView%24InfantTextBox=0&promocode=&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListSearchBy=columnView&BookingRicercaRestylingBookingAcquistoRicercaView%24DropDownListFareTypes=ST&__EVENTTARGET=BookingRicercaRestylingBookingAcquistoRicercaView%24ButtonSubmit&__EVENTARGUMENT=");

#ifdef QT_DEBUG     //only in debug builds

    QFile file("./data/postData.txt");
        if(!file.open(QIODevice::WriteOnly))
            return;
        QTextStream stream(&file); // Open stream
        stream << postData;
        file.close();

#endif

    ArtifactRequest * request = new ArtifactRequest(m_qnam, this);
    m_openRequests++;

    bool ok = connect(request, SIGNAL(moved()), this, SLOT(pageMoved()), Qt::UniqueConnection);
    connect(request, SIGNAL(complete(QString, bool, int)), this, SLOT(onResponse(QString, bool, int)), Qt::UniqueConnection);
    Q_ASSERT(ok);
    Q_UNUSED(ok);

    request->post("https://biglietti.italotreno.it/Booking_Acquisto_Ricerca.aspx", postData);
    //emit activeChanged();
}

void ItaloRequest::pageMoved(){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

    request->requestArtifactline("https://biglietti.italotreno.it/Booking_Acquisto_SelezioneTreno_A.aspx");

}

void ItaloRequest::onResponse(const QString &info, bool success, int i){
    ArtifactRequest *request = qobject_cast<ArtifactRequest*>(sender());

        if (success) {
            parse(info);
            //m_errorMessage = info;


        } else {
            //todo hella complex code going on here
        }

        //m_active = false;
        //emit activeChanged();
        emit finished();

        request->deleteLater();
        this->deleteLater();    //what's the point in living anymore?
}

void ItaloRequest::parse(const QString &response){
    //qDebug()<<response;
    //m_model->clear();
#ifdef QT_DEBUG
    QFile file("./data/italo.txt");
    if(!file.open(QIODevice::WriteOnly))
        return;
    QTextStream stream(&file); // Open stream
    stream << response;
    file.close();
#endif

    qDebug()<<response.indexOf("<div class=\"item-treno js-item-treno\">");

    QStringList lista = response.split("<div class=\"item-treno js-item-treno\">");
    if(!lista.isEmpty()){
        lista.pop_front();
        //qDebug()<<lista;

        int index = 0;
        QRegExp reg;
        QString temp;
        QVariantMap soluzione;
        QDate date;

        reg.setPattern("<li data-search-date=\"\\d+/\\d+/\\d+\"\\s+class=\"selected\"");
        reg.indexIn(response);
        qDebug()<<reg.capturedTexts();

        index = response.indexOf(QRegExp("<li data-search-date=\"\\d+/\\d+/\\d+\"\\s+class=\"selected\"")) + 22;
        qDebug()<<"index:"<< index;
        date = QDate::fromString(response.mid(index, response.indexOf("\"", index)-index), "d/M/yyyy");
        qDebug()<<response.mid(index, response.indexOf("\"", index)-index);

        for(int i=0; i<lista.length(); i++){

            QTime time, time2;

            index = lista[i].indexOf("<p>")+3;
            temp = lista[i].mid(index, lista[i].indexOf("</p>")-index);
            reg.setPattern("\\d+:\\d+");
            reg.indexIn(temp);
            soluzione["orarioPartenza"] = reg.capturedTexts()[0];
            time = QTime::fromString(soluzione["orarioPartenza"].toString(), "hh:mm");
            reg.indexIn(temp, soluzione["orarioPartenza"].toString().length());
            soluzione["orarioArrivo"] = reg.capturedTexts()[0];
            time2 = QTime::fromString(soluzione["orarioArrivo"].toString(), "hh:mm");

            index=lista[i].indexOf("<p class=\"stazione\">", index) + 20;
            soluzione["origin"] = lista[i].mid(index, lista[i].indexOf("</p>",index)-index);
            index=lista[i].indexOf("<p class=\"stazione\">", index) + 20;
            soluzione["destination"] = lista[i].mid(index, lista[i].indexOf("</p>",index)-index);

            index=lista[i].indexOf("<h5>N", index) + 5;
            temp = lista[i].mid(index, lista[i].indexOf("</h5>",index)-index);
            reg.setPattern("\\d+");
            reg.indexIn(temp);
            soluzione["numeroTreno"] = reg.capturedTexts()[0];

            index=lista[i].indexOf("<p class=\"durata\">", index) + 18;
            reg.setPattern("\\d+:\\d+");
            reg.indexIn(lista[i].mid(index, lista[i].indexOf("</p>",index)-index));
            soluzione["duration"] = reg.capturedTexts()[0];

            index=lista[i].indexOf("<span>", index) + 6;
            temp = lista[i].mid(index, lista[i].indexOf("</span>",index)-index);
            reg.setPattern("\\d+,?\\d*");   //parte decimale non assicurata
            reg.indexIn(temp);
            soluzione["minprice"] = reg.capturedTexts()[0].toFloat();

            soluzione["saleable"] = true;
            soluzione["changesno"] = 0;
            soluzione["traintype"] = "italo";
            soluzione["trainacronym"] = "Italo";    //
            soluzione["categoriaDescrizione"] = 0;
            soluzione["trainidentifier"] = soluzione["numeroTreno"];    //

            QDateTime datetime;
            datetime.setTime(time);
            datetime.setDate(date);
          qDebug()<<datetime.toString(Qt::ISODate);
          //qDebug()<<"Italo qint64 departureTime: "<<(qint64)datetime.toMSecsSinceEpoch()<<" quint64: "<<(quint64)datetime.toMSecsSinceEpoch();
            soluzione["departuretime"] = (qulonglong)datetime.toMSecsSinceEpoch();
          //qDebug()<< soluzione["departuretime"];
            datetime.setTime(time2);
            soluzione["arrivaltime"] = datetime.toMSecsSinceEpoch();
          //qDebug()<<"arrivaltime: "<<datetime.toMSecsSinceEpoch();

            m_model->insert(soluzione);
        }

    }else qDebug()<<"could not split html";
}
