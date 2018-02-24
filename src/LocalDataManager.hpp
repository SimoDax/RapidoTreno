/*
 * StationListManager.h
 *
 *  Created on: 16/apr/2017
 *      Author: Simone
 */

#ifndef STATIONLISTMANAGER_H_
#define STATIONLISTMANAGER_H_

#include <QtCore/QObject>
#include <bb/cascades/GroupDataModel>
#include <QtLocationSubset/QGeoPositionInfoSource>
#include <bb/system/SystemDialog>

using namespace bb::cascades;
using namespace bb::system;
using namespace QtMobilitySubset;

class LocalDataManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bb::cascades::DataModel* stazioni READ stazioni CONSTANT)

public:

    LocalDataManager(QObject* parent=0);

public Q_SLOTS:

    void smartLoad(QString init);
    void load(QString init);
    void loadNearest();
    void save(QString from, QString to);
    void reset();
    void cleanup();
    void encryptCredentials(const QString &user, const QString &pass);
    QVariantMap decryptCredentials();
    void deleteCredentials();

 Q_SIGNALS:

    void locationError(QString err);
    void nearestSelected(QString staz);

private Q_SLOTS:

    void onGPSFix(const QGeoPositionInfo &fix);
    void onDialogFinished(bb::system::SystemUiResult::Type result);
    void onStationsDialogFinished(bb::system::SystemUiResult::Type result);
    void onTimeout();

private:

    void writeJSON(const  QString &path, QVariant &data);
    void readJSON(const QString &path);
    double getDistance(double x1, double y1, double x2, double y2);

    bb::cascades::DataModel* stazioni() const;

    void caricaordineinversoesalva();

private:

    GroupDataModel * m_stazioni;
    QVariantList m_list;
    QVariantList m_coord;
    static const QString m_dumpStazioniPath;
    static const QString m_dumpViaggiatrenoPath;
    static const QString m_dumpCodiciPath;
    static const QString m_credentialsPath;
};

#endif /* STATIONLISTMANAGER_H_ */
