// ============================================================
// REPORT ANOMALIE — Kit Matteo
// Query da eseguire SUBITO dopo il caricamento, prima di modellare.
// Produce una tabella unica con il conteggio di ogni problema trovato.
// E' il materiale grezzo della sezione "cosa non funzionava nei dati"
// del tuo report PDF: qui nasce il valore percepito dal cliente.
//
// Nome query: Report_Anomalie
// ============================================================
let
    // --- adatta questi nomi alle query del progetto ---
    Articoli  = anagrafica_articoli_grezzo,
    Clienti   = anagrafica_clienti_grezzo,
    Righe     = righe_ordine_grezzo,
    NoteCred  = note_credito_grezzo,

    Controlli = #table(
        type table [Controllo = text, Tabella = text, Conteggio = number, Impatto = text],
        {
            {
                "Articoli senza costo di acquisto", "anagrafica_articoli",
                Table.RowCount(Table.SelectRows(Articoli, each [costo_acquisto] = null or [costo_acquisto] = 0)),
                "Margine gonfiato al 100% su questi articoli"
            },
            {
                "Codici articolo duplicati", "anagrafica_articoli",
                Table.RowCount(Articoli) - List.Count(List.Distinct(Table.Column(Articoli, "codice_articolo"))),
                "Giacenza e vendite spezzate su piu' righe"
            },
            {
                "Codici con spazi anomali", "anagrafica_articoli",
                Table.RowCount(Table.SelectRows(Articoli, each Text.From([codice_articolo]) <> Text.Trim(Text.From([codice_articolo])))),
                "Duplicati invisibili, relazioni che non agganciano"
            },
            {
                "Anagrafiche cliente duplicate", "anagrafica_clienti",
                Table.RowCount(Clienti) - List.Count(List.Distinct(List.Transform(Table.Column(Clienti, "ragione_sociale"), each fxNormalizzaRagioneSociale(_)))),
                "Conteggio clienti errato, perdita di fiducia nel report"
            },
            {
                "Righe con data non interpretabile", "righe_ordine",
                Table.RowCount(Table.SelectRows(Righe, each fxDataMista([data_ordine]) = null and [data_ordine] <> null)),
                "Ordini nel mese sbagliato, stagionalita' inventata"
            },
            {
                "Righe con prezzo non numerico", "righe_ordine",
                Table.RowCount(Table.SelectRows(Righe, each fxNumeroMisto([prezzo_unitario]) = null and [prezzo_unitario] <> null)),
                "Fatturato sottostimato"
            },
            {
                "Righe orfane (articolo non in anagrafica)", "righe_ordine",
                Table.RowCount(Table.SelectRows(Righe, each not List.Contains(Table.Column(Articoli, "codice_articolo"), [codice_articolo]))),
                "Fatturato che sparisce dalle analisi per famiglia"
            },
            {
                "Note di credito > 20% del fatturato", "note_credito",
                if List.Sum(Table.Column(NoteCred, "valore")) > 0.2 * List.Sum(Table.Column(Righe, "prezzo_unitario")) then 1 else 0,
                "Sintomo di separatore decimale sbagliato (valori x100)"
            }
        }
    ),
    SoloProblemi = Table.SelectRows(Controlli, each [Conteggio] > 0),
    Ordinato = Table.Sort(SoloProblemi, {{"Conteggio", Order.Descending}})
in
    Ordinato
