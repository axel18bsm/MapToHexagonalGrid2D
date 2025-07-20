unit DetectionLogic;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, raylib, initVariable, math;

// Procédures publiques pour la détection
procedure InitDetectionSystem;
procedure StartReferenceSelection;
procedure StopReferenceSelection;
procedure HandleDetectionClick(hexNumber: Integer);
procedure ResetAllReferences;
function GetDetectionStatus: string;
procedure ResetDetectionComplete;

// Nouvelles procédures pour l'analyse des couleurs
function AnalyzeHexagonColors(hexNumber: Integer): TColorSignature;
procedure AnalyzeAllReferences;
function CountColorsInCircle(centerX, centerY, radius: Single): TColorSignature;
function ColorsAreSimilar(color1, color2: TColor; threshold: Integer): Boolean;

// Nouvelles procédures pour la classification
function CompareSignatures(sig1, sig2: TColorSignature; strictOrder: Boolean): Boolean;
function FindMatchingReference(hexSignature: TColorSignature): Integer;
procedure ClassifyAllHexagons;

implementation


procedure ResetDetectionComplete;
var
  i, j: Integer;
begin
  WriteLn('');
  WriteLn('=================== RÉINITIALISATION COMPLÈTE DE LA DÉTECTION ===================');

  // 1. Effacer tous les TypeTerrain, IsReference, Supprime ET Exempt de tous les hexagones
  for i := 1 to TotalNbreHex do
  begin
    HexGrid[i].TypeTerrain := 0;
    HexGrid[i].IsReference := 0;
    HexGrid[i].Supprime := False;
    HexGrid[i].Exempt := False;  // NOUVEAU: Réinitialiser aussi l'exemption
  end;

  // 2. Vider toutes les signatures de référence
  for i := 1 to Length(ReferenceSignatures) - 1 do
  begin
    if i <= High(ReferenceSignatures) then
    begin
      ReferenceSignatures[i].IsValid := False;
      ReferenceSignatures[i].TotalPixels := 0;
      for j := 0 to 2 do
      begin
        ReferenceSignatures[i].DominantColors[j] := BLANK;
        ReferenceSignatures[i].ColorCounts[j] := 0;
      end;
    end;
  end;

  // 3. Remettre tous les compteurs et variables à zéro
  NombreReferences := 0;
  DetectionActive := False;
  StatusDetection := 'Prêt';
  ValeurSpinnerCorrection := 1;

  WriteLn('- Tous les TypeTerrain remis à 0');
  WriteLn('- Toutes les références effacées');
  WriteLn('- Tous les Supprime remis à False');
  WriteLn('- Tous les Exempt remis à False');  // NOUVEAU
  WriteLn('- Toutes les signatures vidées');
  WriteLn('- Corrections manuelles effacées');
  WriteLn('- Compteurs réinitialisés');
  WriteLn('=================== RÉINITIALISATION TERMINÉE ===================');
  WriteLn('');
end;

procedure InitDetectionSystem;
var
  i, j: Integer;
begin
  // Initialiser tous les hexagones avec les valeurs par défaut
  for i := 1 to TotalNbreHex do
  begin
    HexGrid[i].TypeTerrain := 0;
    HexGrid[i].IsReference := 0;
    HexGrid[i].Supprime := False;
    HexGrid[i].Exempt := False;        // NOUVEAU: Initialisation exemption
  end;

  // Initialiser le tableau dynamique des signatures (commence à index 1)
  // On alloue assez d'espace pour tous les hexagones potentiels
  SetLength(ReferenceSignatures, TotalNbreHex + 1);  // +1 pour commencer à index 1

  for i := 1 to TotalNbreHex do
  begin
    ReferenceSignatures[i].IsValid := False;
    ReferenceSignatures[i].TotalPixels := 0;
    for j := 0 to 2 do
    begin
      ReferenceSignatures[i].DominantColors[j] := BLANK;
      ReferenceSignatures[i].ColorCounts[j] := 0;
    end;
  end;

  DetectionActive := False;
  NombreReferences := 0;
  StatusDetection := 'Prêt';

  WriteLn('Système de détection initialisé avec support suppression et exemption');
end;



procedure StartReferenceSelection;
begin
  DetectionActive := True;
  StatusDetection := 'Sélection références en cours';
  WriteLn('Début sélection des références');
end;

procedure StopReferenceSelection;
begin
  DetectionActive := False;
  if NombreReferences = 0 then
    StatusDetection := 'Aucune référence sélectionnée'
  else
  begin
    StatusDetection := 'Analyse des références...';
    // Analyser toutes les références
    AnalyzeAllReferences;

    StatusDetection := 'Classification en cours...';
    // NOUVEAU: Classifier tous les hexagones
    ClassifyAllHexagons;
  end;

  WriteLn('Fin sélection - Références: ' + IntToStr(NombreReferences));
end;

procedure HandleDetectionClick(hexNumber: Integer);
begin
  if not DetectionActive then Exit;

  // Vérifier que l'hexagone n'est pas déjà une référence
  if HexGrid[hexNumber].IsReference > 0 then
  begin
    WriteLn('Hexagone ' + IntToStr(hexNumber) + ' déjà référence #' + IntToStr(HexGrid[hexNumber].IsReference));
    Exit;
  end;

  // Ajouter comme nouvelle référence
  Inc(NombreReferences);
  HexGrid[hexNumber].IsReference := NombreReferences;
  HexGrid[hexNumber].TypeTerrain := NombreReferences;

  StatusDetection := 'Références: ' + IntToStr(NombreReferences) + ' - Clic pour continuer';

  WriteLn('Hexagone ' + IntToStr(hexNumber) + ' défini comme référence #' + IntToStr(NombreReferences));
end;

procedure ResetAllReferences;
var
  i: Integer;
begin
  for i := 1 to TotalNbreHex do
  begin
    HexGrid[i].TypeTerrain := 0;
    HexGrid[i].IsReference := 0;
  end;

  NombreReferences := 0;
  DetectionActive := False;
  StatusDetection := 'Références effacées';

  WriteLn('Toutes les références ont été effacées');
end;

function GetDetectionStatus: string;
begin
  Result := StatusDetection;
end;

// ================== NOUVELLES FONCTIONS POUR L'ANALYSE DES COULEURS ==================

function ColorsAreSimilar(color1, color2: TColor; threshold: Integer): Boolean;
var
  distance: Integer;
begin
  // Distance Manhattan : |R1-R2| + |G1-G2| + |B1-B2|
  distance := abs(color1.r - color2.r) + abs(color1.g - color2.g) + abs(color1.b - color2.b);
  Result := distance <= threshold;
end;

function CountColorsInCircle(centerX, centerY, radius: Single): TColorSignature;
var
  x, y: Integer;
  point: TVector2;
  center: TVector2;
  pixelColor: TColor;
  colorList: array of TColorCount;
  colorIndex: Integer;
  found: Boolean;
  i, j: Integer;
  totalPixels: Integer;
  colorThreshold: Integer;
begin
  // Seuil pour regrouper les couleurs similaires
  colorThreshold := 40;  // Ajustable selon les résultats

  // Initialiser la signature
  Result.TotalPixels := 0;
  Result.IsValid := False;
  for i := 0 to 2 do
  begin
    Result.DominantColors[i] := BLANK;
    Result.ColorCounts[i] := 0;
  end;

  // Vérifier que l'image est chargée
  if not lacarte.Acharger then
  begin
    WriteLn('Erreur: Aucune carte chargée pour l''analyse');
    Exit;
  end;

  SetLength(colorList, 0);
  center.x := centerX;
  center.y := centerY;
  totalPixels := 0;

  WriteLn('Seuil de regroupement des couleurs: ' + IntToStr(colorThreshold));

  // Parcourir tous les pixels dans un carré autour du cercle
  for y := Round(centerY - radius) to Round(centerY + radius) do
  begin
    for x := Round(centerX - radius) to Round(centerX + radius) do
    begin
      // Vérifier que le pixel est dans les limites de l'image
      if (x >= 0) and (x < lacarte.limage.width) and (y >= 0) and (y < lacarte.limage.height) then
      begin
        point.x := x;
        point.y := y;

        // Vérifier que le point est dans le cercle
        if CheckCollisionPointCircle(point, center, radius) then
        begin
          pixelColor := GetImageColor(lacarte.limage, x, y);
          Inc(totalPixels);

          // Chercher si cette couleur (ou une similaire) existe déjà
          found := False;
          for i := 0 to High(colorList) do
          begin
            if ColorsAreSimilar(colorList[i].Color, pixelColor, colorThreshold) then
            begin
              Inc(colorList[i].Count);
              found := True;
              Break;
            end;
          end;

          // Si couleur pas trouvée, l'ajouter
          if not found then
          begin
            SetLength(colorList, Length(colorList) + 1);
            colorList[High(colorList)].Color := pixelColor;
            colorList[High(colorList)].Count := 1;
          end;
        end;
      end;
    end;
  end;

  Result.TotalPixels := totalPixels;

  if totalPixels = 0 then
  begin
    WriteLn('Aucun pixel trouvé dans le cercle');
    Exit;
  end;

  WriteLn('Couleurs distinctes trouvées: ' + IntToStr(Length(colorList)));

  // Trier les couleurs par fréquence (tri à bulles simple)
  for i := 0 to High(colorList) - 1 do
  begin
    for j := i + 1 to High(colorList) do
    begin
      if colorList[j].Count > colorList[i].Count then
      begin
        // Échanger
        pixelColor := colorList[i].Color;
        colorIndex := colorList[i].Count;
        colorList[i] := colorList[j];
        colorList[j].Color := pixelColor;
        colorList[j].Count := colorIndex;
      end;
    end;
  end;

  // Prendre les 3 couleurs les plus fréquentes
  for i := 0 to Min(2, High(colorList)) do
  begin
    Result.DominantColors[i] := colorList[i].Color;
    Result.ColorCounts[i] := colorList[i].Count;
  end;

  Result.IsValid := True;
end;

function AnalyzeHexagonColors(hexNumber: Integer): TColorSignature;
var
  centerX, centerY: Single;
  analysisRadius: Single;
begin
  // Vérifier que l'hexagone existe
  if (hexNumber < 1) or (hexNumber > TotalNbreHex) then
  begin
    Result.IsValid := False;
    WriteLn('Erreur: Numéro d''hexagone invalide: ' + IntToStr(hexNumber));
    Exit;
  end;

  centerX := HexGrid[hexNumber].Center.x;
  centerY := HexGrid[hexNumber].Center.y;
  analysisRadius := HexRadius * 0.8; // 80% du rayon pour rester dans l'hexagone

  WriteLn('=== Analyse hexagone #' + IntToStr(hexNumber) + ' ===');
  WriteLn('Centre: (' + FormatFloat('0.0', centerX) + ', ' + FormatFloat('0.0', centerY) + ')');
  WriteLn('Rayon d''analyse: ' + FormatFloat('0.0', analysisRadius));

  Result := CountColorsInCircle(centerX, centerY, analysisRadius);

  if Result.IsValid then
  begin
    WriteLn('Pixels analysés: ' + IntToStr(Result.TotalPixels));

    if Result.TotalPixels > 0 then
    begin
      WriteLn('Couleurs dominantes:');
      if Result.ColorCounts[0] > 0 then
        WriteLn('  1. RGB(' + IntToStr(Result.DominantColors[0].r) + ',' + IntToStr(Result.DominantColors[0].g) + ',' + IntToStr(Result.DominantColors[0].b) + ') - ' + IntToStr(Result.ColorCounts[0]) + ' pixels (' + FormatFloat('0.0', (Result.ColorCounts[0] * 100.0) / Result.TotalPixels) + '%)');

      if Result.ColorCounts[1] > 0 then
        WriteLn('  2. RGB(' + IntToStr(Result.DominantColors[1].r) + ',' + IntToStr(Result.DominantColors[1].g) + ',' + IntToStr(Result.DominantColors[1].b) + ') - ' + IntToStr(Result.ColorCounts[1]) + ' pixels (' + FormatFloat('0.0', (Result.ColorCounts[1] * 100.0) / Result.TotalPixels) + '%)');

      if Result.ColorCounts[2] > 0 then
        WriteLn('  3. RGB(' + IntToStr(Result.DominantColors[2].r) + ',' + IntToStr(Result.DominantColors[2].g) + ',' + IntToStr(Result.DominantColors[2].b) + ') - ' + IntToStr(Result.ColorCounts[2]) + ' pixels (' + FormatFloat('0.0', (Result.ColorCounts[2] * 100.0) / Result.TotalPixels) + '%)');
    end;
  end
  else
  begin
    WriteLn('Erreur lors de l''analyse');
  end;

  WriteLn('');
end;

procedure AnalyzeAllReferences;
var
  i: Integer;
  refCount: Integer;
  signature: TColorSignature;
begin
  WriteLn('');
  WriteLn('=================== DÉBUT ANALYSE DES RÉFÉRENCES ===================');

  refCount := 0;

  // Analyser chaque hexagone référence
  for i := 1 to TotalNbreHex do
  begin
    if HexGrid[i].IsReference > 0 then
    begin
      Inc(refCount);
      signature := AnalyzeHexagonColors(i);

      // Stocker la signature à l'index correspondant au numéro de référence
      // ReferenceSignatures[numRef] = signature de la référence #numRef
      ReferenceSignatures[HexGrid[i].IsReference] := signature;

      WriteLn('Signature stockée pour référence #' + IntToStr(HexGrid[i].IsReference) + ' (hexagone #' + IntToStr(i) + ')');
    end;
  end;

  WriteLn('=================== FIN ANALYSE - ' + IntToStr(refCount) + ' RÉFÉRENCES ===================');
  WriteLn('');
end;

// ================== NOUVELLES FONCTIONS POUR LA CLASSIFICATION ==================

function CompareSignatures(sig1, sig2: TColorSignature; strictOrder: Boolean): Boolean;
var
  i, j: Integer;
  matchCount: Integer;
  requiredMatches: Integer;
  colorThreshold: Integer;
begin
  Result := False;
  colorThreshold := 40; // Même seuil que pour le regroupement

  // Déterminer combien de couleurs la référence a
  requiredMatches := 0;
  for i := 0 to 2 do
  begin
    if sig2.ColorCounts[i] > 0 then
      Inc(requiredMatches);
  end;

  if requiredMatches = 0 then Exit; // Signature de référence vide

  if strictOrder then
  begin
    // =================== MODE STRICT ===================
    // Chaque position doit correspondre exactement
    for i := 0 to requiredMatches - 1 do
    begin
      // Vérifier que l'hexagone a une couleur à cette position
      if sig1.ColorCounts[i] = 0 then
        Exit; // L'hexagone n'a pas assez de couleurs

      // Vérifier que les couleurs à la même position sont similaires
      if not ColorsAreSimilar(sig1.DominantColors[i], sig2.DominantColors[i], colorThreshold) then
        Exit; // Les couleurs à cette position ne correspondent pas
    end;

    Result := True; // Toutes les positions correspondent
  end
  else
  begin
    // =================== MODE NON-STRICT ===================
    // Les couleurs doivent juste être présentes, peu importe l'ordre
    matchCount := 0;

    // Vérifier que chaque couleur de la référence se retrouve dans l'hexagone
    for i := 0 to 2 do
    begin
      if sig2.ColorCounts[i] > 0 then // Cette couleur existe dans la référence
      begin
        // Chercher cette couleur dans l'hexagone
        for j := 0 to 2 do
        begin
          if sig1.ColorCounts[j] > 0 then // Cette couleur existe dans l'hexagone
          begin
            if ColorsAreSimilar(sig1.DominantColors[j], sig2.DominantColors[i], colorThreshold) then
            begin
              Inc(matchCount);
              Break; // Couleur trouvée, passer à la suivante
            end;
          end;
        end;
      end;
    end;

    // Toutes les couleurs de la référence doivent être trouvées
    Result := (matchCount = requiredMatches);
  end;
end;

function FindMatchingReference(hexSignature: TColorSignature): Integer;
var
  i: Integer;
  useStrictOrder: Boolean;
begin
  Result := 0; // Par défaut : non déterminé
  useStrictOrder := false; // Changer ici pour basculer entre strict/non-strict

  // Tester chaque signature de référence
  for i := 1 to NombreReferences do
  begin
    if ReferenceSignatures[i].IsValid then
    begin
      if CompareSignatures(hexSignature, ReferenceSignatures[i], useStrictOrder) then
      begin
        Result := i; // Référence trouvée
        Exit;
      end;
    end;
  end;
end;

procedure ClassifyAllHexagons;
var
  i: Integer;
  hexSignature: TColorSignature;
  matchingRef: Integer;
  determinedCount: Integer;
  undeterminedCount: Integer;
begin
  WriteLn('');
  WriteLn('=================== DÉBUT CLASSIFICATION DE TOUS LES HEXAGONES ===================');

  determinedCount := 0;
  undeterminedCount := 0;

  for i := 1 to TotalNbreHex do
  begin
    // Mettre à jour le statut périodiquement
    if (i mod 50) = 0 then
      StatusDetection := 'Classification: ' + IntToStr(i) + '/' + IntToStr(TotalNbreHex);

    // Ne pas re-analyser les références
    if HexGrid[i].IsReference > 0 then
    begin
      Inc(determinedCount); // Les références sont déjà déterminées
      Continue;
    end;

    // Analyser cet hexagone
    hexSignature := AnalyzeHexagonColors(i);

    if hexSignature.IsValid then
    begin
      // Trouver la référence correspondante
      matchingRef := FindMatchingReference(hexSignature);
      HexGrid[i].TypeTerrain := matchingRef;

      if matchingRef > 0 then
        Inc(determinedCount)
      else
        Inc(undeterminedCount);
    end
    else
    begin
      HexGrid[i].TypeTerrain := 0;
      Inc(undeterminedCount);
    end;
  end;

  StatusDetection := 'Classification terminée: ' + IntToStr(determinedCount) + ' déterminés, ' + IntToStr(undeterminedCount) + ' non déterminés';

  WriteLn('Classification terminée:');
  WriteLn('- Hexagones déterminés: ' + IntToStr(determinedCount));
  WriteLn('- Hexagones non déterminés: ' + IntToStr(undeterminedCount));
  WriteLn('=================== FIN CLASSIFICATION ===================');
  WriteLn('');
end;

end.
