// =============================================================================
// FICHIER 1: initVariable.pas CORRIGÉ
// =============================================================================

unit initVariable;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Sysutils,raylib;

const
  InfoBoxWidth = 300;             // Largeur du cadre d'informations
  InfoBoxHeight = 150;            // Hauteur de la zone d'informations
  WindowWidth = 1024+InfoBoxWidth;              // Largeur de la fenêtre
  WindowHeight = 900 + InfoBoxHeight; // Hauteur de la fenêtre (inclut la zone d'information)
  SaveFileName = 'hexgridplat.csv'; //  nom sauvegarde fichier
  faitAstar=True;                   // declenche le calcul cheminement
  DecHt=20;                         // decalage haut ecran grille
  PanelWidth = 300;          // Largeur du panneau GUI
  DecBord =0;

type
  THexOrientation = (hoFlatTop, hoPointyTop);
   TAppMode = (amNormal, amDetection, amSuppression);
  TTypeCarteActive = (tcAucune, tcImportee, tcChargee);

   TColorCount = record
    Color: TColor;
    Count: Integer;
  end;

  TColorSignature = record
    DominantColors: array[0..2] of TColor;  // 3 couleurs principales
    ColorCounts: array[0..2] of Integer;    // Leur fréquence
    TotalPixels: Integer;                   // Nombre total de pixels analysés
    IsValid: Boolean;                       // Signature valide ou non
  end;
var
  // NOUVELLES VARIABLES DYNAMIQUES (remplacent les constantes)
  columns: integer = 16;                    // Nombre d'hexagones en largeur
  rows: integer = 20;                       // Nombre d'hexagones en hauteur
  TotalNbreHex: integer;                    // nombre hexagons (calculé)
  CoinIn: boolean = false;                  // extremement important

  // Variables dynamiques pour permettre l'ajustement
  HexDiameter: Single = 70.67;              // Diamètre de chaque hexagone (modifiable)
  HexRadius: Single;                        // Rayon de chaque hexagone (calculé)
  HexHeight: Single;                        // Hauteur de l'hexagone (calculé)
  HexWidth: Single;                         // Largeur totale d'un hexagone (calculé)
  decalageRayon: Single = 3;                // la detection se fait par la longueur du rayon

  // Nouveaux paramètres d'ajustement
  GridOffsetX: Single = -55;                // Décalage horizontal de toute la grille
  GridOffsetY: Single = -64;                // Décalage vertical de toute la grille
  HexScale: Single = 1.0;                   // Multiplicateur de taille (1.0 = taille normale)

  // Paramètres pour HandleMouseClick
  MouseOffsetX: Single = -55;                // Décalage souris X (était hardcodé)
  MouseOffsetY: Single = -64;                // Décalage souris Y (était hardcodé)

  // glisser deposer
  IsDragging: Boolean = False;
  DragStartPos: TVector2;
  DragStartOffsetX: Single;
  DragStartOffsetY: Single;
  MinDragDistance: Single = 5.0;
  MouseStartOffsetX: Single;
  MouseStartOffsetY: Single;

  // Variables pour le chargeur de cartes
  CartesList: array of string;
  CartesListText: string;
  SelectedCarteIndex: integer;
  CartesListInitialized: boolean;
  ShowCartesSelector: boolean;

  // Variables pour l'import de cartes
  NomCarteImportee: string;
  AfficherGrille: boolean = true;

  // Variables pour l'interface d'import
  ImportList: array of string;
  ImportListText: string;
  SelectedImportIndex: integer;
  ImportListInitialized: boolean;
  ShowImportSelector: boolean;

  // NOUVELLES VARIABLES pour création de grille
  colonnesText: string = '16';
  lignesText: string = '20';
  CoinInChecked: boolean = false;
  colonnesBuffer: array[0..10] of Char;
  lignesBuffer: array[0..10] of Char;
  editingColonnes: Boolean = false;
  editingLignes: Boolean = false;
  repertoireCarte: string;
  cheminSource: string;
  cheminDestination: string;
  extension: string;
  copieReussie: Boolean;

type
  TPoint = record
    x, y: integer;
  end;

  TEmplacement = (inconnu, CoinHG, CoinHD, CoinBG, CoinBD, BordH, BordB,BordG,BordD,Classic,Bloque);

  // Structure pour sauvegarder/charger les paramètres d'ajustement
  TAjustementParams = record
    DiameterValue: Single;
    OffsetX: Single;
    OffsetY: Single;
    Scale: Single;
  end;

  TMAP =record                    // carte principale
      Id:LongInt;
      nom:String;
      limage:timage;
      lacarte:TTexture2D;
      Fileimage: pchar;
      position:TVector2;
      commandelimage:timage;
      commande:TTexture2D;
      Filecommande: pchar;
      positioncommande:TVector2;
      Acharger:Boolean;
      grilletransparente:boolean       // est ce la grille hexagonale est transparente
   end;

  // Structure d'un hexagone avec un numéro, centre, couleur, sélection et voisins
  THexCell = record
    Number: integer;              // Numéro de l'hexagone
    center: Tvector2;               // Point central de l'hexagone
    Vertices: array[0..5] of TPoint;  // Les 6 sommets de l'hexagone
    Color: TColor;                // Couleur de l'hexagone
    ColorPt:tcolor;               // couleur point central pour inference
    Selected: boolean;            // État de sélection par clic
    Neighbors: array[1..6] of integer;  // Numéros des voisins contigus (6 voisins)
    Colonne: integer;                 // quelle est la colonne de cet haxagone,rows
    ligne: integer;                   // quelle est la ligne de cet hexagone, lines
    Poshexagone:TEmplacement;         // l'emplacement va nous servir pour connaitre la strategie à adopter pour trouver les voisins
    PairImpairLigne:boolean;           // va nous servir pour trouver les voisins tete pointue
    GCost, HCost, FCost: Integer;  // permet d effectuer les couts du trajet A*
    Parent: Integer;               // un parent possible, toujours pour A*
    Closed: Boolean;               // il est traité par A*
    Open: Boolean;                 //il est en cours de traitement par A*
    PairImpaircolonne:boolean;       //va nous servir pour trouver les voisins tete plate
    TypeTerrain: Integer;          // Type de terrain détecté (0 = aucun, 1,2,3... = types)
    IsReference: Integer;          // Numéro de référence (0 = pas référence, 1,2,3... = ordre de sélection)
    Supprime: Boolean;             // NOUVEAU: Suppression logique (True = supprimé, False = actif)
    Exempt: Boolean;// pour avoir un hexagone valide mais pas accessible.
  end;

  type
  TButtonAxel = record
    Rect: TRectangle;     // Rectangle du bouton
    NormalColor: TColor;  // Couleur normale
    HoverColor: TColor;   // Couleur lorsqu'on passe la souris dessus
    ClickedColor: TColor; // Couleur lorsqu'on clique
    IsClicked: Boolean;   // Indicateur de clic
  end;

var
  HexGrid: array of THexCell;                 // MAINTENANT DYNAMIQUE !
  i, j,k: integer;
  SelectedHex: THexCell;  // Hexagone actuellement sélectionné
  HexSelected: boolean;   // Indique si un hexagone est sélectionné
  Path: array of Integer;// le cheminastar
  lacarte:TMAP;
  AjustementParams: TAjustementParams;  // Pour sauvegarder les paramètres
  HexOrientation: THexOrientation = hoFlatTop;
  ButtonSave: TButtonAxel;
  CheckboxOrientation: TRectangle; // Rectangle pour la checkbox
  OrientationChecked: Boolean = False; // False = Flat, True = Pointy
  Hex1ReferenceX: Single = 50.0;
  Hex1ReferenceY: Single = 50.0;
  cheminComplet: string;
  TypeCarteActive: TTypeCarteActive = tcAucune;
  NomCarteCourante: string = '';
  MessageSauvegarde: string = '';
  cartePath: string;
  AfficherNumeros: boolean = true;
  CheckboxNumbers: TRectangle;
  panelRect: TRectangle;
  orientationText: string;
  wasChecked: Boolean;
  AppMode: TAppMode = amNormal;           // Mode d'application actuel
  AppModeIndex: Integer = 0;             // Index pour GuiToggleGroup (0=Normal, 1=Détection, 2=Suppression)
  ToggleGroupAppMode: TRectangle;        // ToggleGroup pour les modes d'application
   DetectionActive: Boolean = False;     // Mode sélection des références actif
  NombreReferences: Integer = 0;        // Compteur des références sélectionnées
  StatusDetection: string = 'Prêt';     // Statut affiché dans l'interface
  ReferenceSignatures: array of TColorSignature;  // Tableau dynamique des signatures de références
   ClassificationTerminee: Boolean = False;    // Classification terminée
  SpinnerCorrection: TRectangle;              // Spinner pour choisir le type
  ValeurSpinnerCorrection: Integer = 1;       // Valeur sélectionnée (1,2,3,4...)
   ShowResetDialog: Boolean = False;           // Afficher le popup de confirmation reset
    AppModeSuppressionIndex: Integer = 0;          // Index pour ToggleGroup Suppression (0=Suppression, 1=Exemption)
  ToggleGroupSuppression: TRectangle;            // ToggleGroup pour Suppression/Exemption


// Procédures pour gérer les dimensions dynamiques
procedure RecalculerDimensionsHex;
procedure AppliquerEchelle(NouvelleEchelle: Single);
procedure ModifierDecalage(DeltaX, DeltaY: Single);
procedure SauvegarderParametresAjustement( NomFichier: string);
procedure ChargerParametresAjustement( NomFichier: string);
procedure SetHexOrientation(NewOrientation: THexOrientation);
procedure SaveOrientationToParams;
procedure LoadOrientationFromParams;
procedure InitCarteLoader;
procedure ScanCartesDisponibles;
function ValidateCarteFiles(const cartePath: string): boolean;
procedure LoadCarteComplete(const carteName: string);
procedure InitImportSystem;
procedure ScanCartesRessources;
procedure LoadCarteImport(const nomFichier: string);
procedure SauvegarderCarteImportee;
procedure SauvegarderCarteUniverselle;
function LoadDetectionDataFromCSV(const csvFilePath: string): Boolean;

// NOUVELLES PROCÉDURES pour grille dynamique
procedure RecalculerTotalHex;
procedure RedimensionnerHexGrid;
procedure GenererNouvelleGrille;
function AppliquerParametresGrille: boolean;
procedure SaveHexGridToCSV();

implementation
uses HexagonLogic;

procedure SaveHexGridToCSV();
var
  F: TextFile;
  i, k: Integer;
  NeighborStr, VerticesStr: string;
  fichierCSV: string;
begin
  if (TypeCarteActive <> tcAucune) and (NomCarteCourante <> '') then
    fichierCSV := './save/' + NomCarteCourante + '/' + SaveFileName
  else
    fichierCSV := SaveFileName;

  WriteLn('Sauvegarde CSV dans: ' + fichierCSV);
  AssignFile(F, fichierCSV);
  Rewrite(F);
  try
    // MODIFIÉ: Ajout de la colonne Exempt à la fin
    Writeln(F, 'Number,CenterX,CenterY,ColorR,ColorG,ColorB,ColorPtR,ColorPtG,ColorPtB,BSelected,Colonne,Ligne,Emplacement,PairImpairLigne,' +
               'Vertex1X,Vertex1Y,Vertex2X,Vertex2Y,Vertex3X,Vertex3Y,Vertex4X,Vertex4Y,Vertex5X,Vertex5Y,Vertex6X,Vertex6Y,' +
               'Neighbor1,Neighbor2,Neighbor3,Neighbor4,Neighbor5,Neighbor6,TypeTerrain,IsReference,Supprime,Exempt');

    for i := 1 to TotalNbreHex do
    begin
      NeighborStr := Format('%d,%d,%d,%d,%d,%d', [HexGrid[i].Neighbors[1], HexGrid[i].Neighbors[2],
                                                  HexGrid[i].Neighbors[3], HexGrid[i].Neighbors[4],
                                                  HexGrid[i].Neighbors[5], HexGrid[i].Neighbors[6]]);

      VerticesStr := '';
      for k := 0 to 5 do
      begin
        VerticesStr := VerticesStr + Format('%d,%d', [HexGrid[i].Vertices[k].x, HexGrid[i].Vertices[k].y]);
        if k < 5 then
          VerticesStr := VerticesStr + ',';
      end;

      // MODIFIÉ: Ajout de Exempt à la fin de la ligne
      Writeln(F, Format('%d,%.0f,%.0f,%d,%d,%d,%d,%d,%d,%s,%d,%d,%s,%s,%s,%s,%d,%d,%s,%s',
        [HexGrid[i].Number,
         HexGrid[i].Center.x, HexGrid[i].Center.y,
         HexGrid[i].Color.r, HexGrid[i].Color.g, HexGrid[i].Color.b,
         HexGrid[i].ColorPt.r, HexGrid[i].ColorPt.g, HexGrid[i].ColorPt.b,
         BoolToStr(HexGrid[i].Selected, True),
         HexGrid[i].Colonne, HexGrid[i].Ligne,
         EmplacementToString(HexGrid[i].Poshexagone),
         BoolToStr(HexGrid[i].PairImpairLigne, True),
         VerticesStr,
         NeighborStr,
         HexGrid[i].TypeTerrain,
         HexGrid[i].IsReference,
         BoolToStr(HexGrid[i].Supprime, True),
         BoolToStr(HexGrid[i].Exempt, True)]));  // NOUVEAU: Exempt
    end;

    WriteLn('Sauvegarde terminée avec données de suppression et exemption');
  finally
    CloseFile(F);
  end;
end;
function LoadDetectionDataFromCSV(const csvFilePath: string): Boolean;
var
  F: TextFile;
  ligne: string;
  elements: array of string;
  i, elementCount: Integer;
  hexNumber: Integer;
  typeTerrain, isReference: Integer;
  supprime, exempt: Boolean;
  pos, startPos: Integer;
  loadedReferences: Integer;
begin
  Result := False;

  if not FileExists(PChar(csvFilePath)) then
  begin
    WriteLn('Fichier CSV introuvable: ' + csvFilePath);
    Exit;
  end;

  WriteLn('Chargement des données de détection, suppression et exemption depuis: ' + csvFilePath);

  AssignFile(F, PChar(csvFilePath));
  Reset(F);
  try
    // Lire la première ligne (en-têtes) et l'ignorer
    if not Eof(F) then
      Readln(F, ligne);

    loadedReferences := 0;

    // Lire chaque ligne de données
    while not Eof(F) do
    begin
      Readln(F, ligne);
      if Trim(ligne) = '' then Continue;

      // Parser la ligne CSV (méthode simple)
      SetLength(elements, 0);
      elementCount := 0;
      startPos := 1;

      for pos := 1 to Length(ligne) do
      begin
        if ligne[pos] = ',' then
        begin
          SetLength(elements, elementCount + 1);
          elements[elementCount] := Copy(ligne, startPos, pos - startPos);
          Inc(elementCount);
          startPos := pos + 1;
        end;
      end;

      // Ajouter le dernier élément
      SetLength(elements, elementCount + 1);
      elements[elementCount] := Copy(ligne, startPos, Length(ligne) - startPos + 1);
      Inc(elementCount);

      // MODIFIÉ: Vérifier qu'on a assez d'éléments (36: 35 colonnes originales + Exempt)
      if elementCount >= 36 then
      begin
        try
          hexNumber := StrToInt(Trim(elements[0]));
          typeTerrain := StrToInt(Trim(elements[32])); // TypeTerrain en position 32
          isReference := StrToInt(Trim(elements[33])); // IsReference en position 33
          supprime := (Trim(elements[34]) = 'True') or (Trim(elements[34]) = '-1'); // Supprime en position 34
          exempt := (Trim(elements[35]) = 'True') or (Trim(elements[35]) = '-1');   // NOUVEAU: Exempt en position 35

          // Vérifier que le numéro d'hexagone est valide
          if (hexNumber >= 1) and (hexNumber <= TotalNbreHex) then
          begin
            HexGrid[hexNumber].TypeTerrain := typeTerrain;
            HexGrid[hexNumber].IsReference := isReference;
            HexGrid[hexNumber].Supprime := supprime;
            HexGrid[hexNumber].Exempt := exempt;  // NOUVEAU: Charger l'état d'exemption

            if isReference > 0 then
              Inc(loadedReferences);
          end;

        except
          on E: Exception do
          begin
            WriteLn('Erreur lors du parsing de la ligne pour hexagone: ' + elements[0]);
            Continue;
          end;
        end;
      end
      // NOUVEAU: Gérer les anciens fichiers CSV (sans colonne Exempt)
      else if elementCount >= 35 then
      begin
        try
          hexNumber := StrToInt(Trim(elements[0]));
          typeTerrain := StrToInt(Trim(elements[32]));
          isReference := StrToInt(Trim(elements[33]));
          supprime := (Trim(elements[34]) = 'True') or (Trim(elements[34]) = '-1');

          if (hexNumber >= 1) and (hexNumber <= TotalNbreHex) then
          begin
            HexGrid[hexNumber].TypeTerrain := typeTerrain;
            HexGrid[hexNumber].IsReference := isReference;
            HexGrid[hexNumber].Supprime := supprime;
            HexGrid[hexNumber].Exempt := False;  // NOUVEAU: Par défaut False pour anciens fichiers

            if isReference > 0 then
              Inc(loadedReferences);
          end;

        except
          on E: Exception do
          begin
            WriteLn('Erreur lors du parsing de la ligne pour hexagone: ' + elements[0]);
            Continue;
          end;
        end;
      end;
    end;

    // Recalculer NombreReferences
    NombreReferences := loadedReferences;

    WriteLn('Données chargées avec succès:');
    WriteLn('- Références chargées: ' + IntToStr(loadedReferences));
    WriteLn('- TypeTerrain, Supprime et Exempt restaurés pour tous les hexagones');

    Result := True;

  except
    on E: Exception do
    begin
      WriteLn('ERREUR lors du chargement du CSV: ' + E.Message);
      Result := False;
    end;
  end;

  CloseFile(F);
end;

function CopierFichierAvecStream(const FichierSource, FichierDestination: string): Boolean;
var
  FluxSource, FluxDestination: TFileStream;
begin
  Result := False; // On part du principe que l'opération va échouer

  // Vérifier si le fichier source existe avant de commencer
  if not FileExists(pchar(FichierSource)) then
  begin
    WriteLn('Erreur (Stream) : Le fichier source "', FichierSource, '" n''existe pas.');
    Exit; // Quitte la fonction
  end;

  try
    FluxSource := TFileStream.Create(FichierSource, fmOpenRead);
    try
      FluxDestination := TFileStream.Create(FichierDestination, fmCreate);
      try
        // Copier tout le contenu du flux source vers le flux destination
        FluxDestination.CopyFrom(FluxSource, 0);
        Result := True; // La copie a réussi !
      finally
        FluxDestination.Free;
      end;
    finally
      FluxSource.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erreur (Stream) : Une exception est survenue lors de la copie. ', E.ClassName, ': ', E.Message);
      Result := False;
    end;
  end;
end;

procedure SauvegarderCarteUniverselle;


begin
  case TypeCarteActive of
    tcAucune:
    begin
      MessageSauvegarde := 'Aucune carte active à sauvegarder';
      WriteLn('Erreur: Aucune carte active');
      Exit;
    end;

    tcImportee, tcChargee:
    begin
      if NomCarteCourante = '' then
      begin
        MessageSauvegarde := 'Erreur: nom de carte invalide';
        WriteLn('Erreur: NomCarteCourante vide');
        Exit;
      end;

      WriteLn('=== SAUVEGARDE UNIVERSELLE ===');
      WriteLn('Type: ', Ord(TypeCarteActive), ' Nom: ', NomCarteCourante);

      // Créer le répertoire de destination
      repertoireCarte := './save/' + NomCarteCourante + '/';

      if not DirectoryExists(PChar('./save/')) then
        MakeDirectory('./save/');

      if not DirectoryExists(PChar(repertoireCarte)) then
        MakeDirectory(PChar(repertoireCarte));

      try
        // Pour carte importée : copier l'image
        if TypeCarteActive = tcImportee then
        begin
          cheminSource := string(lacarte.Fileimage);
          extension := ExtractFileExt(cheminSource);
          cheminDestination := repertoireCarte + NomCarteCourante + extension;

          WriteLn('Copie image: ', cheminSource, ' -> ', cheminDestination);

          //if FileExists(pchar('cheminSource')) then

            copieReussie := CopierFichierAvecStream(cheminSource, cheminDestination);
            if not copieReussie then
            begin
              MessageSauvegarde := 'Erreur: échec copie image';
              WriteLn('Erreur: Échec de la copie du fichier image');
              Exit;
            end;

         //// else
         //// begin
         //   MessageSauvegarde := 'Erreur: fichier source introuvable';
         //   WriteLn('Erreur: Fichier source introuvable: ' + cheminSource);
         //   Exit;
         // end;
        end;

        // Toujours sauvegarder les paramètres d'ajustement
        SauvegarderParametresAjustement(repertoireCarte + 'ajustements.txt');

        MessageSauvegarde := 'Carte "' + NomCarteCourante + '" sauvegardée avec succès';
        WriteLn('Sauvegarde réussie: ' + NomCarteCourante);

      except
        on E: Exception do
        begin
          MessageSauvegarde := 'Erreur lors de la sauvegarde';
          WriteLn('Erreur lors de la sauvegarde: ' + E.Message);
        end;
      end;
    end;
  end;
end;



procedure SauvegarderCarteImportee;
var
  repertoireCarte: string;
  cheminSource: string;
  cheminDestination: string;
  extension: string;
  copieReussie: Boolean;
begin
  if NomCarteImportee = '' then
  begin
    WriteLn('Erreur: Aucune carte importée à sauvegarder');
    Exit;
  end;

  // Créer le chemin du répertoire de destination
  repertoireCarte := './save/' + NomCarteImportee + '/';

  // Créer le répertoire s'il n'existe pas
  if not DirectoryExists(PChar('./save/')) then
    MakeDirectory('./save/');

  if not DirectoryExists(PChar(repertoireCarte)) then
    MakeDirectory(PChar(repertoireCarte));

  // Copier le fichier image
  cheminSource := string(lacarte.Fileimage);
  extension := ExtractFileExt(cheminSource);
  cheminDestination := repertoireCarte + NomCarteImportee + extension;

  WriteLn('DEBUG - cheminSource: "', cheminSource, '"');
  WriteLn('DEBUG - cheminDestination: "', cheminDestination, '"');

  try
    if FileExists(pchar(cheminSource)) then
    begin
      // CORRECTION ICI - utiliser les vraies variables string, pas PChar !
      copieReussie := CopierFichierAvecStream(cheminSource, cheminDestination);

      if copieReussie then
        WriteLn('Image copiée: ' + cheminSource + ' -> ' + cheminDestination)
      else
      begin
        WriteLn('ERREUR: Échec de la copie');
        Exit;
      end;
    end
    else
    begin
      WriteLn('Erreur: Fichier source introuvable: ' + cheminSource);
      Exit;
    end;

    // Sauvegarder les paramètres d'ajustement
    SauvegarderParametresAjustement(repertoireCarte + 'ajustements.txt');

    WriteLn('Carte sauvegardée avec succès: ' + NomCarteImportee);

  except
    on E: Exception do
    begin
      WriteLn('Erreur lors de la sauvegarde: ' + E.Message);
    end;
  end;
end;

// NOUVELLES FONCTIONS pour grille dynamique
procedure RecalculerTotalHex;
begin
  TotalNbreHex := columns * rows;
end;

procedure RedimensionnerHexGrid;
begin
  RecalculerTotalHex;
  SetLength(HexGrid, TotalNbreHex + 1); // +1 pour garder l'index 1..n
end;

procedure GenererNouvelleGrille;
begin
  // 1. Redimensionner le tableau
  RedimensionnerHexGrid;

  // 2. Régénérer la grille
  RecalculerDimensionsHex;
  GenerateHexagons;
  CalculateNeighbors;

  // 3. Réactiver l'affichage
  AfficherGrille := true;

  WriteLn('Nouvelle grille générée: ' + IntToStr(columns) + 'x' + IntToStr(rows) +
          ' CoinIn=' + BoolToStr(CoinIn, true));
end;

function AppliquerParametresGrille: boolean;
var
  nouvellesColonnes, nouvellesLignes: integer;
begin
  Result := false;

  try
    // Convertir les textes en nombres
    //nouvellesColonnes := StrToInt(Trim(colonnesText));
    //nouvellesLignes := StrToInt(Trim(lignesText));

    // Validation des limites
    if (columns< 2) or (columns > 1000) then
    begin
      WriteLn('Erreur: Colonnes doivent être entre 2 et 1000');
      Exit;
    end;

    if (rows < 2) or (rows > 1000) then
    begin
      WriteLn('Erreur: Lignes doivent être entre 2 et 1000');
      Exit;
    end;

    // Appliquer les nouveaux paramètres

    CoinIn := CoinInChecked;

    Result := true;

  except
    on E: Exception do
    begin
      WriteLn('Erreur de saisie: ' + E.Message);
    end;
  end;
end;

// TES PROCÉDURES EXISTANTES (inchangées)
procedure InitImportSystem;
begin
  SelectedImportIndex := -1;
  ImportListInitialized := false;
  ImportListText := '';
  ShowImportSelector := false;
  SetLength(ImportList, 0);
  NomCarteImportee := '';
  AfficherGrille := true;
end;

procedure ScanCartesRessources;
var
  files: TFilePathList;
  i: integer;
  fileName: PChar;
  nomFichier: string;
  extension: string;
  cheminRessources: string;
begin
  cheminRessources := 'C:\Users\Axel\Documents\FP\Pascaldemoraylib\Hexagon\ressources\';

  if not DirectoryExists(pchar(cheminRessources)) then
  begin
    WriteLn('Erreur: répertoire ressources introuvable: ' + cheminRessources);
    Exit;
  end;

  WriteLn('Scan du répertoire: ' + cheminRessources);
  SetLength(ImportList, 0);
  ImportListText := '';

  files := LoadDirectoryFiles(PChar(cheminRessources));

  try
    WriteLn('Nombre de fichiers trouvés: ' + IntToStr(files.count));

    for i := 0 to files.count - 1 do
    begin
      fileName := GetFileName(files.paths[i]);
      nomFichier := string(fileName);
      WriteLn('Fichier examiné: ' + nomFichier);

      extension := LowerCase(ExtractFileExt(nomFichier));
      WriteLn('Extension détectée: ' + extension);

      if (extension = '.png') or (extension = '.bmp') or (extension = '.jpg') or (extension = '.jpeg') then
      begin
        WriteLn('Image valide ajoutée: ' + nomFichier);
        SetLength(ImportList, Length(ImportList) + 1);
        ImportList[High(ImportList)] := nomFichier;

        if ImportListText <> '' then
          ImportListText := ImportListText + ';';
        ImportListText := ImportListText + nomFichier;
      end
      else
      begin
        WriteLn('Fichier ignoré (extension non supportée): ' + nomFichier + ' -> ' + extension);
      end;
    end;

    ImportListInitialized := true;
    SelectedImportIndex := -1;
    WriteLn('Nombre total d''images trouvées: ' + IntToStr(Length(ImportList)));

  finally
    UnloadDirectoryFiles(files);
  end;
end;

procedure LoadCarteImport(const nomFichier: string);
var
  nomSansExtension: string;
begin
  cheminComplet := './ressources/' + nomFichier;

  if not FileExists(PChar(cheminComplet)) then
  begin
    WriteLn('Fichier introuvable: ' + cheminComplet);
    Exit;
  end;

  WriteLn('Import de la carte: ' + nomFichier);

  try
    if lacarte.lacarte.id > 0 then
    begin
      UnloadTexture(lacarte.lacarte);
      UnloadImage(lacarte.limage);
    end;

    nomSansExtension := ChangeFileExt(nomFichier, '');

    lacarte.nom := nomSansExtension;
    lacarte.Fileimage := PChar(cheminComplet);
    lacarte.position := Vector2Create(0, 0);

    lacarte.limage := LoadImage(lacarte.Fileimage);
    lacarte.lacarte := LoadTextureFromImage(lacarte.limage);
    lacarte.Acharger := true;

    // NOUVEAU: Mise à jour du statut
    TypeCarteActive := tcImportee;
    NomCarteCourante := nomSansExtension;
    MessageSauvegarde := '';

    AfficherGrille := false;
    ShowImportSelector := false;

    WriteLn('Carte importée avec succès: ' + nomSansExtension);

  except
    on E: Exception do
    begin
      WriteLn('Erreur lors de l''import de la carte: ' + E.Message);
      lacarte.Acharger := false;
      TypeCarteActive := tcAucune;
      NomCarteCourante := '';
    end;
  end;
end;

procedure InitCarteLoader;
begin
  SelectedCarteIndex := -1;
  CartesListInitialized := false;
  CartesListText := '';
  ShowCartesSelector := false;
  SetLength(CartesList, 0);
end;

procedure ScanCartesDisponibles;
var
  files: TFilePathList;
  i: integer;
  fileName: PChar;
  carteName: string;
begin
  if not DirectoryExists('./save/') then
  begin
    WriteLn('Erreur: répertoire save introuvable');
    Exit;
  end;

  SetLength(CartesList, 0);
  CartesListText := '';

  files := LoadDirectoryFilesEx('./save/', 'DIR', false);

  try
    for i := 0 to files.count - 1 do
    begin
      fileName := GetFileName(files.paths[i]);
      carteName := string(fileName);

      if (carteName <> '.') and (carteName <> '..') then
      begin
        SetLength(CartesList, Length(CartesList) + 1);
        CartesList[High(CartesList)] := carteName;

        if CartesListText <> '' then
          CartesListText := CartesListText + ';';
        CartesListText := CartesListText + carteName;
      end;
    end;

    CartesListInitialized := true;
    SelectedCarteIndex := -1;

  finally
    UnloadDirectoryFiles(files);
  end;
end;

function ValidateCarteFiles(const cartePath: string): boolean;
var
  ajustementFile: string;
  carteFound: boolean;
  carteName: string;
begin
  ajustementFile := cartePath + 'ajustements.txt';

  if not FileExists(PChar(ajustementFile)) then
  begin
    Result := false;
    Exit;
  end;

  carteName := ExtractFileName(ExcludeTrailingPathDelimiter(cartePath));

  carteFound := FileExists(PChar(cartePath + carteName + '.png')) or
                FileExists(PChar(cartePath + carteName + '.bmp')) or
                FileExists(PChar(cartePath + carteName + '.jpg')) or
                FileExists(PChar(cartePath + carteName + '.jpeg'));

  Result := carteFound;
end;

procedure LoadCarteComplete(const carteName: string);
var
  csvDetectionPath: string;  // NOUVEAU: variable locale pour le chemin CSV
begin
  cartePath := './save/' + carteName + '/';

  if not ValidateCarteFiles(cartePath) then
  begin
    WriteLn('Chargement interrompu, il manque des fichiers');
    Exit;
  end;

  WriteLn('Chargement de la carte: ' + carteName);

  try
    ChargerParametresAjustement(cartePath + 'ajustements.txt');

    if lacarte.lacarte.id > 0 then
    begin
      UnloadTexture(lacarte.lacarte);
      UnloadImage(lacarte.limage);
    end;

    lacarte.nom := carteName;
    lacarte.position := Vector2Create(0, 0);

    // CORRECTION: Utiliser cheminComplet global
    if FileExists(PChar(cartePath + carteName + '.png')) then
      cheminComplet := cartePath + carteName + '.png'
    else if FileExists(PChar(cartePath + carteName + '.bmp')) then
      cheminComplet := cartePath + carteName + '.bmp'
    else if FileExists(PChar(cartePath + carteName + '.jpg')) then
      cheminComplet := cartePath + carteName + '.jpg'
    else if FileExists(PChar(cartePath + carteName + '.jpeg')) then
      cheminComplet := cartePath + carteName + '.jpeg'
    else
    begin
      WriteLn('Aucun fichier image trouvé pour: ' + carteName + ' (formats: png, bmp, jpg, jpeg)');
      lacarte.Acharger := false;
      TypeCarteActive := tcAucune;
      NomCarteCourante := '';
      Exit;
    end;

    // CORRECTION: Pointer vers la variable globale
    lacarte.Fileimage := PChar(cheminComplet);

    try
      lacarte.limage := LoadImage(lacarte.Fileimage);
      lacarte.lacarte := LoadTextureFromImage(lacarte.limage);
      lacarte.Acharger := true;
      WriteLn('Image chargée: ' + string(lacarte.Fileimage));
    except
      on E: Exception do
      begin
        WriteLn('Erreur lors du chargement de l''image: ' + E.Message);
        lacarte.Acharger := false;
        TypeCarteActive := tcAucune;
        NomCarteCourante := '';
        Exit;
      end;
    end;

    // IMPORTANT: Régénérer la grille avec la bonne taille
    RedimensionnerHexGrid;
    RecalculerDimensionsHex;
    GenerateHexagons;
    CalculateNeighbors;


    // ============ NOUVEAU: CHARGEMENT DES DONNÉES DE DÉTECTION ============
    csvDetectionPath := cartePath + SaveFileName;  // './save/carteName/hexgridplat.csv'
    if LoadDetectionDataFromCSV(csvDetectionPath) then
    begin
      StatusDetection := 'Données de détection chargées';
      WriteLn('Données de détection chargées avec succès');
    end
    else
    begin
      StatusDetection := 'Prêt';
      WriteLn('Aucune donnée de détection trouvée ou erreur de chargement');
    end;
    // ========================================================================

    // NOUVEAU: Mise à jour du statut
    TypeCarteActive := tcChargee;
    NomCarteCourante := carteName;
    MessageSauvegarde := '';

    AfficherGrille := true;
    ShowCartesSelector := false;

    WriteLn('Carte chargée avec succès: ' + carteName);

  except
    on E: Exception do
    begin
      WriteLn('Erreur lors du chargement de la carte: ' + E.Message);
      lacarte.Acharger := false;
      TypeCarteActive := tcAucune;
      NomCarteCourante := '';
      MessageSauvegarde := 'Erreur lors du chargement';
    end;
  end;
end;

procedure SetHexOrientation(NewOrientation: THexOrientation);
begin
  if HexOrientation <> NewOrientation then
  begin
    HexOrientation := NewOrientation;
    OrientationChecked := (HexOrientation = hoPointyTop);
    RecalculerDimensionsHex;
  end;
end;

procedure SaveOrientationToParams;
begin
end;

procedure LoadOrientationFromParams;
begin
end;

procedure RecalculerDimensionsHex;
begin
  HexRadius := (HexDiameter * HexScale) / 2;

  case HexOrientation of
    hoFlatTop:
    begin
      HexHeight := sqrt(3) * HexRadius;
      HexWidth := 2 * HexRadius;
    end;
    hoPointyTop:
    begin
      HexHeight := 2 * HexRadius;
      HexWidth := sqrt(3) * HexRadius;
    end;
  end;

  decalageRayon := 3 * HexScale;
end;

procedure AppliquerEchelle(NouvelleEchelle: Single);
begin
  if (NouvelleEchelle >= 0.5) and (NouvelleEchelle <= 2.0) then
  begin
    HexScale := NouvelleEchelle;
    RecalculerDimensionsHex;
  end;
end;

procedure ModifierDecalage(DeltaX, DeltaY: Single);
begin
  GridOffsetX := GridOffsetX + DeltaX;
  GridOffsetY := GridOffsetY + DeltaY;
end;

procedure SauvegarderParametresAjustement(NomFichier: string);
var
  F: TextFile;
  FS: TFormatSettings;
  DeltaRelativeX, DeltaRelativeY: Single;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  // CORRECTION: Calculer le delta relatif par rapport à la position de la carte
  DeltaRelativeX := Hex1ReferenceX - lacarte.position.x;
  DeltaRelativeY := Hex1ReferenceY - lacarte.position.y;

  AssignFile(F, PChar(nomfichier));
  Rewrite(F);
  try
    Writeln(F, 'HexDiameter=', FormatFloat('0.00', HexDiameter, FS));
    Writeln(F, 'HexScale=', FormatFloat('0.00', HexScale, FS));
    Writeln(F, 'HexOrientation=', Ord(HexOrientation));
    Writeln(F, 'CoinIn=', BoolToStr(CoinIn, True));
    Writeln(F, 'DeltaRelativeX=', FormatFloat('0.00', DeltaRelativeX, FS));
    Writeln(F, 'DeltaRelativeY=', FormatFloat('0.00', DeltaRelativeY, FS));
    // Sauvegarder les dimensions de grille
    Writeln(F, 'Columns=', IntToStr(columns));
    Writeln(F, 'Rows=', IntToStr(rows));
  finally
    CloseFile(F);
  end;
end;

procedure ChargerParametresAjustement(NomFichier: string);
var
  F: TextFile;
  ligne: string;
  posEgal: Integer;
  cle, valeurStr: string;
  valeur: Extended;
  FS: TFormatSettings;
  DeltaRelativeX, DeltaRelativeY: Single;
  CoinInValue: Boolean;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  // Valeurs par défaut
  DeltaRelativeX := 50.0;
  DeltaRelativeY := 50.0;
  CoinInValue := False;

  if FileExists(PChar(nomfichier)) then
  begin
    AssignFile(F, PChar(nomfichier));
    Reset(F);
    try
      while not Eof(F) do
      begin
        Readln(F, ligne);
        posEgal := Pos('=', ligne);
        if posEgal > 0 then
        begin
          cle := Copy(ligne, 1, posEgal - 1);
          valeurStr := Copy(ligne, posEgal + 1, Length(ligne) - posEgal);

          try
            if cle = 'HexDiameter' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              HexDiameter := valeur;
            end
            else if cle = 'HexScale' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              HexScale := valeur;
            end
            else if cle = 'HexOrientation' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              if Trunc(valeur) = 1 then
                SetHexOrientation(hoPointyTop)
              else
                SetHexOrientation(hoFlatTop);
            end
            else if cle = 'CoinIn' then
            begin
              CoinInValue := (valeurStr = 'True') or (valeurStr = '-1');
              CoinIn := CoinInValue;
            end
            else if cle = 'DeltaRelativeX' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              DeltaRelativeX := valeur;
            end
            else if cle = 'DeltaRelativeY' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              DeltaRelativeY := valeur;
            end
            // Charger les dimensions de grille
            else if cle = 'Columns' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              columns := Trunc(valeur);
              colonnesText := IntToStr(columns);
            end
            else if cle = 'Rows' then
            begin
              valeur := StrToFloat(valeurStr, FS);
              rows := Trunc(valeur);
              lignesText := IntToStr(rows);
            end;
          except
            on E: Exception do
              TraceLog(LOG_WARNING, PChar('Erreur lors de la conversion de ' + cle + ': ' + E.Message));
          end;
        end;
      end;

      // CORRECTION: Recalculer la position absolue à partir du delta relatif
      // Note: lacarte.position vaut (0,0) au moment du chargement
      Hex1ReferenceX := lacarte.position.x + DeltaRelativeX;
      Hex1ReferenceY := lacarte.position.y + DeltaRelativeY;
      CoinInChecked := CoinIn;

      RecalculerDimensionsHex;

    finally
      CloseFile(F);
    end;
  end
  else
  begin
    TraceLog(LOG_INFO, PChar('Fichier ' + nomfichier + ' introuvable'));
    // Valeurs par défaut si fichier inexistant
    Hex1ReferenceX := lacarte.position.x + DeltaRelativeX;
    Hex1ReferenceY := lacarte.position.y + DeltaRelativeY;
  end;
end;

initialization
  RecalculerDimensionsHex;
  RecalculerTotalHex;
  SetLength(HexGrid, TotalNbreHex + 1);
  StrPCopy(colonnesBuffer, colonnesText);
  StrPCopy(lignesBuffer, lignesText);
end.
