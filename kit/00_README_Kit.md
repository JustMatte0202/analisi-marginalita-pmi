# Kit progetto — analisi margine per PMI industriali

Obiettivo: passare da "qualche giorno" a **mezza giornata** per progetto, con un risultato
graficamente coerente ogni volta. Il kit è anche il motivo per cui potrai consegnare in due
settimane ciò per cui un'agenzia ne chiede otto.

## Contenuto

| Cartella | File | A cosa serve |
|---|---|---|
| `01_Tema` | `tema-industriale.json` | Tema Power BI. Palette, font, spaziature, tabelle, assi. Risolve il "bruttino" una volta per tutte. |
| `02_DAX` | `01_Calendario.dax` | Tabella Calendario completa in italiano, con istruzioni post-creazione |
| `02_DAX` | `02_Libreria_Misure.dax` | ~55 misure: fatturato, margine, ponte margine, clienti, magazzino, qualità dati |
| `03_PowerQuery` | `01_Funzioni_Pulizia.m` | 6 funzioni per i 6 problemi tipici dell'export gestionale |
| `03_PowerQuery` | `02_Query_Report_Anomalie.m` | Tabella riassuntiva delle anomalie trovate — materia prima del report |
| `04_Checklist` | `Checklist_Qualita_Dati.md` | Le 6 fasi da chiudere prima di costruire un solo grafico |
| `05_Template_Report` | `Template_Report_Cliente.md` | Struttura del PDF finale, con le istruzioni di tono |

## Come si applica il tema

1. Power BI Desktop → scheda **Visualizza** → **Temi** → freccia in basso → **Sfoglia temi**
2. Seleziona `tema-industriale.json`
3. Fatto: card, tabelle, assi, griglie e colori si allineano su tutto il report

Colori: blu profondo `#1F3A5F` (principale), ambra `#C8892A` (attenzione),
rosso mattone `#A63A2E` (negativo), verde `#4A7C59` (positivo), sfondo pagina `#F5F3EF`.
Funziona in stampa e in proiezione, non solo a schermo.

## Come si usa la libreria misure

Le misure sono scritte per questi nomi di colonna. **Rinomina in Power Query**, non nel DAX:
è il modo per riusare la libreria senza toccarla mai.

```
righe_ordine        : id_ordine, id_cliente, codice_articolo, data_ordine,
                      quantita, prezzo_unitario, sconto_pct, costo_trasporto
anagrafica_articoli : codice_articolo, descrizione, famiglia, categoria,
                      costo_acquisto, prezzo_listino
anagrafica_clienti  : id_cliente, ragione_sociale, provincia, canale
movimenti_magazzino : codice_articolo, data_movimento, tipo, quantita, valore_movimento
note_credito        : id_cliente, data, valore, causale, codice_articolo
```

Se il gestionale del cliente usa nomi diversi, il lavoro di adattamento è **una sola query
di rinomina per tabella**. Tutto il resto del kit funziona senza modifiche.

## Ordine di lavoro su un progetto nuovo

1. Copia la cartella `Kit` nel progetto
2. Carica i grezzi in Power Query, tutte le query con suffisso `_grezzo`
3. Incolla le 6 funzioni `fx*` come query separate
4. Esegui `Report_Anomalie` → **screenshot: è la sezione 2 del report al cliente**
5. Applica le funzioni di pulizia, produci le query pulite
6. Crea Calendario e relazioni (schema a stella)
7. Incolla la libreria misure nella tabella `_Misure`
8. Applica il tema
9. Chiudi la checklist, con la riconciliazione col bilancio
10. Costruisci i visual — ora sono l'ultimo passo, non il primo
11. Scrivi il report dal template

## Regola sull'uso dell'IA

Genera pure DAX e M, ma **non consegnare una riga che non sapresti spiegare a voce**
davanti al cliente. Il giorno in cui non sai rispondere al "perché questo numero è questo",
il rapporto è finito.

## Manutenzione del kit

Ogni progetto nuovo deve lasciare qui almeno una cosa: una misura, una funzione, una riga
di checklist. Se dopo tre progetti il kit non è cresciuto, non lo stai usando davvero.
