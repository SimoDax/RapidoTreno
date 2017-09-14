

  <div id="readme" class="readme blob instapaper_body">
    <article class="markdown-body entry-content" itemprop="text"><h1><a id="user-content-rapidotreno" class="anchor" href="#rapidotreno" aria-hidden="true"><svg aria-hidden="true" class="octicon octicon-link" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M4 9h1v1H4c-1.5 0-3-1.69-3-3.5S2.55 3 4 3h4c1.45 0 3 1.69 3 3.5 0 1.41-.91 2.72-2 3.25V8.59c.58-.45 1-1.27 1-2.09C10 5.22 8.98 4 8 4H4c-.98 0-2 1.22-2 2.5S3 9 4 9zm9-3h-1v1h1c1 0 2 1.22 2 2.5S13.98 12 13 12H9c-.98 0-2-1.22-2-2.5 0-.83.42-1.64 1-2.09V6.25c-1.09.53-2 1.84-2 3.25C6 11.31 7.55 13 9 13h4c1.45 0 3-1.69 3-3.5S14.5 6 13 6z"></path></svg></a>RapidoTreno</h1>
<p><a href="https://www.gnu.org/licenses/gpl-3.0"><img src="https://camo.githubusercontent.com/bf135a9cea09d0ea4bba410582c0e70ec8222736/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f4c6963656e73652d47504c25323076332d626c75652e737667" alt="License: GPL v3" data-canonical-src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" style="max-width:100%;"></a></p>
<p><a href="https://appworld.blackberry.com/webstore/content/59998595/?countrycode=IT&amp;lang=it"><img src="https://github.com/SimoDax/RapidoTreno/raw/master/bbworld.jpg" alt="Get it at BlackBerry World" style="max-width:100%;"></a></p>
<p>Sorgente dell'app per BB10. Questa repo vuole essere solamente un mezzo per rendere pubblico il codice, nella speranza che sia utile a qualcuno.</p>
<p>Alcune parti sono state scritte quando avevo ancora poca dimestichezza con le librerie dell'os (<a href="https://www.qt.io/">Qt</a> in primis), potrebbero essere riscritte in modo più compatto ed elegante ma dato che funzionano egregiamente non ho intenzione di toccarle, per ora. Ci sono pezzi di codice vecchio che è stato commentato, lo tengo caso mai tornasse utile in futuro.</p>
<p>L'app è strutturata in una classe principale, App, che (eccetto qualche funzione di utlity) interfaccia l'ui con le altre classi, dove avviene l'elaborazione dei dati vera e propria. In questo modo i file Qml si rivolgono solo ad App per richiedere e caricare i dati, semplificando le connessioni, al come vengono invece caricati ci pensano le varie classi, istanziate opportunamente da App.
Fa eccezione alla regola la classe LocalDataManager che per comodità viene istanziata direttamente dal Qml, infatti differentemente dalle altre classi tratta file locali e non effettua richieste web.</p>
<p>Le cartelle mindw76h128du e mindw120h120du contengono asset specifici rispettivamente per i dispositivi con schermo widescreen e ad alta densità di pixel (Passport)</p>
<p>Ho omesso il file bar-descriptor.xml, nel caso doveste ricompilare il codice createne uno con il vostro AuthorId se volete firmare digitalmente il software.</p>
<p>La documentazione ufficiale per le librerie proprietarie BlackBerry 10 è consultabile <a href="https://developer.blackberry.com/native/documentation/">qui</a></p>
</article>
  </div>

  </div>

 
