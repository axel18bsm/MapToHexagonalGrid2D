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

  // =================== CHECKBOXES ===================
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

  // =================== TOGGLE GROUP PRINCIPAL ===================
  // ⭐ MODIFIÉ: Largeur réduite de 80 → 40 pour accueillir 6 modes
  ToggleGroupAppMode.x := windowWidth - PanelWidth + 50;
  ToggleGroupAppMode.y := 465;
  ToggleGroupAppMode.width := 40;  // ⭐ Largeur réduite pour 6 boutons
  ToggleGroupAppMode.height := 25;

  // =================== BOUTON DÉTECTION ===================
  ButtonDetection := CreateButton(windowWidth - PanelWidth + 50, 510, 200, 30, MAGENTA, RED, MAROON);

  // =================== SPINNER CORRECTION (MODE DÉTECTION) ===================
  SpinnerCorrection.x := windowWidth - PanelWidth + 50;
  SpinnerCorrection.y := 565;
  SpinnerCorrection.width := 100;
  SpinnerCorrection.height := 25;

  // =================== TOGGLE GROUP SUPPRESSION ===================
  ToggleGroupSuppression.x := windowWidth - PanelWidth + 50;
  ToggleGroupSuppression.y := 615;
  ToggleGroupSuppression.width := 100;
  ToggleGroupSuppression.height := 25;

  // =================== SPINNER OBJET (MODE ITEM) ===================
  SpinnerObjet.x := windowWidth - PanelWidth + 50;
  SpinnerObjet.y := 525;
  SpinnerObjet.width := 100;
  SpinnerObjet.height := 25;

  // =================== SPINNER RIVIÈRE (MODE RIVIÈRE) ===================
  SpinnerRiviere.x := windowWidth - PanelWidth + 50;
  SpinnerRiviere.y := 520;
  SpinnerRiviere.width := 100;
  SpinnerRiviere.height := 25;

  // =================== ⭐ NOUVEAU: SPINNER HAUTEUR (MODE HAUTEUR) ===================
  SpinnerHauteur.x := windowWidth - PanelWidth + 50;
  SpinnerHauteur.y := 520;
  SpinnerHauteur.width := 100;
  SpinnerHauteur.height := 25;
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
  dialogRect: TRectangle;
  dialogResult: Integer;
  oldSuppressionModeIndex: Integer;
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
    begin
      GenererNouvelleGrille;
    end;
  end;

  // =================== CHECKBOXES ===================
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

  // =================== TEXTBOXES ===================
  if GuivalueBox(TextBoxColonnes, '',@columns ,2,100, editingColonnes)<>0 then editingColonnes:=NOT editingColonnes;
  if GuivalueBox(TextBoxLignes, '', @rows, 2,100,editingLignes)<>0 then editingLignes:=NOT editingLignes;

  // =================== TOGGLE GROUP PRINCIPAL ===================
  // ⭐ MODIFIÉ: 6 modes (ajout de Hauteur)
  oldAppModeIndex := AppModeIndex;
  GuiToggleGroup(ToggleGroupAppMode, 'Normal;Détection;Suppression;Item;Riviere;Hauteur', @AppModeIndex);

  if AppModeIndex <> oldAppModeIndex then
  begin
    case AppModeIndex of
      0: AppMode := amNormal;
      1: AppMode := amDetection;
      2: AppMode := amSuppression;
      3: AppMode := amObjet;
      4: AppMode := amRiviere;
      5: AppMode := amHauteur;  // ⭐ NOUVEAU: case 5 = mode Hauteur
    end;
  end;

  // =================== LABELS ===================
  DrawText('Colonnes:', windowWidth - PanelWidth + 50, 410, 12, DARKGRAY);
  DrawText('Lignes:', windowWidth - PanelWidth + 140, 410, 12, DARKGRAY);
  DrawText('Mode:', windowWidth - PanelWidth + 50, 450, 12, DARKGRAY);

  // =================== INTERFACE DE DÉTECTION ===================
  if AppMode = amDetection then
  begin
    DrawText('Status:', windowWidth - PanelWidth + 50, 495, 12, DARKGRAY);
    DrawText(PChar(GetDetectionStatus()), windowWidth - PanelWidth + 95, 495, 14, DARKBLUE);

    if DetectionActive then
    begin
      if GuiButton(ButtonDetection.Rect, 'Terminer sélection') = 1 then
      begin
        StopReferenceSelection;
      end;
    end
    else
    begin
      if GuiButton(ButtonDetection.Rect, 'Commencer sélection') = 1 then
      begin
        if NombreReferences > 0 then
        begin
          ShowResetDialog := True;
        end
        else
        begin
          StartReferenceSelection;
        end;
      end;
    end;

    if NombreReferences > 0 then
    begin
      DrawText('Modification du terrain:', windowWidth - PanelWidth + 50, 545, 12, DARKGRAY);

      if ValeurSpinnerCorrection > NombreReferences then
        ValeurSpinnerCorrection := NombreReferences;
      if ValeurSpinnerCorrection < 1 then
        ValeurSpinnerCorrection := 1;

      GuiSpinner(SpinnerCorrection, '', @ValeurSpinnerCorrection, 1, NombreReferences, False);

      DrawText(PChar('Type: ' + IntToStr(ValeurSpinnerCorrection)),
               windowWidth - PanelWidth + 160, 560, 12, DARKGREEN);
    end;
  end;

  // =================== INTERFACE DE SUPPRESSION ===================
  if AppMode = amSuppression then
  begin
    DrawText('Mode suppression actif:', windowWidth - PanelWidth + 50, 595, 14, RED);

    oldSuppressionModeIndex := AppModeSuppressionIndex;
    GuiToggleGroup(ToggleGroupSuppression, 'Suppression;Exemption', @AppModeSuppressionIndex);

    case AppModeSuppressionIndex of
      0:
      begin
        DrawText('Action: Supprimer/Restaurer', windowWidth - PanelWidth + 50, 650, 14, RED);
        DrawText('1er clic: Supprime + croix rouge', windowWidth - PanelWidth + 50, 670, 12, DARKGRAY);
        DrawText('2ème clic: Restaure hexagone', windowWidth - PanelWidth + 50, 685, 12, DARKGRAY);
      end;

      1:
      begin
        DrawText('Action: Exemption', windowWidth - PanelWidth + 50, 650, 14, ORANGE);
        DrawText('1er clic: Exempte + O rouge', windowWidth - PanelWidth + 50, 670, 12, DARKGRAY);
        DrawText('2ème clic: Restaure (DUMMY)', windowWidth - PanelWidth + 50, 685, 12, DARKGRAY);
      end;
    end;

    DrawText('Cliquez sur un hexagone', windowWidth - PanelWidth + 50, 705, 12, DARKBLUE);
  end;

  // =================== INTERFACE ITEM ===================
  if AppMode = amObjet then
  begin
    DrawText('Mode Item actif:', windowWidth - PanelWidth + 50, 495, 14, BLUE);

    GuiSpinner(SpinnerObjet, '', @ValeurSpinnerObjet, 1, 10, False);

    DrawText(PChar('Item sélectionné: ' + IntToStr(ValeurSpinnerObjet)),
             windowWidth - PanelWidth + 160, 515, 12, DARKBLUE);

    DrawText('Actions:', windowWidth - PanelWidth + 50, 545, 12, DARKGRAY);
    DrawText('1er clic: Place rond rouge', windowWidth - PanelWidth + 50, 565, 12, DARKGRAY);
    DrawText('2ème clic: Supprime le rond', windowWidth - PanelWidth + 50, 580, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 595, 12, DARKGRAY);
    DrawText('Affichage:', windowWidth - PanelWidth + 50, 615, 12, DARKGRAY);
    DrawText('Uniquement items du slider actuel', windowWidth - PanelWidth + 50, 635, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 650, 12, DARKGRAY);
    DrawText('Note: Un hexagone peut avoir', windowWidth - PanelWidth + 50, 670, 11, DARKGRAY);
    DrawText('plusieurs items simultanément', windowWidth - PanelWidth + 50, 685, 11, DARKGRAY);
  end;

  // =================== INTERFACE RIVIÈRE ===================
  if AppMode = amRiviere then
  begin
    DrawText('Mode Rivière actif:', windowWidth - PanelWidth + 50, 495, 14, RED);

    GuiSpinner(SpinnerRiviere, '', @ValeurSpinnerRiviere, 0, 10, False); // 10 falaise, 1à 5 largeur riviere

    DrawText(PChar('Type: riv' + IntToStr(ValeurSpinnerRiviere)),windowWidth - PanelWidth + 160, 515, 12, DARKGRAY);

    DrawText('Instructions:', windowWidth - PanelWidth + 50, 545, 12, DARKGRAY);
    DrawText('1er clic: Sélectionne hex source', windowWidth - PanelWidth + 50, 565, 12, DARKGRAY);
    DrawText('2ème clic: Hex adjacent', windowWidth - PanelWidth + 50, 580, 12, DARKGRAY);
    DrawText('  → Trace trait rouge', windowWidth - PanelWidth + 50, 595, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 610, 12, DARKGRAY);
    DrawText('Re-clic sur paire:', windowWidth - PanelWidth + 50, 625, 12, DARKGRAY);
    DrawText('  → Supprime le trait', windowWidth - PanelWidth + 50, 640, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 655, 12, DARKGRAY);
    DrawText('Épaisseur = valeur spinner', windowWidth - PanelWidth + 50, 670, 11, DARKGRAY);
    DrawText('(1-5 pixels)', windowWidth - PanelWidth + 50, 685, 11, DARKGRAY);
  end;

  // =================== ⭐ NOUVEAU: INTERFACE HAUTEUR ===================
  if AppMode = amHauteur then
  begin
    DrawText('Mode Hauteur actif:', windowWidth - PanelWidth + 50, 495, 14, DARKGREEN);

    // Spinner pour sélectionner la hauteur (0-99)
    GuiSpinner(SpinnerHauteur, '', @ValeurSpinnerHauteur, -2, 10, False);

    DrawText(PChar('Hauteur: ' + IntToStr(ValeurSpinnerHauteur)),
             windowWidth - PanelWidth + 160, 515, 12, DARKBLUE);

    DrawText('Instructions:', windowWidth - PanelWidth + 50, 545, 12, DARKGRAY);
    DrawText('1. Sélectionnez la hauteur (0-99)', windowWidth - PanelWidth + 50, 565, 12, DARKGRAY);
    DrawText('2. Cliquez sur un hexagone', windowWidth - PanelWidth + 50, 580, 12, DARKGRAY);
    DrawText('   → Applique la hauteur', windowWidth - PanelWidth + 50, 595, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 610, 12, DARKGRAY);
    DrawText('Affichage:', windowWidth - PanelWidth + 50, 625, 12, DARKGRAY);
    DrawText('Le chiffre affiché = hauteur', windowWidth - PanelWidth + 50, 640, 12, DARKGRAY);
    DrawText('', windowWidth - PanelWidth + 50, 655, 12, DARKGRAY);
    DrawText('Hauteur 0 = terrain plat', windowWidth - PanelWidth + 50, 670, 11, DARKGRAY);
    DrawText('Hauteur 99 = montagne haute', windowWidth - PanelWidth + 50, 685, 11, DARKGRAY);
  end;

  // =================== INFORMATIONS GÉNÉRALES ===================
  if HexOrientation = hoFlatTop then
    orientationText := 'Mode: Flat Top'
  else
    orientationText := 'Mode: Pointy Top';
  DrawText(PChar(orientationText), windowWidth - PanelWidth + 50, 730, 16, DARKGRAY);

  if NomCarteImportee <> '' then
    DrawText(PChar('Carte: ' + NomCarteImportee + ' (importée)'),
             windowWidth - PanelWidth + 50, 755, 14, PURPLE)
  else
    DrawText(PChar('Carte: ' + lacarte.nom),
             windowWidth - PanelWidth + 50, 755, 14, DARKBLUE);

  DrawText(PChar('Grille: ' + IntToStr(columns) + 'x' + IntToStr(rows) + ' (' + IntToStr(TotalNbreHex) + ' hex)'),
           windowWidth - PanelWidth + 50, 775, 14, DARKGREEN);

  // ⭐ MODIFIÉ: Ajout du cas amHauteur
  case AppMode of
    amNormal: DrawText('Mode actuel: Normal', windowWidth - PanelWidth + 50, 795, 14, DARKGREEN);
    amDetection: DrawText('Mode actuel: Détection', windowWidth - PanelWidth + 50, 795, 14, ORANGE);
    amSuppression:
    begin
      case AppModeSuppressionIndex of
        0: DrawText('Mode actuel: Suppression', windowWidth - PanelWidth + 50, 795, 14, RED);
        1: DrawText('Mode actuel: Exemption', windowWidth - PanelWidth + 50, 795, 14, ORANGE);
      end;
    end;
    amObjet: DrawText('Mode actuel: Item', windowWidth - PanelWidth + 50, 795, 14, BLUE);
    amRiviere: DrawText('Mode actuel: Rivière', windowWidth - PanelWidth + 50, 795, 14, RED);
    amHauteur: DrawText('Mode actuel: Hauteur', windowWidth - PanelWidth + 50, 795, 14, DARKGREEN);  // ⭐ NOUVEAU
  end;

  // =================== MESSAGEBOX DE RÉINITIALISATION ===================
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

//// =============================================================================
// FICHIER 10: DrawHexGrid() COMPLÈTE MODIFIÉE
// EMPLACEMENT: hexagongridflattop.lpr, remplacer la fonction existante (ligne ~671)
// ACTION: REMPLACER TOUTE LA FONCTION par cette version
// =============================================================================

procedure DrawHexGrid(dessineLesNombres: boolean);
var
  hexNumberText: array[0..5] of char;
  outlineColor: TColor;
  rotationAngle: single;
  showNumbers: boolean;
  j, voisin: Integer;
  epaisseur: Single;
begin
  // Déterminer l'angle de rotation selon l'orientation
  case HexOrientation of
    hoFlatTop:   rotationAngle := 0;
    hoPointyTop: rotationAngle := 30;
  end;

  // Afficher les numéros sauf en mode Détection
  showNumbers := dessineLesNombres and (AppMode <> amDetection);

  // =================== DESSIN DES HEXAGONES ===================
  for i := 1 to TotalNbreHex do
  begin
    // Gestion de la visibilité selon le mode
    case AppMode of
      amNormal, amDetection:
      begin
        if HexGrid[i].Supprime then
          Continue;
      end;

      amSuppression:
      begin
        // En mode Suppression : afficher tous les hexagones
      end;

      amObjet:
      begin
        if HexGrid[i].Supprime then
          Continue;
      end;

      amRiviere:
      begin
        if HexGrid[i].Supprime then
          Continue;
      end;

      // ⭐ NOUVEAU: Mode Hauteur
      amHauteur:
      begin
        if HexGrid[i].Supprime then
          Continue;
      end;
    end;

    // Dessiner le polygone hexagonal si la grille n'est pas transparente
    if lacarte.grilletransparente = False then
    begin
      DrawPoly(Vector2Create(HexGrid[i].Center.x, HexGrid[i].Center.y),
               6, HexRadius, rotationAngle, HexGrid[i].Color);

      if HexGrid[i].Selected then
        outlineColor := GREEN
      else
        outlineColor := raywhite;
    end;

    // Déterminer la couleur du contour selon le mode
    if (AppMode = amDetection) and (HexGrid[i].IsReference > 0) then
      outlineColor := RED
    else if (AppMode = amSuppression) and HexGrid[i].Supprime then
      outlineColor := RED
    else if (AppMode = amRiviere) and (i = HexRiviereSource) then
      outlineColor := ORANGE
    else
      outlineColor := orange;

    // Dessiner le contour de l'hexagone
    DrawPolyLinesEx(Vector2Create(HexGrid[I].Center.x, HexGrid[I].Center.y),
                    6, HexRadius, rotationAngle, 2, outlineColor);

    // Afficher les numéros d'hexagones (mode normal)
    if showNumbers and not HexGrid[i].Supprime then
    begin
      StrPCopy(hexNumberText, IntToStr(HexGrid[I].Number));
      DrawText(hexNumberText,
               Round(HexGrid[I].Center.x - 5),
               Round(HexGrid[I].Center.y - 10),
               20, BLACK);
    end;

    // =================== AFFICHAGES SPÉCIFIQUES PAR MODE ===================

    // MODE DÉTECTION : Afficher les numéros de référence ou de type terrain
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

    // MODE SUPPRESSION : Afficher X pour hexagones supprimés
    if (AppMode = amSuppression) and HexGrid[i].Supprime then
    begin
      DrawText('X',
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               24, RED);
    end;

    // MODE SUPPRESSION : Afficher O pour hexagones exempts
    if (AppMode = amSuppression) and HexGrid[i].Exempt then
    begin
      DrawText('O',
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               24, RED);
    end;

    // MODE OBJET : Afficher ronds rouges pour objets actifs
    if (AppMode = amObjet) and HexGrid[i].Objets[ValeurSpinnerObjet] then
    begin
      DrawCircle(Round(HexGrid[I].Center.x),
                 Round(HexGrid[I].Center.y),
                 5, RED);
    end;

    // ⭐ NOUVEAU: MODE HAUTEUR - Afficher le chiffre de hauteur
    if (AppMode = amHauteur) and not HexGrid[i].Supprime then
    begin
      StrPCopy(hexNumberText, IntToStr(HexGrid[i].Hauteur));
      DrawText(hexNumberText,
               Round(HexGrid[I].Center.x - 8),
               Round(HexGrid[I].Center.y - 12),
               20, red);
    end;
  end;

  // =================== DESSIN DES RIVIÈRES (UNIQUEMENT EN MODE RIVIÈRE) ===================
  if AppMode = amRiviere then
  begin
    for i := 1 to TotalNbreHex do
    begin
      if HexGrid[i].Supprime then Continue;

      // Parcourir les 6 côtés de chaque hexagone
      for j := 1 to 6 do
      begin
        if HexGrid[i].Edges[j] > 0 then
        begin
          // Trouver le voisin
          voisin := HexGrid[i].Neighbors[j];
          if (voisin > 0) and (voisin <= TotalNbreHex) then
          begin
            // Pour éviter de dessiner 2 fois, ne dessiner que si i < voisin
            if i < voisin then
            begin
              epaisseur := HexGrid[i].Edges[j];  // 1-5 pixels
              DrawLineEx(HexGrid[i].Center, HexGrid[voisin].Center, epaisseur, RED);
            end;
          end;
        end;
      end;
    end;
  end;
end;

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
begin
  mousePos := GetMousePosition();

  // =================== GESTION DU DÉBUT DU DRAG ===================
  if IsMouseButtonPressed(MOUSE_LEFT_BUTTON) then
  begin
    if (mousePos.x < windowWidth - PanelWidth) and (mousePos.y < windowHeight - InfoBoxHeight) then
    begin
      DragStartPos := mousePos;
      MouseStartOffsetX := Hex1ReferenceX;
      MouseStartOffsetY := Hex1ReferenceY;
      DragStartOffsetX := lacarte.position.x;
      DragStartOffsetY := lacarte.position.y;
      IsDragging := False;
    end;
  end;

  // =================== GESTION DU DRAG EN COURS ===================
  if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then
  begin
    deltaX := mousePos.x - DragStartPos.x;
    deltaY := mousePos.y - DragStartPos.y;
    distance := sqrt(deltaX * deltaX + deltaY * deltaY);

    if (distance > MinDragDistance) and (mousePos.x < windowWidth - PanelWidth) then
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

      Hex1ReferenceX := newHex1RefX;
      Hex1ReferenceY := newHex1RefY;
      lacarte.position.x := DragStartOffsetX + deltaX;
      lacarte.position.y := DragStartOffsetY + deltaY;
    end;
  end;

  // =================== GESTION DE LA FIN DU DRAG (CLIC OU DROP) ===================
  if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then
  begin
    if IsDragging then
    begin
      RegenerateurGrille;
      WriteLn('Régénération après glisser-déposer terminée');
    end
    else
    begin
      // C'était un CLIC, pas un drag
      mouseX := GetMouseX();
      mouseY := GetMouseY();

      if (mouseX < windowWidth - PanelWidth) and (mouseY < windowHeight - InfoBoxHeight) then
      begin
        // Détecter quel hexagone a été cliqué
        for i := 1 to TotalNbreHex do
        begin
          dx := mouseX - HexGrid[i].Center.x;
          dy := mouseY - HexGrid[i].Center.y;
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
                  WriteLn('Hexagone #' + IntToStr(i) + ' corrigé vers type ' + IntToStr(ValeurSpinnerCorrection));

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
                  0:
                  begin
                    if HexGrid[i].Supprime = False then
                    begin
                      WriteLn('Suppression hexagone #' + IntToStr(i));
                      HexGrid[i].Supprime := True;

                      for j := 1 to 6 do
                      begin
                        ancienVoisin := HexGrid[i].Neighbors[j];
                        if ancienVoisin > 0 then
                        begin
                          for k := 1 to 6 do
                          begin
                            if HexGrid[ancienVoisin].Neighbors[k] = i then
                            begin
                              HexGrid[ancienVoisin].Neighbors[k] := 0;
                              WriteLn('  Supprimé référence dans hexagone #' + IntToStr(ancienVoisin) + ' voisin[' + IntToStr(k) + ']');
                            end;
                          end;
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

                  1:
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
                HexGrid[i].Objets[ValeurSpinnerObjet] := not HexGrid[i].Objets[ValeurSpinnerObjet];

                if HexGrid[i].Objets[ValeurSpinnerObjet] then
                  WriteLn('Item ' + IntToStr(ValeurSpinnerObjet) + ' placé sur hexagone #' + IntToStr(i))
                else
                  WriteLn('Item ' + IntToStr(ValeurSpinnerObjet) + ' supprimé de l''hexagone #' + IntToStr(i));

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
                  // PREMIER CLIC - Sélectionner la source
                  HexRiviereSource := i;
                  WriteLn('Riviere: Source selectionnee #' + IntToStr(i));

                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end
                else
                begin
                  // DEUXIÈME CLIC - Placer ou supprimer la rivière
                  coteSource := TrouverAreteCommuneEntreVoisins(HexRiviereSource, i);

                  if coteSource > 0 then
                  begin
                    coteDest := CoteOppose(coteSource);

                    if HexGrid[HexRiviereSource].Edges[coteSource] > 0 then
                    begin
                      // SUPPRESSION - Rivière existe déjà
                      HexGrid[HexRiviereSource].Edges[coteSource] := 0;
                      HexGrid[i].Edges[coteDest] := 0;
                      WriteLn('Riviere supprimee entre #' + IntToStr(HexRiviereSource) + ' et #' + IntToStr(i));
                    end
                    else
                    begin
                      // PLACEMENT - Nouvelle rivière
                      HexGrid[HexRiviereSource].Edges[coteSource] := ValeurSpinnerRiviere;
                      HexGrid[i].Edges[coteDest] := ValeurSpinnerRiviere;
                      WriteLn('Riviere type ' + IntToStr(ValeurSpinnerRiviere) + ' placee entre #' + IntToStr(HexRiviereSource) + ' et #' + IntToStr(i));
                    end;
                  end
                  else
                  begin
                    WriteLn('ERREUR: Les hexagones #' + IntToStr(HexRiviereSource) + ' et #' + IntToStr(i) + ' ne sont pas adjacents');
                  end;

                  HexRiviereSource := 0;

                  for j := 1 to TotalNbreHex do
                    HexGrid[j].Selected := False;
                  HexGrid[i].Selected := True;
                  SelectedHex := HexGrid[i];
                  HexSelected := True;
                end;
              end;

              // =================== ⭐ NOUVEAU: MODE HAUTEUR ===================
              amHauteur:
              begin
                // Appliquer la hauteur sélectionnée à l'hexagone cliqué
                HexGrid[i].Hauteur := ValeurSpinnerHauteur;

                WriteLn('Hauteur ' + IntToStr(ValeurSpinnerHauteur) + ' appliquée à l''hexagone #' + IntToStr(i));

                // Mettre à jour la sélection
                for j := 1 to TotalNbreHex do
                  HexGrid[j].Selected := False;
                HexGrid[i].Selected := True;
                SelectedHex := HexGrid[i];
                HexSelected := True;
              end;
            end;

            Break;
          end;
        end;
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
  if faitAstar = false then AStarPathfinding(3,36);

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
