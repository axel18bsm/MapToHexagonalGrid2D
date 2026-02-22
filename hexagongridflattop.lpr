program hexagongridflattop;

{$mode objfpc}{$H+}

uses
  raylib,
  math,SysUtils,initvariable,BoutonClic,traceastar,raygui, HexagonLogic,
DetectionLogic;

var
  i: Integer;
  ButtonChargerCarte: TButtonAxel;
  ButtonImporterCarte: TButtonAxel;
  ButtonGenererGrille: TButtonAxel;    // NOUVEAU
  CheckboxAfficherGrille: TRectangle;
  CheckboxCoinIn: TRectangle;          // NOUVEAU
  TextBoxColonnes: TRectangle;         // NOUVEAU
  TextBoxLignes: TRectangle;           // NOUVEAU
  ButtonSauverCarte: TButtonAxel;    // NOUVEAU
   ButtonDetection:TButtonAxel;


// Trouve le côté de hex1 qui touche hex2 (retourne 1-6, ou 0 si non adjacents)
function TrouverAreteCommuneEntreVoisins(hex1, hex2: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to 6 do
  begin
    if HexGrid[hex1].Neighbors[i] = hex2 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

// Retourne le côté opposé (1<->4, 2<->5, 3<->6)
function CoteOppose(cote: Integer): Integer;
begin
  case cote of
    1: Result := 4;
    2: Result := 5;
    3: Result := 6;
    4: Result := 1;
    5: Result := 2;
    6: Result := 3;
  else
    Result := 0;
  end;
end;
// =============================================================================
// FICHIER 7: creationbouttons() COMPLÈTE MODIFIÉE
// EMPLACEMENT: hexagongridflattop.lpr, remplacer la fonction existante (ligne ~58)
// ACTION: REMPLACER TOUTE LA FONCTION par cette version
// =============================================================================

procedure creationbouttons;
begin
  // =================== BOUTONS PRINCIPAUX ===================
  ButtonSave := CreateButton(windowWidth - PanelWidth + 50, 60, 200, 40, DARKBLUE, SKYBLUE, RED);
  ButtonChargerCarte := CreateButton(windowWidth - PanelWidth + 50, 110, 200, 40, DARKGREEN, GREEN, RED);
  ButtonImporterCarte := CreateButton(windowWidth - PanelWidth + 50, 160, 200, 40, PURPLE, VIOLET, RED);
  ButtonSauverCarte := CreateButton(windowWidth - PanelWidth + 50, 210, 200, 40, BROWN, ORANGE, RED);
  ButtonGenererGrille := CreateButton(windowWidth - PanelWidth + 50, 260, 200, 40, ORANGE, YELLOW, RED);

  // =================== CHECKBOXES ORIENTATION / AFFICHAGE ===================
  CheckboxOrientation.x := windowWidth - PanelWidth + 50;
  CheckboxOrientation.y := 320;
  CheckboxOrientation.width := 20;
  CheckboxOrientation.height := 20;

  CheckboxNumbers.x := windowWidth - PanelWidth + 150;
  CheckboxNumbers.y := 320;
  CheckboxNumbers.width := 20;
  CheckboxNumbers.height := 20;

  CheckboxAfficherGrille.x := windowWidth - PanelWidth + 50;
  CheckboxAfficherGrille.y := 350;
  CheckboxAfficherGrille.width := 20;
  CheckboxAfficherGrille.height := 20;

  CheckboxCoinIn.x := windowWidth - PanelWidth + 50;
  CheckboxCoinIn.y := 380;
  CheckboxCoinIn.width := 20;
  CheckboxCoinIn.height := 20;

  // =================== TEXTBOXES POUR GRILLE ===================
  TextBoxColonnes.x := windowWidth - PanelWidth + 50;
  TextBoxColonnes.y := 425;
  TextBoxColonnes.width := 80;
  TextBoxColonnes.height := 25;

  TextBoxLignes.x := windowWidth - PanelWidth + 140;
  TextBoxLignes.y := 425;
  TextBoxLignes.width := 80;
  TextBoxLignes.height := 25;

  // =================== TOGGLE GROUP PRINCIPAL (6 modes de base) ===================
  ToggleGroupAppMode.x := windowWidth - PanelWidth + 50;
  ToggleGroupAppMode.y := 465;
  ToggleGroupAppMode.width := 40;   // Largeur réduite pour 6 boutons côte à côte
  ToggleGroupAppMode.height := 25;

  // =================== TOGGLE GROUP MODE AVANCÉ (InfR + Voies) ===================
  // Positionné juste en dessous du toggle principal (465 + 25 + 5 = 495)
  ToggleGroupModeAvance.x := windowWidth - PanelWidth + 50;
  ToggleGroupModeAvance.y := 495;
  ToggleGroupModeAvance.width := 100;  // 2 boutons : InfR + Voies
  ToggleGroupModeAvance.height := 25;

  // =================== BOUTON DÉTECTION (MODE DÉTECTION) ===================
  // Y=545 (décalé +35 par rapport à l'ancienne position 510)
  ButtonDetection := CreateButton(windowWidth - PanelWidth + 50, 545, 200, 30, MAGENTA, RED, MAROON);

  // =================== SPINNER CORRECTION (MODE DÉTECTION) ===================
  // Y=600 (décalé +35 par rapport à l'ancienne position 565)
  SpinnerCorrection.x := windowWidth - PanelWidth + 50;
  SpinnerCorrection.y := 600;
  SpinnerCorrection.width := 100;
  SpinnerCorrection.height := 25;

  // =================== TOGGLE GROUP SUPPRESSION (MODE SUPPRESSION) ===================
  // Y=650 (décalé +35 par rapport à l'ancienne position 615)
  ToggleGroupSuppression.x := windowWidth - PanelWidth + 50;
  ToggleGroupSuppression.y := 650;
  ToggleGroupSuppression.width := 100;
  ToggleGroupSuppression.height := 25;

  // =================== SPINNER OBJET (MODE ITEM) ===================
  // Y=560 (décalé +35 par rapport à l'ancienne position 525)
  SpinnerObjet.x := windowWidth - PanelWidth + 50;
  SpinnerObjet.y := 560;
  SpinnerObjet.width := 100;
  SpinnerObjet.height := 25;

  // =================== SPINNER RIVIÈRE (MODE RIVIÈRE) ===================
  // Y=555 (décalé +35 par rapport à l'ancienne position 520)
  SpinnerRiviere.x := windowWidth - PanelWidth + 50;
  SpinnerRiviere.y := 555;
  SpinnerRiviere.width := 100;
  SpinnerRiviere.height := 25;

  // =================== SPINNER HAUTEUR (MODE HAUTEUR) ===================
  // Y=555 (décalé +35 par rapport à l'ancienne position 520)
  SpinnerHauteur.x := windowWidth - PanelWidth + 50;
  SpinnerHauteur.y := 555;
  SpinnerHauteur.width := 100;
  SpinnerHauteur.height := 25;

  // =================== CHECKBOXES VOIES (MODE VOIES) ===================
  // 4 checkboxes conditionnelles, affichées uniquement en mode amVoies
  // Espacées de 23px verticalement pour être lisibles dans le panneau

  // Voie1 : sentier, 2px, DARKGRAY
  CheckboxVoie1.x := windowWidth - PanelWidth + 50;
  CheckboxVoie1.y := 545;
  CheckboxVoie1.width := 20;
  CheckboxVoie1.height := 20;

  // Voie2 : route, 4px, BLUE
  CheckboxVoie2.x := windowWidth - PanelWidth + 50;
  CheckboxVoie2.y := 568;
  CheckboxVoie2.width := 20;
  CheckboxVoie2.height := 20;

  // Voie3 : nationale, 6px, YELLOW
  CheckboxVoie3.x := windowWidth - PanelWidth + 50;
  CheckboxVoie3.y := 591;
  CheckboxVoie3.width := 20;
  CheckboxVoie3.height := 20;

  // Voie4 : chemin de fer, 8px, RED
  CheckboxVoie4.x := windowWidth - PanelWidth + 50;
  CheckboxVoie4.y := 614;
  CheckboxVoie4.width := 20;
  CheckboxVoie4.height := 20;

end;

// =============================================================================
// RÉSUMÉ DES MODIFICATIONS:
// 1. ToggleGroupAppMode.width réduit de 80 → 40 (pour afficher 6 modes)
// 2. Ajout du SpinnerHauteur (position Y=520, même que SpinnerRiviere)
// 3. Tous les autres éléments restent inchangés
// =============================================================================

procedure DrawImportSelector;
var
  selectorRect: TRectangle;
  listRect: TRectangle;
  closeButtonRect: TRectangle;
  buttonY: Single;
  buttonHeight: Single;
  i: Integer;
begin
  if not ShowImportSelector then Exit;

  DrawRectangle(0, 0, WindowWidth, WindowHeight, ColorAlpha(BLACK, 0.5));

  selectorRect.x := WindowWidth / 4;
  selectorRect.y := WindowHeight / 4;
  selectorRect.width := WindowWidth / 2;
  selectorRect.height := WindowHeight / 2;

  GuiPanel(selectorRect, 'Importer une carte');

  closeButtonRect.x := selectorRect.x + selectorRect.width - 30;
  closeButtonRect.y := selectorRect.y + 5;
  closeButtonRect.width := 25;
  closeButtonRect.height := 25;

  if GuiButton(closeButtonRect, 'X') > 0 then
  begin
    ShowImportSelector := false;
  end;

  if GuiButton(RectangleCreate(selectorRect.x + 10, selectorRect.y + 40, 150, 30), 'Actualiser la liste') > 0 then
  begin
    ScanCartesRessources;
  end;

  if ImportListInitialized and (Length(ImportList) > 0) then
  begin
    listRect.x := selectorRect.x + 10;
    listRect.y := selectorRect.y + 80;
    listRect.width := selectorRect.width - 20;
    listRect.height := selectorRect.height - 100;

    buttonHeight := 30;
    buttonY := listRect.y;

    for i := 0 to High(ImportList) do
    begin
      if (buttonY + buttonHeight) > (listRect.y + listRect.height) then
        break;

      if GuiButton(RectangleCreate(listRect.x, buttonY, listRect.width, buttonHeight),
                   PChar(ImportList[i])) > 0 then
      begin
        LoadCarteImport(ImportList[i]);
      end;

      buttonY := buttonY + buttonHeight + 5;
    end;
  end
  else if ImportListInitialized then
  begin
    DrawText('Aucune image trouvée dans le répertoire ressources/',
             Round(selectorRect.x + 10), Round(selectorRect.y + 80), 20, DARKGRAY);
  end;
end;

procedure DrawCartesSelector;
var
  selectorRect: TRectangle;
  listRect: TRectangle;
  closeButtonRect: TRectangle;
  buttonY: Single;
  buttonHeight: Single;
  i: Integer;
begin
  if not ShowCartesSelector then Exit;

  DrawRectangle(0, 0, WindowWidth, WindowHeight, ColorAlpha(BLACK, 0.5));

  selectorRect.x := WindowWidth / 4;
  selectorRect.y := WindowHeight / 4;
  selectorRect.width := WindowWidth / 2;
  selectorRect.height := WindowHeight / 2;

  GuiPanel(selectorRect, 'Sélectionner une carte');

  closeButtonRect.x := selectorRect.x + selectorRect.width - 30;
  closeButtonRect.y := selectorRect.y + 5;
  closeButtonRect.width := 25;
  closeButtonRect.height := 25;

  if GuiButton(closeButtonRect, 'X') > 0 then
  begin
    ShowCartesSelector := false;
  end;

  if GuiButton(RectangleCreate(selectorRect.x + 10, selectorRect.y + 40, 150, 30), 'Actualiser la liste') > 0 then
  begin
    ScanCartesDisponibles;
  end;

  if CartesListInitialized and (Length(CartesList) > 0) then
  begin
    listRect.x := selectorRect.x + 10;
    listRect.y := selectorRect.y + 80;
    listRect.width := selectorRect.width - 20;
    listRect.height := selectorRect.height - 100;

    buttonHeight := 30;
    buttonY := listRect.y;

    for i := 0 to High(CartesList) do
    begin
      if (buttonY + buttonHeight) > (listRect.y + listRect.height) then
        break;

      if GuiButton(RectangleCreate(listRect.x, buttonY, listRect.width, buttonHeight), PChar(CartesList[i])) > 0 then
      begin
        LoadCarteComplete(CartesList[i]);
      end;

      buttonY := buttonY + buttonHeight + 5;
    end;
  end
  else if CartesListInitialized then
  begin
    DrawText('Aucune carte trouvée dans le répertoire ./save/',
             Round(selectorRect.x + 10), Round(selectorRect.y + 80), 20, DARKGRAY);
  end;
end;

procedure Chargelacarte();
begin
  with lacarte do
  begin
    id := 1;
    nom := 'Waterloo';
    Fileimage := 'ressources/carte2v.png';
    Position := Vector2Create(0, 0);

    limage := LoadImage(Fileimage);
    lacarte := LoadTextureFromImage(limage);
  end;
end;

procedure RegenerateurGrille;
begin
  RecalculerDimensionsHex;
  GenerateHexagons;
  CalculateNeighbors;
  //InitialiserHauteurs;
end;

// =============================================================================
// FICHIER 8: DrawGUIPanel() COMPLÈTE MODIFIÉE
// EMPLACEMENT: hexagongridflattop.lpr, remplacer la fonction existante (ligne ~298)
// ACTION: REMPLACER TOUTE LA FONCTION par cette version
// =============================================================================

procedure DrawGUIPanel();
var
  panelRect: TRectangle;
  orientationText: string;
  wasChecked: Boolean;
  oldAppModeIndex: Integer;
  oldAppModeAvanceIndex: Integer;
  dialogRect: TRectangle;
  dialogResult: Integer;
  oldSuppressionModeIndex: Integer;
  valeurCourante: Integer;        // Pour afficher la valeur décimale Voies courante
begin
  panelRect.x := windowWidth - PanelWidth;
  panelRect.y := 0;
  panelRect.width := PanelWidth;
  panelRect.height := windowHeight - InfoBoxHeight;

  GuiPanel(panelRect, 'Commandes');

  // =================== BOUTONS PRINCIPAUX ===================
  if GuiButton(ButtonSave.Rect, 'Sauve les coord Hex') = 1 then
  begin
    SaveHexGridToCSV;
    ButtonSave.IsClicked := True;
  end;

  if GuiButton(ButtonChargerCarte.Rect, 'Charger une carte') = 1 then
  begin
    ShowCartesSelector := true;
    ScanCartesDisponibles;
  end;

  if GuiButton(ButtonImporterCarte.Rect, 'Importer carte') = 1 then
  begin
    ShowImportSelector := true;
    ScanCartesRessources;
  end;

  if GuiButton(ButtonSauverCarte.Rect, 'Sauver carte') = 1 then
  begin
    SauvegarderCarteUniverselle;
  end;

  if GuiButton(ButtonGenererGrille.Rect, 'Générer grille') = 1 then
  begin
    if AppliquerParametresGrille then
      GenererNouvelleGrille;
  end;

  // =================== CHECKBOXES ORIENTATION / AFFICHAGE ===================
  wasChecked := OrientationChecked;
  GuiCheckBox(CheckboxOrientation, 'Pointy Top', @OrientationChecked);

  if OrientationChecked <> wasChecked then
  begin
    if OrientationChecked then
      SetHexOrientation(hoPointyTop)
    else
      SetHexOrientation(hoFlatTop);
    RegenerateurGrille;
  end;

  GuiCheckBox(CheckboxNumbers, 'Numbers', @AfficherNumeros);
  GuiCheckBox(CheckboxAfficherGrille, 'Afficher grille', @AfficherGrille);
  GuiCheckBox(CheckboxCoinIn, 'CoinIn', @CoinInChecked);

  // =================== TEXTBOXES COLONNES / LIGNES ===================
  if GuivalueBox(TextBoxColonnes, '', @columns, 2, 100, editingColonnes) <> 0 then
    editingColonnes := not editingColonnes;
  if GuivalueBox(TextBoxLignes, '', @rows, 2, 100, editingLignes) <> 0 then
    editingLignes := not editingLignes;

  // =================== LABELS FIXES ===================
  DrawText('Colonnes:', windowWidth - PanelWidth + 50, 410, 12, DARKGRAY);
  DrawText('Lignes:',   windowWidth - PanelWidth + 140, 410, 12, DARKGRAY);
  DrawText('Mode:',     windowWidth - PanelWidth + 50, 450, 12, DARKGRAY);
  DrawText('Avancé:',   windowWidth - PanelWidth + 50, 483, 10, DARKGRAY);

  // =================== TOGGLE GROUP PRINCIPAL (6 modes de base) ===================
  oldAppModeIndex := AppModeIndex;
  GuiToggleGroup(ToggleGroupAppMode,
    'Normal;Détection;Suppression;Item;Riviere;Hauteur', @AppModeIndex);

  if AppModeIndex <> oldAppModeIndex then
  begin
    // Désélectionner le 2ème toggle (exclusion mutuelle)
    AppModeAvanceIndex := -1;
    // Réinitialiser les sources en attente
    HexInfRSource := 0;
    HexVoiesSource := 0;
    case AppModeIndex of
      0: AppMode := amNormal;
      1: AppMode := amDetection;
      2: AppMode := amSuppression;
      3: AppMode := amObjet;
      4: AppMode := amRiviere;
      5: AppMode := amHauteur;
    end;
  end;

  // =================== TOGGLE GROUP MODE AVANCÉ (InfR + Voies) ===================
  oldAppModeAvanceIndex := AppModeAvanceIndex;
  GuiToggleGroup(ToggleGroupModeAvance, 'InfR;Voies', @AppModeAvanceIndex);

  if AppModeAvanceIndex <> oldAppModeAvanceIndex then
  begin
    // Désélectionner le 1er toggle (exclusion mutuelle)
    AppModeIndex := -1;
    // Réinitialiser les sources en attente
    HexInfRSource := 0;
    HexVoiesSource := 0;
    case AppModeAvanceIndex of
      0: AppMode := amInfR;
      1: AppMode := amVoies;
    end;
  end;

  // =================== INTERFACE DÉTECTION ===================
  if AppMode = amDetection then
  begin
    DrawText('Status:', windowWidth - PanelWidth + 50, 530, 12, DARKGRAY);
    DrawText(PChar(GetDetectionStatus()),
             windowWidth - PanelWidth + 95, 530, 14, DARKBLUE);

    if DetectionActive then
    begin
      if GuiButton(ButtonDetection.Rect, 'Terminer sélection') = 1 then
        StopReferenceSelection;
    end
    else
    begin
      if GuiButton(ButtonDetection.Rect, 'Commencer sélection') = 1 then
      begin
        if NombreReferences > 0 then
          ShowResetDialog := True
        else
          StartReferenceSelection;
      end;
    end;

    if NombreReferences > 0 then
    begin
      DrawText('Modification du terrain:',
               windowWidth - PanelWidth + 50, 580, 12, DARKGRAY);

      if ValeurSpinnerCorrection > NombreReferences then
        ValeurSpinnerCorrection := NombreReferences;
      if ValeurSpinnerCorrection < 1 then
        ValeurSpinnerCorrection := 1;

      GuiSpinner(SpinnerCorrection, '', @ValeurSpinnerCorrection,
                 1, NombreReferences, False);

      DrawText(PChar('Type: ' + IntToStr(ValeurSpinnerCorrection)),
               windowWidth - PanelWidth + 160, 595, 12, DARKGREEN);
    end;
  end;

  // =================== INTERFACE SUPPRESSION ===================
  if AppMode = amSuppression then
  begin
    DrawText('Mode suppression actif:',
             windowWidth - PanelWidth + 50, 530, 14, RED);

    oldSuppressionModeIndex := AppModeSuppressionIndex;
    GuiToggleGroup(ToggleGroupSuppression,
                   'Suppression;Exemption', @AppModeSuppressionIndex);

    case AppModeSuppressionIndex of
      0:
      begin
        DrawText('Action: Supprimer/Restaurer',
                 windowWidth - PanelWidth + 50, 685, 14, RED);
        DrawText('1er clic: Supprime + croix rouge',
                 windowWidth - PanelWidth + 50, 705, 12, DARKGRAY);
        DrawText('2ème clic: Restaure hexagone',
                 windowWidth - PanelWidth + 50, 720, 12, DARKGRAY);
      end;
      1:
      begin
        DrawText('Action: Exemption',
                 windowWidth - PanelWidth + 50, 685, 14, ORANGE);
        DrawText('1er clic: Exempte + O rouge',
                 windowWidth - PanelWidth + 50, 705, 12, DARKGRAY);
        DrawText('2ème clic: Restaure',
                 windowWidth - PanelWidth + 50, 720, 12, DARKGRAY);
      end;
    end;

    DrawText('Cliquez sur un hexagone',
             windowWidth - PanelWidth + 50, 740, 12, DARKBLUE);
  end;

  // =================== INTERFACE ITEM ===================
  if AppMode = amObjet then
  begin
    DrawText('Mode Item actif:', windowWidth - PanelWidth + 50, 530, 14, BLUE);

    GuiSpinner(SpinnerObjet, '', @ValeurSpinnerObjet, 1, 10, False);

    DrawText(PChar('Item: ' + IntToStr(ValeurSpinnerObjet)),
             windowWidth - PanelWidth + 160, 550, 12, DARKBLUE);

    DrawText('1er clic: Place rond rouge',
             windowWidth - PanelWidth + 50, 585, 12, DARKGRAY);
    DrawText('2ème clic: Supprime le rond',
             windowWidth - PanelWidth + 50, 600, 12, DARKGRAY);
    DrawText('Note: cumul possible sur un hex',
             windowWidth - PanelWidth + 50, 625, 11, DARKGRAY);
  end;

  // =================== INTERFACE RIVIÈRE ===================
  if AppMode = amRiviere then
  begin
    DrawText('Mode Rivière actif:',
             windowWidth - PanelWidth + 50, 530, 14, RED);

    GuiSpinner(SpinnerRiviere, '', @ValeurSpinnerRiviere, 0, 10, False);

    DrawText(PChar('Type: riv' + IntToStr(ValeurSpinnerRiviere)),
             windowWidth - PanelWidth + 160, 550, 12, DARKGRAY);

    DrawText('1er clic: Sélectionne hex source',
             windowWidth - PanelWidth + 50, 585, 12, DARKGRAY);
    DrawText('2ème clic: Hex adjacent',
             windowWidth - PanelWidth + 50, 600, 12, DARKGRAY);
    DrawText('  → Trace trait rouge',
             windowWidth - PanelWidth + 50, 615, 12, DARKGRAY);
    DrawText('Re-clic: Supprime le trait',
             windowWidth - PanelWidth + 50, 635, 12, DARKGRAY);
  end;

  // =================== INTERFACE HAUTEUR ===================
  if AppMode = amHauteur then
  begin
    DrawText('Mode Hauteur actif:',
             windowWidth - PanelWidth + 50, 530, 14, DARKGREEN);

    GuiSpinner(SpinnerHauteur, '', @ValeurSpinnerHauteur, -2, 10, False);

    DrawText(PChar('Hauteur: ' + IntToStr(ValeurSpinnerHauteur)),
             windowWidth - PanelWidth + 160, 550, 12, DARKBLUE);

    DrawText('Cliquez sur un hexagone',
             windowWidth - PanelWidth + 50, 585, 12, DARKGRAY);
    DrawText('  → Applique la hauteur',
             windowWidth - PanelWidth + 50, 600, 12, DARKGRAY);
    DrawText('Hauteur 0 = terrain plat',
             windowWidth - PanelWidth + 50, 625, 11, DARKGRAY);
  end;

  // =================== INTERFACE InfR ===================
  if AppMode = amInfR then
  begin
    DrawText('Mode InfR actif:',
             windowWidth - PanelWidth + 50, 530, 14, MAROON);

    DrawText('1er clic: Sélectionne hex source',
             windowWidth - PanelWidth + 50, 558, 12, DARKGRAY);
    DrawText('2ème clic: Hex adjacent',
             windowWidth - PanelWidth + 50, 573, 12, DARKGRAY);
    DrawText('  → Trait marron (ep.5)',
             windowWidth - PanelWidth + 50, 588, 12, DARKGRAY);
    DrawText('Re-clic même paire: Supprime',
             windowWidth - PanelWidth + 50, 608, 12, DARKGRAY);

    // Affichage dynamique de la source en attente
    if HexInfRSource > 0 then
      DrawText(PChar('Source: hex #' + IntToStr(HexInfRSource)),
               windowWidth - PanelWidth + 50, 633, 13, MAROON)
    else
      DrawText('Source: aucune',
               windowWidth - PanelWidth + 50, 633, 13, DARKGRAY);
  end;

  // =================== INTERFACE VOIES ===================
  if AppMode = amVoies then
  begin
    DrawText('Mode Voies actif:',
             windowWidth - PanelWidth + 50, 530, 14, DARKBLUE);

    DrawText('Voies à appliquer:',
             windowWidth - PanelWidth + 50, 553, 12, DARKGRAY);

    // --- Checkbox Voie1 : sentier, 2px, DARKGRAY ---
    GuiCheckBox(CheckboxVoie1, 'Voie1-sentier  2px', @CheckVoie1);

    // --- Checkbox Voie2 : route, 4px, BLUE ---
    GuiCheckBox(CheckboxVoie2, 'Voie2-route    4px', @CheckVoie2);

    // --- Checkbox Voie3 : nationale, 6px, YELLOW ---
    GuiCheckBox(CheckboxVoie3, 'Voie3-nationale 6px', @CheckVoie3);

    // --- Checkbox Voie4 : chemin de fer, 8px, RED ---
    GuiCheckBox(CheckboxVoie4, 'Voie4-fer      8px', @CheckVoie4);

    // --- Affichage de la valeur décimale courante ---
    valeurCourante := ValeurVoiesCochees;
    if valeurCourante > 0 then
      DrawText(PChar('Valeur: ' + IntToStr(valeurCourante)),
               windowWidth - PanelWidth + 50, 638, 13, DARKBLUE)
    else
      DrawText('Valeur: 0 (aucune voie)',
               windowWidth - PanelWidth + 50, 638, 13, DARKGRAY);

    DrawText('1er clic: Sélectionne hex source',
             windowWidth - PanelWidth + 50, 658, 12, DARKGRAY);
    DrawText('2ème clic: Hex adjacent',
             windowWidth - PanelWidth + 50, 673, 12, DARKGRAY);
    DrawText('  → Pose les voies cochées',
             windowWidth - PanelWidth + 50, 688, 12, DARKGRAY);
    DrawText('Re-clic même paire: Remet à 0',
             windowWidth - PanelWidth + 50, 708, 12, DARKGRAY);

    // Affichage dynamique de la source en attente
    if HexVoiesSource > 0 then
      DrawText(PChar('Source: hex #' + IntToStr(HexVoiesSource)),
               windowWidth - PanelWidth + 50, 728, 13, DARKBLUE)
    else
      DrawText('Source: aucune',
               windowWidth - PanelWidth + 50, 728, 13, DARKGRAY);
  end;

  // =================== INFORMATIONS GÉNÉRALES ===================
  if HexOrientation = hoFlatTop then
    orientationText := 'Mode: Flat Top'
  else
    orientationText := 'Mode: Pointy Top';
  DrawText(PChar(orientationText),
           windowWidth - PanelWidth + 50, 760, 16, DARKGRAY);

  if NomCarteImportee <> '' then
    DrawText(PChar('Carte: ' + NomCarteImportee + ' (importée)'),
             windowWidth - PanelWidth + 50, 782, 14, PURPLE)
  else
    DrawText(PChar('Carte: ' + lacarte.nom),
             windowWidth - PanelWidth + 50, 782, 14, DARKBLUE);

  DrawText(PChar('Grille: ' + IntToStr(columns) + 'x' + IntToStr(rows) +
           ' (' + IntToStr(TotalNbreHex) + ' hex)'),
           windowWidth - PanelWidth + 50, 802, 14, DARKGREEN);

  // =================== MODE ACTUEL ===================
  case AppMode of
    amNormal:
      DrawText('Mode actuel: Normal',
               windowWidth - PanelWidth + 50, 822, 14, DARKGREEN);
    amDetection:
      DrawText('Mode actuel: Détection',
               windowWidth - PanelWidth + 50, 822, 14, ORANGE);
    amSuppression:
    begin
      case AppModeSuppressionIndex of
        0: DrawText('Mode actuel: Suppression',
                    windowWidth - PanelWidth + 50, 822, 14, RED);
        1: DrawText('Mode actuel: Exemption',
                    windowWidth - PanelWidth + 50, 822, 14, ORANGE);
      end;
    end;
    amObjet:
      DrawText('Mode actuel: Item',
               windowWidth - PanelWidth + 50, 822, 14, BLUE);
    amRiviere:
      DrawText('Mode actuel: Rivière',
               windowWidth - PanelWidth + 50, 822, 14, RED);
    amHauteur:
      DrawText('Mode actuel: Hauteur',
               windowWidth - PanelWidth + 50, 822, 14, DARKGREEN);
    amInfR:
      DrawText('Mode actuel: InfR',
               windowWidth - PanelWidth + 50, 822, 14, MAROON);
    amVoies:
      DrawText('Mode actuel: Voies',
               windowWidth - PanelWidth + 50, 822, 14, DARKBLUE);
  end;

  // =================== MESSAGEBOX RÉINITIALISATION DÉTECTION ===================
  if ShowResetDialog then
  begin
    dialogRect.x := (WindowWidth - 400) / 2;
    dialogRect.y := (WindowHeight - 200) / 2;
    dialogRect.width := 400;
    dialogRect.height := 200;

    dialogResult := GuiMessageBox(dialogRect,
                                  'Nouvelle détection',
                                  'Une détection existe déjà.#Voulez-vous tout réinitialiser ?',
                                  'Oui;Non');

    if dialogResult = 1 then
    begin
      ResetDetectionComplete;
      StartReferenceSelection;
      ShowResetDialog := False;
    end
    else if dialogResult = 0 then
    begin
      ShowResetDialog := False;
    end;
  end;
end;

// =============================================================================
// RÉSUMÉ DES MODIFICATIONS:
// 1. ToggleGroup: Ajout de ";Hauteur" (6 modes au total)
// 2. Case statement: Ajout de "5: AppMode := amHauteur;"
// 3. Interface Hauteur: Section complète avec spinner (0-99) et instructions
// 4. Affichage mode actuel: Ajout de "amHauteur: DrawText..."
// =============================================================================

procedure DrawHexagon2(hex: THexCell);
var
  i: Integer;
  angle: Float;
  point1, point2: TVector2;
begin
  for i := 0 to 5 do
  begin
    angle := Pi / 3 * i;
    point1.x := hex.Center.X + Round(cos(angle) * hexRadius);
    point1.y := hex.center.Y + Round(sin(angle) * hexRadius);
    point2.x := hex.center.X + Round(cos(angle + Pi / 3) * hexRadius);
    point2.y := hex.center.Y + Round(sin(angle + Pi / 3) * hexRadius);

    DrawLineV(point1, point2, DARKGRAY);
  end;

  DrawText(PChar(IntToStr(hex.Number)), round(hex.center.X) - 10, round(hex.center.Y) - 10, 20, BLACK);
end;

procedure HandleMouseClic();
var
  mouseX, mouseY: integer;
  dx, dy: single;
  dist: single;
  currentMousePos: TVector2;
  deltaX, deltaY: Single;
  dragDistance: Single;
begin
  currentMousePos := GetMousePosition();

  if IsMouseButtonPressed(MOUSE_LEFT_BUTTON) then
  begin
    if (currentMousePos.x < windowWidth - PanelWidth) and
       (currentMousePos.y < windowHeight - InfoBoxHeight) then
    begin
      DragStartPos := currentMousePos;
      DragStartOffsetX := GridOffsetX;
      DragStartOffsetY := GridOffsetY;
      MouseStartOffsetX := MouseOffsetX;
      MouseStartOffsetY := MouseOffsetY;
      IsDragging := False;
    end;
  end;

  if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then
  begin
    deltaX := currentMousePos.x - DragStartPos.x;
    deltaY := currentMousePos.y - DragStartPos.y;
    dragDistance := sqrt(deltaX * deltaX + deltaY * deltaY);

    if (dragDistance > MinDragDistance) and
       (currentMousePos.x < windowWidth - PanelWidth) then
    begin
      IsDragging := True;

      GridOffsetX := DragStartOffsetX + deltaX;
      GridOffsetY := DragStartOffsetY + deltaY;
      MouseOffsetX := MouseStartOffsetX + deltaX;
      MouseOffsetY := MouseStartOffsetY + deltaY;
    end;
  end;

  if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then
  begin
    if not IsDragging then
    begin
      mouseX := GetMouseX();
      mouseY := GetMouseY();
      HexSelected := False;
      MousePosition := Vector2Create(mouseX, mouseY);

      if (mouseX < windowWidth - PanelWidth) and
         (mouseY < windowHeight - InfoBoxHeight) then
      begin
        // CORRIGÉ: Utilise maintenant TotalNbreHex variable !
        for i := 1 to TotalNbreHex do
        begin
          dx := mouseX - HexGrid[i].Center.x - MouseOffsetX;
          dy := mouseY - HexGrid[i].Center.y - MouseOffsetY;
          dist := sqrt(dx * dx + dy * dy);

          if dist <= HexRadius - decalageRayon then
          begin
            HexGrid[i].Selected := True;
            SelectedHex := HexGrid[i];
            HexSelected := True;
          end
          else
            HexGrid[i].Selected := False;
        end;
      end;
    end;

    IsDragging := False;
  end;
end;
    procedure DrawHexGrid(dessineLesNombres: boolean);
var
  hexNumberText: array[0..5] of char;
  outlineColor: TColor;
  rotationAngle: single;
  showNumbers: boolean;
  j, voisin: Integer;
  epaisseur: Single;
  centre1, centre2: TVector2;
  valVoie: Integer;
begin
  case HexOrientation of
    hoFlatTop:   rotationAngle := 0;
    hoPointyTop: rotationAngle := 30;
  end;

  showNumbers := dessineLesNombres and (AppMode <> amDetection);

  // =================== DESSIN DES HEXAGONES ===================
  for i := 1 to TotalNbreHex do
  begin
    case AppMode of
      amNormal, amDetection:
      begin
        if HexGrid[i].Supprime then Continue;
      end;

      amSuppression:
      begin
        // Afficher tous les hexagones (supprimés inclus)
      end;

      amObjet, amRiviere, amHauteur, amInfR, amVoies:
      begin
        if HexGrid[i].Supprime then Continue;
      end;
    end;

    if lacarte.grilletransparente = False then
    begin
      DrawPoly(Vector2Create(HexGrid[i].Center.x, HexGrid[i].Center.y),
               6, HexRadius, rotationAngle, HexGrid[i].Color);

      if HexGrid[i].Selected then
        outlineColor := GREEN
      else
        outlineColor := raywhite;
    end;

    if (AppMode = amDetection) and (HexGrid[i].IsReference > 0) then
      outlineColor := RED
    else if (AppMode = amSuppression) and HexGrid[i].Supprime then
      outlineColor := RED
    else if (AppMode = amRiviere) and (i = HexRiviereSource) then
      outlineColor := ORANGE
    else if (AppMode = amInfR) and (i = HexInfRSource) then
      outlineColor := ORANGE
    else if (AppMode = amVoies) and (i = HexVoiesSource) then
      outlineColor := SKYBLUE
    else
      outlineColor := ORANGE;

    DrawPolyLinesEx(Vector2Create(HexGrid[I].Center.x, HexGrid[I].Center.y),
                    6, HexRadius, rotationAngle, 2, outlineColor);

    if showNumbers and not HexGrid[i].Supprime then
    begin
      StrPCopy(hexNumberText, IntToStr(HexGrid[I].Number));
      DrawText(hexNumberText,
               Round(HexGrid[I].Center.x - 5),
               Round(HexGrid[I].Center.y - 10),
               20, BLACK);
    end;

    // =================== AFFICHAGES SPÉCIFIQUES PAR MODE ===================

    if (AppMode = amDetection) and not HexGrid[i].Supprime then
    begin
      if HexGrid[i].IsReference > 0 then
      begin
        StrPCopy(hexNumberText, IntToStr(HexGrid[i].IsReference));
        DrawText(hexNumberText,
                 Round(HexGrid[I].Center.x - 8),
                 Round(HexGrid[I].Center.y - 12),
                 24, RED);
      end
      else if HexGrid[i].TypeTerrain > 0 then
      begin
        StrPCopy(hexNumberText, IntToStr(HexGrid[i].TypeTerrain));
        DrawText(hexNumberText,
                 Round(HexGrid[I].Center.x - 8),
                 Round(HexGrid[I].Center.y - 12),
                 20, GREEN);
      end;
    end;

    if (AppMode = amSuppression) and HexGrid[i].Supprime then
    begin
      DrawText('X',
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               24, RED);
    end;

    if (AppMode = amSuppression) and HexGrid[i].Exempt then
    begin
      DrawText('O',
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               24, RED);
    end;

    if (AppMode = amObjet) and HexGrid[i].Objets[ValeurSpinnerObjet] then
    begin
      DrawCircle(Round(HexGrid[I].Center.x),
                 Round(HexGrid[I].Center.y),
                 5, RED);
    end;

    if (AppMode = amHauteur) and not HexGrid[i].Supprime then
    begin
      StrPCopy(hexNumberText, IntToStr(HexGrid[i].Hauteur));
      DrawText(hexNumberText,
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               20, RED);
    end;

    // MODE InfR : cercle marron sur le hex source en attente
    if (AppMode = amInfR) and (i = HexInfRSource) then
    begin
      DrawCircle(Round(HexGrid[i].Center.x),
                 Round(HexGrid[i].Center.y),
                 6, BROWN);
    end;

    // MODE VOIES : cercle bleu sur le hex source en attente
    if (AppMode = amVoies) and (i = HexVoiesSource) then
    begin
      DrawCircle(Round(HexGrid[i].Center.x),
                 Round(HexGrid[i].Center.y),
                 6, DARKBLUE);
    end;

  end; // fin boucle hexagones

  // =================== DESSIN DES RIVIÈRES (MODE RIVIÈRE) ===================
  if AppMode = amRiviere then
  begin
    for i := 1 to TotalNbreHex do
    begin
      if HexGrid[i].Supprime then Continue;

      for j := 1 to 6 do
      begin
        if HexGrid[i].Edges[j] > 0 then
        begin
          voisin := HexGrid[i].Neighbors[j];
          if (voisin > 0) and (voisin <= TotalNbreHex) then
          begin
            if i < voisin then
            begin
              epaisseur := HexGrid[i].Edges[j];
              DrawLineEx(HexGrid[i].Center, HexGrid[voisin].Center,
                         epaisseur, RED);
            end;
          end;
        end;
      end;
    end;
  end;

  // =================== DESSIN DES InfR (MODE InfR) ===================
  if AppMode = amInfR then
  begin
    for i := 1 to TotalNbreHex do
    begin
      if HexGrid[i].Supprime then Continue;

      for j := 1 to 6 do
      begin
        if HexGrid[i].InfR[j] > 0 then
        begin
          voisin := HexGrid[i].Neighbors[j];
          if (voisin > 0) and (voisin <= TotalNbreHex) then
          begin
            if i < voisin then
              DrawLineEx(HexGrid[i].Center, HexGrid[voisin].Center,
                         5, BROWN);
          end;
        end;
      end;
    end;
  end;

  // =================== DESSIN DES VOIES (MODE VOIES) ===================
  // Chaque lien est INDÉPENDANT : on lit uniquement la valeur stockée
  // dans HexGrid[i].Voies[j] pour décider quoi dessiner.
  // Les checkboxes ne servent QU'À COMPOSER la valeur lors du clic (HandleDragAndDrop).
  // Elles n'ont AUCUN effet sur l'affichage ici → pas de bug global.
  if AppMode = amVoies then
  begin
    for i := 1 to TotalNbreHex do
    begin
      if HexGrid[i].Supprime then Continue;

      for j := 1 to 6 do
      begin
        if HexGrid[i].Voies[j] > 0 then
        begin
          voisin := HexGrid[i].Neighbors[j];
          if (voisin > 0) and (voisin <= TotalNbreHex) then
          begin
            if i < voisin then
            begin
              centre1 := HexGrid[i].Center;
              centre2 := HexGrid[voisin].Center;
              valVoie := HexGrid[i].Voies[j];

              // --- COUCHE 1 : Voie4 (chemin de fer) 8px ROUGE ---
              // Dessinée en premier car plus large → sert de bordure
              // On lit uniquement la valeur stockée, pas les checkboxes
              if (valVoie div 1000) mod 10 = 1 then
                DrawLineEx(centre1, centre2, 4 * VoieEpaisseur, RED);

              // --- COUCHE 2 : Voie3 (nationale) 6px JAUNE ---
              // Par-dessus le rouge → bordure rouge visible sur les bords
              if (valVoie div 100) mod 10 = 1 then
                DrawLineEx(centre1, centre2, 3 * VoieEpaisseur, YELLOW);

              // --- COUCHE 3 : Voie2 (route) 4px BLEU ---
              if (valVoie div 10) mod 10 = 1 then
                DrawLineEx(centre1, centre2, 2 * VoieEpaisseur, BLUE);

              // --- COUCHE 4 : Voie1 (sentier) 2px BLANC ---
              // Dessinée en dernier → visible au centre de toutes les couches
              if (valVoie mod 10) = 1 then
                DrawLineEx(centre1, centre2, 1 * VoieEpaisseur, WHITE);

            end;
          end;
        end;
      end;
    end;
  end;

end;
//// =============================================================================
// FICHIER 10: DrawHexGrid() COMPLÈTE MODIFIÉE
// EMPLACEMENT: hexagongridflattop.lpr, remplacer la fonction existante (ligne ~671)
// ACTION: REMPLACER TOUTE LA FONCTION par cette version
// =============================================================================



    // MODE SUPPRESSION : X pour hexagones supprimés

// =============================================================================
// RÉSUMÉ DES MODIFICATIONS:
// 1. Ajout du case "amHauteur:" dans la gestion de visibilité
// 2. Nouvelle section d'affichage pour le mode Hauteur:
//    - Affiche le chiffre de hauteur (HexGrid[i].Hauteur)
//    - Couleur DARKGREEN pour bien le distinguer
//    - Taille 20 pour lisibilité
//    - Positionné au centre de l'hexagone
// 3. N'affiche pas les hauteurs pour les hexagones supprimés
// =============================================================================

procedure HandleKeyboardAdjustments;
var
  needsRegeneration: Boolean;
begin
  needsRegeneration := False;

  if IsKeyPressed(KEY_RIGHT) then
  begin
    Hex1ReferenceX := Hex1ReferenceX + 1;
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_LEFT) then
  begin
    Hex1ReferenceX := Hex1ReferenceX - 1;
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_DOWN) then
  begin
    Hex1ReferenceY := Hex1ReferenceY + 1;
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_UP) then
  begin
    Hex1ReferenceY := Hex1ReferenceY - 1;
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_KP_ADD) or IsKeyPressed(KEY_EQUAL) then
  begin
    AppliquerEchelle(HexScale + 0.001);
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_KP_SUBTRACT) or IsKeyPressed(KEY_MINUS) then
  begin
    AppliquerEchelle(HexScale - 0.001);
    needsRegeneration := True;
  end;

  if IsKeyPressed(KEY_S) then
  begin
    SauvegarderParametresAjustement('ajustements.txt');
    TraceLog(LOG_INFO, 'Paramètres d''ajustement sauvegardés');
  end;

  if IsKeyPressed(KEY_L) and IsKeyDown(KEY_LEFT_CONTROL) then
  begin
    ChargerParametresAjustement('ajustements.txt');
    needsRegeneration := True;
    TraceLog(LOG_INFO, 'Paramètres d''ajustement chargés');
  end;

  if IsKeyPressed(KEY_R) and IsKeyDown(KEY_LEFT_CONTROL) then
  begin
    HexDiameter := 70.67;
    HexScale := 1.0;
    Hex1ReferenceX := 50.0;
    Hex1ReferenceY := 50.0;
    needsRegeneration := True;
    TraceLog(LOG_INFO, 'Paramètres réinitialisés');
  end;

  if needsRegeneration then
  begin
    RegenerateurGrille;
  end;
end;

procedure DrawHexInfoBox();
var
  InfoRect: TRectangle;
  TextBuffer: array[0..511] of Char;
  YPos: Integer;
  LineHeight: Integer;
  ColorText: string;
begin
  InfoRect.x := 0;
  InfoRect.y := WindowHeight - InfoBoxHeight;
  InfoRect.width := WindowWidth;
  InfoRect.height := InfoBoxHeight;

  DrawRectangleRec(InfoRect, LIGHTGRAY);
  DrawRectangleLinesEx(InfoRect, 2, DARKGRAY);

  StrPCopy(TextBuffer, 'Colonnes: ');
  DrawText(TextBuffer, 511, 13, 12, BLACK);

  StrPCopy(TextBuffer, IntToStr(columns));
  DrawText(TextBuffer, 576, 13, 14, BLACK);

  YPos := WindowHeight - InfoBoxHeight + 10;
  LineHeight := 20;

  StrPCopy(TextBuffer, Format('Échelle: %.3f | Décalage X: %.0f | Décalage Y: %.0f',
    [HexScale, GridOffsetX, GridOffsetY]));
  DrawText(TextBuffer, WindowWidth - 400, YPos, 16, DARKGRAY);

  if HexSelected then
  begin
    YPos := WindowHeight - InfoBoxHeight + 20;

    if (SelectedHex.Color.r = GREEN.r) and (SelectedHex.Color.g = GREEN.g) and (SelectedHex.Color.b = GREEN.b) then
      ColorText := 'Vert'
    else if (SelectedHex.Color.r = LIGHTGRAY.r) and (SelectedHex.Color.g = LIGHTGRAY.g) and (SelectedHex.Color.b = LIGHTGRAY.b) then
      ColorText := 'Gris clair'
    else
      ColorText := Format('RGB(%d,%d,%d)', [SelectedHex.Color.r, SelectedHex.Color.g, SelectedHex.Color.b]);

    StrPCopy(TextBuffer, Format('Hexagone #%d | Position: L%d C%d | Centre: (%.0f, %.0f)',
      [SelectedHex.Number, SelectedHex.Ligne, SelectedHex.Colonne,
       SelectedHex.Center.x, SelectedHex.Center.y]));
    DrawText(TextBuffer, 20, YPos, 18, BLACK);

    Inc(YPos, LineHeight);
    StrPCopy(TextBuffer, Format('Couleur: %s | Emplacement: %s',
      [ColorText, EmplacementToString(SelectedHex.Poshexagone)]));
    DrawText(TextBuffer, 20, YPos, 18, BLACK);

    Inc(YPos, LineHeight);
    StrPCopy(TextBuffer, Format('Voisins: [%d] [%d] [%d] [%d] [%d] [%d]',
      [SelectedHex.Neighbors[1], SelectedHex.Neighbors[2], SelectedHex.Neighbors[3],
       SelectedHex.Neighbors[4], SelectedHex.Neighbors[5], SelectedHex.Neighbors[6]]));
    DrawText(TextBuffer, 20, YPos, 18, BLACK);

    Inc(YPos, LineHeight);
    StrPCopy(TextBuffer, Format('Couleur carte: RGB(%d,%d,%d)',
      [SelectedHex.ColorPt.r, SelectedHex.ColorPt.g, SelectedHex.ColorPt.b]));
    DrawText(TextBuffer, 20, YPos, 18, BLACK);

    // NOUVEAU: Affichage des informations de détection
    if AppMode = amDetection then
    begin
      Inc(YPos, LineHeight);
      if SelectedHex.IsReference > 0 then
        StrPCopy(TextBuffer, Format('RÉFÉRENCE #%d | Type terrain: %d',
          [SelectedHex.IsReference, SelectedHex.TypeTerrain]))
      else if SelectedHex.TypeTerrain > 0 then
        StrPCopy(TextBuffer, Format('Type terrain: %d (classifié)',
          [SelectedHex.TypeTerrain]))
      else
        StrPCopy(TextBuffer, 'Type terrain: 0 (non déterminé)');

      DrawText(TextBuffer, 20, YPos, 18, DARKBLUE);
    end;
  end
  else
  begin
    StrPCopy(TextBuffer, 'Aucun hexagone sélectionné. Cliquez sur un hexagone pour voir ses informations.');
    DrawText(TextBuffer, 20, WindowHeight - InfoBoxHeight + 40, 20, BLACK);
  end;

  YPos := WindowHeight - 30;
  StrPCopy(TextBuffer, 'Flèches: Déplacer | +/-: Zoom | Ctrl+S: Sauver | Ctrl+L: Charger | Ctrl+R: Réinitialiser');
  DrawText(TextBuffer, 20, YPos, 14, DARKGRAY);

  if MessageSauvegarde <> '' then
  begin
    YPos := WindowHeight - 50;
    StrPCopy(TextBuffer, PChar(MessageSauvegarde));
    DrawText(TextBuffer, 20, YPos, 16, DARKGREEN);
  end;
end;
     // =============================================================================
// FONCTION COMPLÈTE: RestaurerVoisinageHexagone() dans hexagongridflattop.lpr
// =============================================================================

procedure RestaurerVoisinageHexagone(hexNumber: Integer);
var
  i, j, k: Integer;
  nombreSupprime: Integer;
begin
  WriteLn('=== DÉBUT RESTAURATION COMPLÈTE DES VOISINAGES ===');
  WriteLn('Hexagone restauré: #' + IntToStr(hexNumber));

  // Compter les hexagones supprimés pour info
  nombreSupprime := 0;
  for i := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Supprime then
      Inc(nombreSupprime);
  end;
  WriteLn('Hexagones encore supprimés: ' + IntToStr(nombreSupprime));

  // ÉTAPE 1: Recalculer TOUS les voisinages depuis zéro
  WriteLn('Étape 1: Recalcul complet des voisinages...');
  CalculateNeighbors;
  WriteLn('Recalcul terminé');

  // ÉTAPE 2: Nettoyer les voisinages des hexagones supprimés
  WriteLn('Étape 2: Nettoyage des hexagones supprimés...');

  for i := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Supprime then
    begin
      // Vider tous ses voisins
      for j := 1 to 6 do
      begin
        if HexGrid[i].Neighbors[j] <> 0 then
        begin
          WriteLn('  Suppression voisin[' + IntToStr(j) + '] = ' + IntToStr(HexGrid[i].Neighbors[j]) + ' pour hex #' + IntToStr(i));
          HexGrid[i].Neighbors[j] := 0;
        end;
      end;

      // Supprimer toutes les références à cet hexagone dans les autres hexagones
      for j := 1 to TotalNbreHex do
      begin
        if not HexGrid[j].Supprime then  // Seulement dans les hexagones actifs
        begin
          for k := 1 to 6 do
          begin
            if HexGrid[j].Neighbors[k] = i then
            begin
              WriteLn('  Suppression référence à #' + IntToStr(i) + ' dans hex #' + IntToStr(j) + ' voisin[' + IntToStr(k) + ']');
              HexGrid[j].Neighbors[k] := 0;
            end;
          end;
        end;
      end;
    end;
  end;

  WriteLn('Nettoyage terminé');

  // ÉTAPE 3: Vérification et statistiques finales
  WriteLn('Étape 3: Vérification...');

  nombreSupprime := 0;
  for i := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Supprime then
      Inc(nombreSupprime);
  end;

  WriteLn('Statistiques finales:');
  WriteLn('- Hexagones supprimés restants: ' + IntToStr(nombreSupprime));
  WriteLn('- Hexagones actifs: ' + IntToStr(TotalNbreHex - nombreSupprime));
  WriteLn('- Hexagone #' + IntToStr(hexNumber) + ' restauré avec succès');

  WriteLn('=== FIN RESTAURATION COMPLÈTE ===');
  WriteLn('');
end;
/// =============================================================================
// FONCTION MODIFIÉE: HandleDragAndDrop
// AJOUT: Gestion du clic dans le mode Item (amObjet)
// =============================================================================

// =============================================================================
// REMPLACER HandleDragAndDrop() dans hexagongridflattop.lpr (ligne ~1037)
// =============================================================================

// =============================================================================
// FICHIER 9: HandleDragAndDrop() COMPLÈTE MODIFIÉE
// EMPLACEMENT: hexagongridflattop.lpr, remplacer la fonction existante (ligne ~1077)
// ACTION: REMPLACER TOUTE LA FONCTION par cette version
// =============================================================================

procedure HandleDragAndDrop();
var
  mousePos: TVector2;
  deltaX, deltaY: Single;
  distance: Single;
  mouseX, mouseY: integer;
  dx, dy: single;
  dist: single;
  i, j, k: Integer;
  ancienVoisin: Integer;
  newHex1RefX, newHex1RefY: Single;
  deltaRefX, deltaRefY: Single;
  coteSource, coteDest: Integer;
  valeurVoies: Integer;           // valeur décimale positionnelle à stocker
begin
  mousePos := GetMousePosition();

  // =================== GESTION DU DÉBUT DU DRAG ===================
  if IsMouseButtonPressed(MOUSE_LEFT_BUTTON) then
  begin
    if (mousePos.x < windowWidth - PanelWidth) and
       (mousePos.y < windowHeight - InfoBoxHeight) then
    begin
      DragStartPos    := mousePos;
      MouseStartOffsetX := Hex1ReferenceX;
      MouseStartOffsetY := Hex1ReferenceY;
      DragStartOffsetX  := lacarte.position.x;
      DragStartOffsetY  := lacarte.position.y;
      IsDragging := False;
    end;
  end;

  // =================== GESTION DU DRAG EN COURS ===================
  if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then
  begin
    deltaX   := mousePos.x - DragStartPos.x;
    deltaY   := mousePos.y - DragStartPos.y;
    distance := sqrt(deltaX * deltaX + deltaY * deltaY);

    if (distance > MinDragDistance) and
       (mousePos.x < windowWidth - PanelWidth) then
    begin
      IsDragging := True;

      newHex1RefX := MouseStartOffsetX + deltaX;
      newHex1RefY := MouseStartOffsetY + deltaY;

      deltaRefX := newHex1RefX - Hex1ReferenceX;
      deltaRefY := newHex1RefY - Hex1ReferenceY;

      if (abs(deltaRefX) > 0.1) or (abs(deltaRefY) > 0.1) then
      begin
        for i := 1 to TotalNbreHex do
        begin
          HexGrid[i].center.X := HexGrid[i].center.X + deltaRefX;
          HexGrid[i].center.Y := HexGrid[i].center.Y + deltaRefY;

          for j := 0 to 5 do
          begin
            HexGrid[i].Vertices[j].x := HexGrid[i].Vertices[j].x + Round(deltaRefX);
            HexGrid[i].Vertices[j].y := HexGrid[i].Vertices[j].y + Round(deltaRefY);
          end;
        end;
      end;

      Hex1ReferenceX        := newHex1RefX;
      Hex1ReferenceY        := newHex1RefY;
      lacarte.position.x    := DragStartOffsetX + deltaX;
      lacarte.position.y    := DragStartOffsetY + deltaY;
    end;
  end;

  // =================== GESTION DE LA FIN DU DRAG (CLIC OU DROP) ===================
  if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then
  begin
    if IsDragging then
    begin
      // C'était un DRAG : régénérer la grille après déplacement
      RegenerateurGrille;
      WriteLn('Régénération après glisser-déposer terminée');
    end
    else
    begin
      // C'était un CLIC simple
      mouseX := GetMouseX();
      mouseY := GetMouseY();

      if (mouseX < windowWidth - PanelWidth) and
         (mouseY < windowHeight - InfoBoxHeight) then
      begin
        for i := 1 to TotalNbreHex do
        begin
          dx   := mouseX - HexGrid[i].Center.x;
          dy   := mouseY - HexGrid[i].Center.y;
          dist := sqrt(dx * dx + dy * dy);

          if dist <= HexRadius - decalageRayon then
          begin
            // =================== GESTION DES CLICS PAR MODE ===================
            case AppMode of

              // =================== MODE NORMAL ===================
              amNormal:
              begin
                for j := 1 to TotalNbreHex do
                  HexGrid[j].Selected := False;
                HexGrid[i].Selected := True;
                SelectedHex := HexGrid[i];
                HexSelected := True;
              end;

              // =================== MODE DÉTECTION ===================
              amDetection:
              begin
                if DetectionActive then
                begin
                  HandleDetectionClick(i);
                  WriteLn('Mode sélection référence - Hexagone #' + IntToStr(i));
                end
                else if NombreReferences > 0 then
                begin
                  HexGrid[i].TypeTerrain := ValeurSpinnerCorrection;
                  WriteLn('Hexagone #' + IntToStr(i) + ' corrigé vers type '
                    + IntToStr(ValeurSpinnerCorrection));
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end
                else
                begin
                  WriteLn('Aucune référence disponible pour la correction');
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end;
              end;

              // =================== MODE SUPPRESSION ===================
              amSuppression:
              begin
                case AppModeSuppressionIndex of
                  0: // Suppression / Restauration
                  begin
                    if HexGrid[i].Supprime = False then
                    begin
                      WriteLn('Suppression hexagone #' + IntToStr(i));
                      HexGrid[i].Supprime := True;

                      for j := 1 to 6 do
                      begin
                        ancienVoisin := HexGrid[i].Neighbors[j];
                        if ancienVoisin > 0 then
                          for k := 1 to 6 do
                            if HexGrid[ancienVoisin].Neighbors[k] = i then
                            begin
                              HexGrid[ancienVoisin].Neighbors[k] := 0;
                              WriteLn('  Supprimé référence dans hex #'
                                + IntToStr(ancienVoisin)
                                + ' voisin[' + IntToStr(k) + ']');
                            end;
                      end;

                      for j := 1 to 6 do
                        HexGrid[i].Neighbors[j] := 0;

                      WriteLn('Hexagone #' + IntToStr(i) + ' supprimé logiquement');
                    end
                    else
                    begin
                      WriteLn('Restauration hexagone #' + IntToStr(i));
                      HexGrid[i].Supprime := False;
                      RestaurerVoisinageHexagone(i);
                      WriteLn('Hexagone #' + IntToStr(i) + ' restauré');
                    end;

                    for j := 1 to TotalNbreHex do
                      HexGrid[j].Selected := False;
                    HexGrid[i].Selected := True;
                    SelectedHex := HexGrid[i];
                    HexSelected := True;
                  end;

                  1: // Exemption / Restauration exemption
                  begin
                    if HexGrid[i].Exempt = False then
                    begin
                      WriteLn('Exemption hexagone #' + IntToStr(i));
                      ExempterHexagone(i);
                    end
                    else
                    begin
                      WriteLn('Restauration exemption hexagone #' + IntToStr(i));
                      RestaurerHexagoneExempt(i);
                    end;

                    for j := 1 to TotalNbreHex do
                      HexGrid[j].Selected := False;
                    HexGrid[i].Selected := True;
                    SelectedHex := HexGrid[i];
                    HexSelected := True;
                  end;
                end;
              end;

              // =================== MODE OBJET/ITEM ===================
              amObjet:
              begin
                HexGrid[i].Objets[ValeurSpinnerObjet] :=
                  not HexGrid[i].Objets[ValeurSpinnerObjet];

                if HexGrid[i].Objets[ValeurSpinnerObjet] then
                  WriteLn('Item ' + IntToStr(ValeurSpinnerObjet)
                    + ' placé sur hex #' + IntToStr(i))
                else
                  WriteLn('Item ' + IntToStr(ValeurSpinnerObjet)
                    + ' supprimé de hex #' + IntToStr(i));

                for j := 1 to TotalNbreHex do
                  HexGrid[j].Selected := False;
                HexGrid[i].Selected := True;
                SelectedHex := HexGrid[i];
                HexSelected := True;
              end;

              // =================== MODE RIVIÈRE ===================
              amRiviere:
              begin
                if HexRiviereSource = 0 then
                begin
                  // PREMIER CLIC : mémoriser la source
                  HexRiviereSource := i;
                  WriteLn('Riviere: Source #' + IntToStr(i));
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end
                else
                begin
                  // DEUXIÈME CLIC : placer ou supprimer
                  coteSource := TrouverAreteCommuneEntreVoisins(HexRiviereSource, i);

                  if coteSource > 0 then
                  begin
                    coteDest := CoteOppose(coteSource);

                    if HexGrid[HexRiviereSource].Edges[coteSource] > 0 then
                    begin
                      HexGrid[HexRiviereSource].Edges[coteSource] := 0;
                      HexGrid[i].Edges[coteDest] := 0;
                      WriteLn('Riviere supprimee entre #'
                        + IntToStr(HexRiviereSource) + ' et #' + IntToStr(i));
                    end
                    else
                    begin
                      HexGrid[HexRiviereSource].Edges[coteSource] := ValeurSpinnerRiviere;
                      HexGrid[i].Edges[coteDest] := ValeurSpinnerRiviere;
                      WriteLn('Riviere type ' + IntToStr(ValeurSpinnerRiviere)
                        + ' entre #' + IntToStr(HexRiviereSource)
                        + ' et #' + IntToStr(i));
                    end;
                  end
                  else
                    WriteLn('ERREUR: hex #' + IntToStr(HexRiviereSource)
                      + ' et #' + IntToStr(i) + ' non adjacents');

                  HexRiviereSource := 0;
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end;
              end;

              // =================== MODE HAUTEUR ===================
              amHauteur:
              begin
                HexGrid[i].Hauteur := ValeurSpinnerHauteur;
                WriteLn('Hauteur ' + IntToStr(ValeurSpinnerHauteur)
                  + ' appliquée à hex #' + IntToStr(i));
                for j := 1 to TotalNbreHex do
                  HexGrid[j].Selected := False;
                HexGrid[i].Selected := True;
                SelectedHex := HexGrid[i];
                HexSelected := True;
              end;

              // =================== MODE InfR ===================
              amInfR:
              begin
                if HexInfRSource = 0 then
                begin
                  // PREMIER CLIC : mémoriser la source
                  HexInfRSource := i;
                  WriteLn('InfR: Source #' + IntToStr(i));
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end
                else
                begin
                  // DEUXIÈME CLIC : placer ou supprimer le lien infranchissable
                  coteSource := TrouverAreteCommuneEntreVoisins(HexInfRSource, i);

                  if coteSource > 0 then
                  begin
                    coteDest := CoteOppose(coteSource);

                    if HexGrid[HexInfRSource].InfR[coteSource] > 0 then
                    begin
                      // Lien existant → SUPPRESSION
                      HexGrid[HexInfRSource].InfR[coteSource] := 0;
                      HexGrid[i].InfR[coteDest] := 0;
                      WriteLn('InfR supprimé entre #'
                        + IntToStr(HexInfRSource) + ' et #' + IntToStr(i));
                    end
                    else
                    begin
                      // Pas de lien → CRÉATION (valeur fixe 5)
                      HexGrid[HexInfRSource].InfR[coteSource] := 5;
                      HexGrid[i].InfR[coteDest] := 5;
                      WriteLn('InfR créé entre #'
                        + IntToStr(HexInfRSource) + ' et #' + IntToStr(i));
                    end;
                  end
                  else
                    WriteLn('InfR ERREUR: hex #' + IntToStr(HexInfRSource)
                      + ' et #' + IntToStr(i) + ' non adjacents');

                  HexInfRSource := 0;
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end;
              end;

              // =================== MODE VOIES ===================
              amVoies:
              begin
                if HexVoiesSource = 0 then
                begin
                  // ---------------------------------------------------
                  // PREMIER CLIC : mémoriser l'hexagone source
                  // Le cercle bleu au centre sera affiché par DrawHexGrid
                  // tant que HexVoiesSource <> 0
                  // ---------------------------------------------------
                  HexVoiesSource := i;
                  WriteLn('Voies: Source #' + IntToStr(i));
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end
                else
                begin
                  // ---------------------------------------------------
                  // DEUXIÈME CLIC : poser ou supprimer les voies
                  // ---------------------------------------------------
                  coteSource := TrouverAreteCommuneEntreVoisins(HexVoiesSource, i);

                  if coteSource > 0 then
                  begin
                    coteDest := CoteOppose(coteSource);

                    if HexGrid[HexVoiesSource].Voies[coteSource] > 0 then
                    begin
                      // -----------------------------------------------
                      // Des voies existent déjà sur ce côté : SUPPRESSION
                      // On remet les deux côtés à 0 (efface tout)
                      // -----------------------------------------------
                      HexGrid[HexVoiesSource].Voies[coteSource] := 0;
                      HexGrid[i].Voies[coteDest] := 0;
                      WriteLn('Voies supprimées entre #'
                        + IntToStr(HexVoiesSource) + ' et #' + IntToStr(i));
                    end
                    else
                    begin
                      // -----------------------------------------------
                      // Aucune voie : CRÉATION
                      // Calculer la valeur décimale selon cases cochées
                      // ex: voie1+voie3 cochées → valeurVoies = 101
                      // -----------------------------------------------
                      valeurVoies := ValeurVoiesCochees;

                      if valeurVoies > 0 then
                      begin
                        // Stocker la même valeur sur les deux côtés
                        HexGrid[HexVoiesSource].Voies[coteSource] := valeurVoies;
                        HexGrid[i].Voies[coteDest] := valeurVoies;
                        WriteLn('Voies ' + IntToStr(valeurVoies)
                          + ' créées entre #' + IntToStr(HexVoiesSource)
                          + ' (côté ' + IntToStr(coteSource) + ')'
                          + ' et #' + IntToStr(i)
                          + ' (côté ' + IntToStr(coteDest) + ')');
                      end
                      else
                      begin
                        // Aucune checkbox cochée → rien à poser
                        WriteLn('Voies: aucune voie sélectionnée (cochez au moins une case)');
                      end;
                    end;
                  end
                  else
                    WriteLn('Voies ERREUR: hex #' + IntToStr(HexVoiesSource)
                      + ' et #' + IntToStr(i) + ' non adjacents');

                  // Réinitialiser la source dans tous les cas
                  HexVoiesSource := 0;
                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end;
              end;

            end; // fin case AppMode

            Break; // Hexagone trouvé, sortir de la boucle de détection
          end;
        end; // fin boucle détection hexagone
      end;
    end;

    IsDragging := False;
  end;
end;

// =============================================================================
// RÉSUMÉ DES MODIFICATIONS:
// - Ajout du case "amHauteur:" dans le switch principal
// - Simple application de la valeur du spinner à l'hexagone cliqué
// - Mise à jour de la sélection visuelle
// - Message de log confirmant l'application
// =============================================================================

procedure DrawMap();
begin
  if lacarte.Acharger = true then
  begin
    DrawTextureV(lacarte.lacarte, lacarte.position, WHITE);
  end;
end;

// Programme principal
begin
  InitWindow(windowWidth, windowHeight, 'Hexagonal Grid - Flat Top (Ajustable)');
  SetTargetFPS(60);

  InitCarteLoader;
  InitImportSystem;
  InitDetectionSystem;

  lacarte.Acharger := true;
  lacarte.grilletransparente := true;

  ChargerParametresAjustement('ajustements.txt');

  If lacarte.Acharger = false then Chargelacarte();
  GenerateHexagons;
  calculateNeighbors();
  CreationBouttons;
  //if faitAstar = false then AStarPathfinding(3,36);

  while not WindowShouldClose() do
  begin
    HandleKeyboardAdjustments();

    if (not ShowCartesSelector) and (not ShowImportSelector) then
      HandleDragAndDrop();

    BeginDrawing();
    ClearBackground(RAYWHITE);

    DrawMap();

     if AfficherGrille then
      DrawHexGrid(AfficherNumeros);  // MODIFIÉ: utilise la variable checkbox au lieu de true


    DrawGUIPanel();
    DrawHexInfoBox();
    DrawCartesSelector();
    DrawImportSelector();

    EndDrawing();
  end;

  if lacarte.lacarte.id > 0 then
  begin
    UnloadTexture(lacarte.lacarte);
    UnloadImage(lacarte.limage);
  end;

  CloseWindow();
end.
