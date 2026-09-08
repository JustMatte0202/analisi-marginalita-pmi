// ============================================================
// FUNZIONI DI PULIZIA RIUTILIZZABILI — Kit Matteo
// Come si usano: in Power Query > Query vuota > Editor avanzato,
// incolla UNA funzione per query e rinomina la query come il nome indicato.
// Poi le richiami da qualsiasi altra query.
// ============================================================


// ============================================================
// fxDataMista  —  PROBLEMA 1: date in due formati nella stessa colonna
// Risolve il caso "04/08/2025" (italiano) mescolato a "2025-08-04" (ISO).
// Nome query: fxDataMista
// Uso:  = Table.TransformColumns(Origine, {{"data_ordine", fxDataMista, type date}})
// ============================================================
let
    fxDataMista = (input as nullable text) as nullable date =>
    let
        Testo = if input = null then null else Text.Trim(Text.From(input)),
        Risultato =
            if Testo = null or Testo = "" then null
            // formato ISO: 2025-08-04
            else if Text.Length(Testo) >= 10 and Text.Contains(Text.Start(Testo, 10), "-") and Text.Length(Text.BeforeDelimiter(Testo, "-")) = 4
                then Date.FromText(Text.Start(Testo, 10))
            // formato italiano gg/mm/aaaa  (o gg-mm-aaaa)
            else
                let
                    Norm = Text.Replace(Text.Replace(Testo, ".", "/"), "-", "/"),
                    Parti = Text.Split(Text.BeforeDelimiter(Norm, " "), "/"),
                    G = Number.FromText(Parti{0}),
                    M = Number.FromText(Parti{1}),
                    A = Number.FromText(Parti{2}),
                    AnnoPieno = if A < 100 then 2000 + A else A
                in
                    #date(AnnoPieno, M, G)
    in
        try Risultato otherwise null
in
    fxDataMista


// ============================================================
// fxNumeroMisto  —  PROBLEMA 2: separatori decimali incoerenti
// Gestisce "1.234,56"  "1,234.56"  "70,19"  "70.19"  "1234"
// Nome query: fxNumeroMisto
// Uso:  = Table.TransformColumns(Origine, {{"prezzo_unitario", fxNumeroMisto, type number}})
// ============================================================
let
    fxNumeroMisto = (input as nullable text) as nullable number =>
    let
        T = if input = null then null else Text.Trim(Text.From(input)),
        Pulito = if T = null then null else Text.Remove(T, {"€", " ", Character.FromNumber(160)}),
        HaVirgola = Pulito <> null and Text.Contains(Pulito, ","),
        HaPunto   = Pulito <> null and Text.Contains(Pulito, "."),
        PosVirgola = if HaVirgola then Text.PositionOf(Pulito, ",", Occurrence.Last) else -1,
        PosPunto   = if HaPunto then Text.PositionOf(Pulito, ".", Occurrence.Last) else -1,
        Normalizzato =
            if Pulito = null or Pulito = "" then null
            // entrambi presenti: l'ULTIMO e' il separatore decimale
            else if HaVirgola and HaPunto then
                if PosVirgola > PosPunto
                then Text.Replace(Text.Replace(Pulito, ".", ""), ",", ".")     // 1.234,56
                else Text.Replace(Pulito, ",", "")                             // 1,234.56
            // solo virgola: decimale se seguono 1-2 cifre, altrimenti migliaia
            else if HaVirgola then
                if Text.Length(Text.AfterDelimiter(Pulito, ",", {0, RelativePosition.FromEnd})) <= 2
                then Text.Replace(Pulito, ",", ".")
                else Text.Replace(Pulito, ",", "")
            // solo punto: decimale se seguono 1-2 cifre, altrimenti migliaia
            else if HaPunto then
                if Text.Length(Text.AfterDelimiter(Pulito, ".", {0, RelativePosition.FromEnd})) <= 2
                then Pulito
                else Text.Replace(Pulito, ".", "")
            else Pulito
    in
        try Number.FromText(Normalizzato, "en-US") otherwise null
in
    fxNumeroMisto


// ============================================================
// fxNormalizzaCodice  —  PROBLEMI 4 e 5: duplicati da spazi / maiuscole
// Toglie spazi iniziali/finali, doppi spazi interni, caratteri invisibili,
// e uniforma in maiuscolo. Da applicare a OGNI chiave prima delle relazioni.
// Nome query: fxNormalizzaCodice
// Uso:  = Table.TransformColumns(Origine, {{"codice_articolo", fxNormalizzaCodice, type text}})
// ============================================================
let
    fxNormalizzaCodice = (input as nullable text) as nullable text =>
    let
        T = if input = null then null else Text.From(input),
        SenzaInvisibili = if T = null then null else Text.Remove(T, {Character.FromNumber(160), Character.FromNumber(9), Character.FromNumber(13), Character.FromNumber(10)}),
        Compresso = if SenzaInvisibili = null then null else Text.Combine(List.Select(Text.Split(SenzaInvisibili, " "), each _ <> ""), " "),
        Finale = if Compresso = null or Compresso = "" then null else Text.Upper(Text.Trim(Compresso))
    in
        Finale
in
    fxNormalizzaCodice


// ============================================================
// fxNormalizzaRagioneSociale  —  PROBLEMA 4: anagrafiche cliente duplicate
// Produce una chiave di confronto per trovare "ROSSI SRL" = "Rossi S.r.l."
// NON sostituisce il nome originale: crea una colonna di appoggio per il match.
// Nome query: fxNormalizzaRagioneSociale
// Uso: aggiungi colonna personalizzata = fxNormalizzaRagioneSociale([ragione_sociale])
//      poi raggruppa su quella colonna per contare i duplicati.
// ============================================================
let
    fxNormalizzaRagioneSociale = (input as nullable text) as nullable text =>
    let
        T = if input = null then null else Text.Upper(Text.Trim(Text.From(input))),
        SenzaPunti = if T = null then null else Text.Remove(T, {".", ",", "'", "-", "&"}),
        FormeSocietarie = {" SRL", " SPA", " SNC", " SAS", " SS", " SRLS", " S R L", " S P A", " S N C", " S A S"},
        SenzaForma = if SenzaPunti = null then null else
            List.Accumulate(FormeSocietarie, SenzaPunti, (stato, corrente) =>
                if Text.EndsWith(stato, corrente) then Text.Start(stato, Text.Length(stato) - Text.Length(corrente)) else stato),
        Compresso = if SenzaForma = null then null else Text.Combine(List.Select(Text.Split(SenzaForma, " "), each _ <> ""), " ")
    in
        if Compresso = null then null else Text.Trim(Compresso)
in
    fxNormalizzaRagioneSociale


// ============================================================
// fxRecuperaCostoDaCarichi  —  PROBLEMA 3: costo di acquisto mancante
// Recupera il costo medio ponderato dai movimenti di carico da fornitore
// e lo usa solo dove l'anagrafica e' vuota o a zero.
// Nome query: fxRecuperaCostoDaCarichi
// Uso: = fxRecuperaCostoDaCarichi(anagrafica_articoli, movimenti_magazzino)
// ============================================================
let
    fxRecuperaCostoDaCarichi = (Articoli as table, Movimenti as table) as table =>
    let
        Carichi = Table.SelectRows(Movimenti, each [tipo] = "CARICO" and [quantita] > 0 and [valore_movimento] <> null),
        CostoMedio = Table.Group(
            Carichi, {"codice_articolo"},
            {{"costo_da_carichi", each List.Sum([valore_movimento]) / List.Sum([quantita]), type number}}
        ),
        Unito = Table.NestedJoin(Articoli, {"codice_articolo"}, CostoMedio, {"codice_articolo"}, "_c", JoinKind.LeftOuter),
        Espanso = Table.ExpandTableColumn(Unito, "_c", {"costo_da_carichi"}, {"costo_da_carichi"}),
        Colmato = Table.AddColumn(Espanso, "costo_acquisto_finale",
            each if [costo_acquisto] = null or [costo_acquisto] = 0 then [costo_da_carichi] else [costo_acquisto], type number),
        Flag = Table.AddColumn(Colmato, "costo_recuperato",
            each [costo_acquisto] = null or [costo_acquisto] = 0, type logical)
    in
        Flag
in
    fxRecuperaCostoDaCarichi


// ============================================================
// fxTrasportoSuTestata  —  PROBLEMA 6: costo trasporto solo sulla prima riga
// Lo isola in una tabella a livello ORDINE, cosi' non puo' essere
// sommato riga per riga per sbaglio.
// Nome query: fxTrasportoSuTestata
// Uso: = fxTrasportoSuTestata(righe_ordine)   --> tabella testate ordine
// Poi: relazione testate[id_ordine] --> righe_ordine[id_ordine]
// ============================================================
let
    fxTrasportoSuTestata = (Righe as table) as table =>
    let
        Ridotto = Table.SelectColumns(Righe, {"id_ordine", "id_cliente", "data_ordine", "costo_trasporto"}),
        Raggruppato = Table.Group(
            Ridotto, {"id_ordine"},
            {
                {"id_cliente",      each List.First([id_cliente])},
                {"data_ordine",     each List.First([data_ordine])},
                {"costo_trasporto", each List.Max(List.RemoveNulls([costo_trasporto])), type number},
                {"numero_righe",    each Table.RowCount(_), Int64.Type}
            }
        )
    in
        Raggruppato
in
    fxTrasportoSuTestata
