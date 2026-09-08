# Checklist qualità dati — da eseguire prima di costruire qualsiasi grafico

Regola: **nessun visual viene creato finché questa checklist non è chiusa.**
Ogni riga che spunti è anche una riga del report finale al cliente.

---

## Fase 1 — Ricezione dei file (prima di aprire Power BI)

- [ ] Ho ricevuto tutti e cinque gli export? (articoli, clienti, righe ordine, movimenti magazzino, note di credito)
- [ ] Ho chiesto **da quale data a quale data** sono estratti? (un export parziale falsa ogni confronto anno su anno)
- [ ] Ho chiesto se i valori sono **al netto o al lordo di IVA**?
- [ ] Ho chiesto quali **codici/causali** vanno esclusi? (omaggi, note interne, resi a fornitore, articoli fittizi)
- [ ] Ho salvato una copia **read-only degli originali** in una cartella `00_Originali`, mai toccata?

## Fase 2 — Struttura (Power Query, prima di trasformare)

- [ ] Ogni file ha il **numero di righe che il cliente si aspetta**? (chiediglielo: "quanti ordini avete fatto nel 2025?")
- [ ] Le intestazioni sono sulla prima riga, senza righe di titolo sopra?
- [ ] Nessuna colonna con nomi tipo `Column1`, `Colonna23`?
- [ ] Tipi di dato impostati **esplicitamente** su ogni colonna? (mai lasciare "any")
- [ ] Le **chiavi** (codice articolo, id cliente, id ordine) sono passate da `fxNormalizzaCodice`?

## Fase 3 — I sei problemi tipici dell'export gestionale

- [ ] **Date** — un solo formato? (`fxDataMista`) → controlla il min e il max: sono plausibili?
- [ ] **Decimali** — punto/virgola coerenti? (`fxNumeroMisto`) → il totale fatturato è dell'ordine di grandezza giusto?
- [ ] **Costi mancanti** — quanti articoli a costo 0 o vuoto? (`fxRecuperaCostoDaCarichi`)
- [ ] **Clienti duplicati** — (`fxNormalizzaRagioneSociale`) → il conteggio clienti coincide con quello che dice il titolare?
- [ ] **Codici duplicati** — spazi finali, maiuscole/minuscole
- [ ] **Costi di testata** — trasporto/imballo isolati a livello ordine? (`fxTrasportoSuTestata`)

## Fase 4 — Modello

- [ ] Schema a stella: dimensioni → fatti, relazioni 1 a molti, direzione singola
- [ ] Tabella Calendario creata, contrassegnata come tabella data, collegata
- [ ] **Zero relazioni molti-a-molti** (se ne serve una, manca una dimensione)
- [ ] Colonne tecniche e chiavi nascoste dalla vista report
- [ ] Tutte le misure nella tabella `_Misure`, organizzate in cartelle
- [ ] Formati numerici impostati sulle misure (€, %, decimali) — non sui visual

## Fase 5 — Riconciliazione (il passaggio che nessuno fa)

- [ ] **Fatturato totale confrontato con il bilancio o la dichiarazione IVA del cliente.** Scarto accettabile: sotto il 2%. Se è di più, non consegnare: capisci prima perché.
- [ ] Numero clienti attivi confrontato con quello che dice il commerciale
- [ ] Valore magazzino confrontato con l'ultimo inventario
- [ ] Il margine complessivo è vicino a quello che il titolare si aspetta? Se è **molto** diverso, o hai trovato qualcosa di grosso o hai sbagliato. Verifica quale delle due prima di dirlo.
- [ ] Il **ponte margine** (misure `Ponte 1..6`) chiude esattamente? 1+2+3+4+5 = 6

## Fase 6 — Prima di consegnare

- [ ] Pagina nascosta "Qualità dati": tutte le misure `QD` a zero, `QD Semaforo` = OK
- [ ] Aperto il report su schermo piccolo: si legge?
- [ ] Stampato in PDF: i colori funzionano anche senza sfondo scuro?
- [ ] Ogni pagina ha un titolo che dice **cosa deve capire chi guarda**, non cosa contiene
- [ ] Aggiornamento automatico configurato e testato con un secondo export
- [ ] So spiegare **a voce, senza slide**, i tre numeri principali e da dove vengono
