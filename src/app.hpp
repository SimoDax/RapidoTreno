#ifndef APP_HPP
#define APP_HPP

#include "ArtifactRequest.hpp"
#include "TrainRequest.hpp"
#include "ItaloApiRequest.hpp"

#include <bb/cascades/GroupDataModel>
#include <bb/cascades/ArrayDataModel>
#include <bb/cascades/AbstractPane>
#include <bb/system/SystemListDialog>
#include <bb/system/SystemUiResult>
#include <bb/system/InvokeManager>

#include <QtCore/QObject>
#include <QtCore/QMap>


//! [0]
class App : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY statusChanged)
    Q_PROPERTY(bool pend READ pend NOTIFY pendChanged)
    Q_PROPERTY(bool loggedIn READ loggedIn)

    Q_PROPERTY(bb::cascades::DataModel* model READ model CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* stazioni READ stazioni CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* ricerche READ ricerche CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* news READ news CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* solutionDetails READ solutionDetails CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* stazioneStatus READ stazioneStatus CONSTANT)
    Q_PROPERTY(bb::cascades::DataModel* tickets READ tickets CONSTANT)
    Q_PROPERTY(QVariantMap statusData READ statusData CONSTANT)
    Q_PROPERTY(QVariantMap profileData READ profileData CONSTANT)
    Q_PROPERTY(QVariantList trainsDetails READ trainsDetails CONSTANT)


public:
    App(QObject *parent = 0);


public Q_SLOTS:

    void requestArtifact(const QString &da, const QString &a, const QString &dt, const QString &adulti, const QString &bambini, const QString &frecce, bool italo, bool silent);

    void requestStatusData(const QString &num);

    void requestStatusDataItalo(const QString &num);

    void requestFSNews();

    void requestStation(QString num);

    void requestAreaPers(QString user, QString pass);

    void openTicket(const QString &id, const QString &tsid);

    void requestOffers(QString id, bool custom);

    void setSolutionDetailsModel(const QVariantList indexPath);

    Q_INVOKABLE QVariant requestStatusField(const QString &field, const int &field2, const QString &field3);
    Q_INVOKABLE QVariant requestStatusField(const QString &field, const int &field2);
    Q_INVOKABLE QVariant requestStatusField(const QString &field);

    void salvaEvento(const QVariantList indexPath);

    void saveSetting(const QString &key, const QVariant &value);

    QVariant loadSetting(const QString &key);
    /*
     * Allows the QML to reset the state of the application
     */
    void reset();

    void resetStazioni();

    void salvaRicerca(QString num);

    void caricaRicerche();

    void clearPreloaded();

    void pagah(const QVariantList indexPath, const QString &adulti, const QString &bambini);

    void switchPend(const QString &part, const QString &arr);
    /**
     * Called to get date string from a timestamp.
     */
    Q_INVOKABLE QString dateFromTimestamp(const QString &timestamp);

Q_SIGNALS:
    /*
     * This signal is emitted whenever the artifacts have been loaded successfully
     */
    void artifactsLoaded();
    void stazioniLoaded();
    void statusDataLoaded();
    void stationDataLoaded();
    void newsLoaded();
    void profileLoaded();
    void offersLoaded();
    /*
     * The change notification signals of the properties
     */
    //void activeChanged();
    void statusChanged();

    void pendChanged();

    void pendToast();

    void badResponse(QString errorMessage);

    void abort();

    void displayWait();

    void showDetails();

    void removeWait();

    //void openChanged();

    //void ricercheLoaded();

private:

    /*
     * The accessor methods of the properties
     */
    //bool active() const;
    QString errorMessage() const;
    bool pend() const;
    bool loggedIn();
    bb::cascades::DataModel* model() const;
    bb::cascades::DataModel* stazioni() const;
    bb::cascades::DataModel* ricerche() const;
    bb::cascades::DataModel* news() const;
    bb::cascades::DataModel* solutionDetails() const;
    bb::cascades::DataModel* stazioneStatus() const;
    bb::cascades::DataModel* tickets() const;
    QVariantMap statusData() const;
    QVariantMap profileData() const;
    QVariantList trainsDetails() const;
    //QList<QList<QMap>>* preloaded() const;

private:
    bool m_active, m_pend, m_logged;
    QString m_errorMessage;
    bb::cascades::GroupDataModel* m_model;
    bb::cascades::GroupDataModel* m_stazioni;
    bb::cascades::GroupDataModel* m_news;
    bb::cascades::GroupDataModel* m_solutionDetails;
    bb::cascades::GroupDataModel* m_stazioneStatus;
    bb::cascades::GroupDataModel* m_tickets;
    bb::cascades::ArrayDataModel* m_ricerche;
    QVariantList* m_trainsDetails;
    //bb::cascades::ArrayDataModel* m_stazioni;
    bb::cascades::AbstractPane* root;
    QVariantMap* m_statusData;
    QVector<QVariantList>* m_preloaded;
    static const QString m_filePath;
    static const QString m_prefPath;
    static const QString m_stazioniPath;
    static const QString m_dumpStazioniPath;
    QNetworkAccessManager * m_qnam;
    QVariantMap* m_profile;
};


#endif
