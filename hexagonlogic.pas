unit HexagonLogic;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, raylib,initVariable;

// Procédures publiques pour la logique hexagonale
procedure GenerateHexagons;
procedure CalculateNeighbors;
procedure CalculateHexVertices(var Hex: THexCell);
function PairOuImpairCol(Number: Integer): boolean;
function PairOuImpairLigne(Number: Integer): boolean;
function EmplacementToString(Emplacement: TEmplacement): string;
procedure ExempterHexagone(hexNumber: Integer);
procedure RestaurerHexagoneExempt(hexNumber: Integer);
procedure NettoyerVoisinagesExempts;

implementation

// Procédures internes
procedure PositionHexagone; forward;
procedure TrouveLesVoisins; forward;

procedure NettoyerVoisinagesExempts;
var
  i, j, k: Integer;
  voisinNum: Integer;
  nombreExempts: Integer;
begin
  WriteLn('=== NETTOYAGE DES VOISINAGES EXEMPTS ===');

  nombreExempts := 0;

  // Pour chaque hexagone exempt
  for i := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Exempt then
    begin
      Inc(nombreExempts);
      WriteLn('Nettoyage voisinage hexagone exempt #' + IntToStr(i));

      // Supprimer les références à cet hexagone dans ses voisins
      for j := 1 to 6 do
      begin
        voisinNum := HexGrid[i].Neighbors[j];
        if voisinNum > 0 then  // Si ce voisin existe
        begin
          WriteLn('  Nettoyage dans voisin #' + IntToStr(voisinNum));

          // Dans ce voisin, chercher la référence à l'hexagone exempt et la supprimer
          for k := 1 to 6 do
          begin
            if HexGrid[voisinNum].Neighbors[k] = i then
            begin
              HexGrid[voisinNum].Neighbors[k] := 0;
              WriteLn('    Référence supprimée: voisin[' + IntToStr(k) + '] mis à 0');
              Break; // Une seule référence par voisin normalement
            end;
          end;
        end;
      end;
    end;
  end;

  if nombreExempts > 0 then
  begin
    WriteLn('Nettoyage terminé: ' + IntToStr(nombreExempts) + ' hexagones exempts traités');
  end
  else
  begin
    WriteLn('Aucun hexagone exempt trouvé');
  end;

  WriteLn('=== FIN NETTOYAGE VOISINAGES EXEMPTS ===');
  WriteLn('');
end;

function PairOuImpairligne(Number: Integer): boolean;
begin
  if not(Number mod 2 = 0) then
    PairOuImpairligne := true  // impair
  else
    PairOuImpairligne := false;
end;
function PairOuImpairCol(Number: Integer): boolean;
begin
  if not(Number mod 2 = 0) then
    PairOuImpairCol := true  // impair
  else
    PairOuImpairCol := false;
end;

function EmplacementToString(Emplacement: TEmplacement): string;
begin
  case Emplacement of
    inconnu: Result := 'inconnu';
    CoinHG: Result := 'CoinHG';
    CoinHD: Result := 'CoinHD';
    CoinBG: Result := 'CoinBG';
    CoinBD: Result := 'CoinBD';
    BordH: Result := 'BordH';
    BordB: Result := 'BordB';
    BordG: Result := 'BordG';
    BordD: Result := 'BordD';
    Classic: Result := 'Classic';
    Bloque: Result := 'Bloque';
  end;
end;

procedure CalculateHexVertices(var Hex: THexCell);
var
  angle_deg, angle_rad: single;
  k: integer;
  startAngle: single;
begin
  // Définir l'angle de départ selon l'orientation
  case HexOrientation of
    hoFlatTop:   startAngle := 0;  // Flat top: commence à 30°
    hoPointyTop: startAngle := 30;   // Pointy top: commence à 0°
  end;

  for k := 0 to 5 do
  begin
    angle_deg := startAngle + 60 * k;
    angle_rad := PI / 180 * angle_deg;
    Hex.Vertices[k].x := Round(Hex.Center.x + HexRadius * cos(angle_rad));
    Hex.Vertices[k].y := Round(Hex.Center.y + HexRadius * sin(angle_rad));
  end;
end;

procedure GenerateHexagons;
var
  x, y, i: Integer;
  offsetX, offsetY: Single;
  horizontalSpacing, verticalSpacing: Single;
  oldSupprime: array of Boolean;  // NOUVEAU: Sauvegarder les états de suppression
  oldTypeTerrainExist: Boolean;   // NOUVEAU: Vérifier si on a des données existantes
begin
  // NOUVEAU: Vérifier si on a déjà des données dans HexGrid
  oldTypeTerrainExist := (Length(HexGrid) > 0) and (TotalNbreHex > 0);

  // NOUVEAU: Sauvegarder les états de suppression existants
  if oldTypeTerrainExist then
  begin
    SetLength(oldSupprime, TotalNbreHex + 1);
    for i := 1 to TotalNbreHex do
    begin
      if i <= High(HexGrid) then
        oldSupprime[i] := HexGrid[i].Supprime
      else
        oldSupprime[i] := False;
    end;
    WriteLn('Sauvegarde de ' + IntToStr(TotalNbreHex) + ' états de suppression');
  end
  else
  begin
    SetLength(oldSupprime, 0);
    WriteLn('Première génération - pas de sauvegarde nécessaire');
  end;

  i := 1;

  // Calculer l'espacement selon l'orientation
  case HexOrientation of
    hoFlatTop:
    begin
      horizontalSpacing := hexWidth * 3/4;
      verticalSpacing := hexHeight;
    end;
    hoPointyTop:
    begin
      horizontalSpacing := hexWidth;
      verticalSpacing := hexHeight * 3/4;
    end;
  end;

  for y := 1 to rows do
  begin
    for x := 1 to columns do
    begin
      case HexOrientation of
        hoFlatTop:
        begin
          // CORRECTION : Calculer la position relative à l'hexagone 1
          offsetX := Hex1ReferenceX + (x - 1) * horizontalSpacing;
          offsetY := Hex1ReferenceY + (y - 1) * verticalSpacing;

          // Décalage vertical pour colonnes impaires
          if (x mod 2) = 1 then
          begin
            if CoinIn = true then
              offsetY := offsetY + (hexHeight / 2)
            else
              offsetY := offsetY - (hexHeight / 2);
          end;
        end;

        hoPointyTop:
        begin
          // CORRECTION : Calculer la position relative à l'hexagone 1
          offsetX := Hex1ReferenceX + (x - 1) * horizontalSpacing;
          offsetY := Hex1ReferenceY + (y - 1) * verticalSpacing;

          // Décalage horizontal pour lignes impaires
          if (y mod 2) = 1 then
          begin
            if CoinIn = true then
              offsetX := offsetX + (hexWidth / 2)
            else
              offsetX := offsetX - (hexWidth / 2);
          end;
        end;
      end;

      HexGrid[i].Number := i;
      HexGrid[i].colonne := x;
      HexGrid[i].ligne := y;
      HexGrid[i].PairImpaircolonne := PairOuImpairCol(HexGrid[i].Colonne);
      HexGrid[i].PairImpairligne := PairOuImpairLigne(HexGrid[i].ligne);

      // CORRECTION PRINCIPALE : Le centre est directement à la position calculée
      // SANS ajouter hexRadius !
      HexGrid[i].center.X := Round(offsetX);
      HexGrid[i].center.Y := Round(offsetY);

      // Vérifier que le centre est dans les limites de l'image
      if (HexGrid[i].center.X >= 0) and (HexGrid[i].center.X < lacarte.limage.width) and
         (HexGrid[i].center.Y >= 0) and (HexGrid[i].center.Y < lacarte.limage.height) then
      begin
        HexGrid[i].ColorPt := GetImageColor(lacarte.limage, trunc(HexGrid[i].center.X), trunc(HexGrid[i].center.Y));
      end
      else
      begin
        HexGrid[i].ColorPt := BLANK;
      end;

      // Couleur en damier
      if (x + y) mod 2 = 0 then
        HexGrid[i].Color := GREEN
      else
        HexGrid[i].Color := LIGHTGRAY;

      HexGrid[i].Selected := False;

      // MODIFIÉ: Préserver l'état de suppression existant ou initialiser à False
      if oldTypeTerrainExist and (i <= High(oldSupprime)) then
      begin
        HexGrid[i].Supprime := oldSupprime[i];  // Restaurer l'état sauvegardé
      end
      else
      begin
        HexGrid[i].Supprime := False;  // Initialisation par défaut pour nouveaux hexagones
      end;

      CalculateHexVertices(HexGrid[i]);
      Inc(i);
    end;
  end;

  // MouseOffset à 0 car la grille est déjà bien positionnée
  MouseOffsetX := 0;
  MouseOffsetY := 0;
  GridOffsetX := Hex1ReferenceX;
  GridOffsetY := Hex1ReferenceY;

  // NOUVEAU: Log du résultat
  if oldTypeTerrainExist then
  begin
    i := 0;
    for x := 1 to TotalNbreHex do
      if HexGrid[x].Supprime then Inc(i);
    WriteLn('Génération terminée - ' + IntToStr(i) + ' hexagones supprimés préservés');
  end
  else
  begin
    WriteLn('Génération terminée - Tous les hexagones initialisés');
  end;
end;
procedure RestaurerHexagoneExempt(hexNumber: Integer);
begin
  WriteLn('=== RESTAURATION HEXAGONE EXEMPT #' + IntToStr(hexNumber) + ' ===');

  // Enlever le flag d'exemption
  HexGrid[hexNumber].Exempt := False;

  // Recalculer tous les voisinages (qui inclut maintenant le nettoyage des exemptions)
  CalculateNeighbors;

  WriteLn('Hexagone #' + IntToStr(hexNumber) + ' restauré avec voisinages recalculés');
  WriteLn('');
end;


procedure PositionHexagone;
var
  I: Integer;
begin
  // Initialisation de tous les champs à inconnu
  for I := 1 to TotalNbreHex do
    HexGrid[i].Poshexagone := inconnu;

  // Attribution des positions selon la position dans la grille
  for I := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Colonne = 1 then HexGrid[i].Poshexagone := BordG;           // bord gauche
    if HexGrid[i].ligne = 1 then HexGrid[i].Poshexagone := BordH;             // bord haut
    if HexGrid[i].colonne = columns then HexGrid[i].Poshexagone := BordD;     // bord droit
    if HexGrid[i].ligne = rows then HexGrid[i].Poshexagone := BordB;          // bord bas
  end;

  // Les coins (écrasent les bords)
  HexGrid[1].Poshexagone := CoinHG;                                    // coin haut gauche
  HexGrid[TotalNbreHex].Poshexagone := CoinBD;                         // coin bas droit
  HexGrid[columns].Poshexagone := CoinHD;                              // coin haut droit
  HexGrid[TotalNbreHex - columns + 1].Poshexagone := CoinBG;           // coin bas gauche

  // Le reste des inconnus deviennent des classic
  for I := 1 to TotalNbreHex do
  begin
    if HexGrid[i].Poshexagone = inconnu then
      HexGrid[i].Poshexagone := classic;
  end;
end;

procedure TrouveLesVoisins;
var
  I, j: Integer;
begin
  If CoinIn = False Then                                                    // separation pour etre plus lisible
  begin
    for I := 1 to TotalNbreHex do
    begin
      case HexGrid[i].Poshexagone of
        inconnu:
          begin
            for j := 1 to 6 do
            begin
              HexGrid[i].Neighbors[j] := 0;                              //hexagone inconnu donc pas de voisin
            end;
          end;
        CoinHG:
          begin                                                        // toujours ligne impaire
            HexGrid[i].Neighbors[1] := 0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;
        Coinbg:
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;
        CoinHD:                                                        // toujours ligne impaire
          begin
            if HexGrid[i].PairImpaircolonne = false then
            begin
              HexGrid[i].Neighbors[1] := 0;                                //paire colonne
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := 0;      //pair
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := 0;
            end;
          End;

        Coinbd:
          if HexGrid[i].PairImpaircolonne = false then                      //ligne paire
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;                                 //impair
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end;
        BordH:                                                         //toujours impair
          if HexGrid[i].PairImpaircolonne = false then                      //ligne paire
          begin
            HexGrid[i].Neighbors[1] := 0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1 + columns;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := 0;                                 //impair
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := 0;
          end;
        BordB:
          if HexGrid[i].PairImpaircolonne = false then                        //ligne impaire
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;      //ligne paire
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end;
        BordG:
          begin
                                                                      // toujours ligne impaire
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;

        BordD:
          begin
            if HexGrid[i].PairImpaircolonne = false then                    //ligne impaire
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;                                 //ligne paire
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end;
          end;
        Classic:
          begin
            if HexGrid[i].PairImpaircolonne = false then                    //ligne impaire
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
               if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
              HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
               if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;       //ligne paire
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
               if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
              HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
               if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end;
          end;
      end;
    end;
  end;

  If CoinIn = True Then
  begin
    for I := 1 to TotalNbreHex do
    begin
      case HexGrid[i].Poshexagone of
        inconnu:
          begin
            for j := 1 to 6 do
            begin
              HexGrid[i].Neighbors[j] := 0;                              //hexagone inconnu donc pas de voisin
            end;
          end;
        CoinHG:
          begin                                                        // toujours ligne impaire
            HexGrid[i].Neighbors[1] := 0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;
        Coinbg:
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;
        CoinHD:                                                        // toujours ligne impaire
          begin
            if HexGrid[i].PairImpaircolonne = false then
            begin
              HexGrid[i].Neighbors[1] := 0;                                //paire colonne
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := 0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := 0;      //pair
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end;
          End;

        Coinbd:
          if HexGrid[i].PairImpaircolonne = false then                      //ligne paire
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;                                 //impair
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end;
        BordH:                                                         //toujours impair
          if HexGrid[i].PairImpaircolonne = false then                      //ligne paire
          begin
            HexGrid[i].Neighbors[1] := 0;
            HexGrid[i].Neighbors[2] := 0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := 0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := 0;                                 //impair
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end;
        BordB:
          if HexGrid[i].PairImpaircolonne = false then                        //ligne impaire
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end
          else
          begin
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;      //ligne paire
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := 0;
            HexGrid[i].Neighbors[4] := 0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
             if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
          end;
        BordG:
          begin
                                                                      // toujours ligne impaire
            HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
             if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
            HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
             if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
            HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
             if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
            HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
             if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
            HexGrid[i].Neighbors[5] := 0;
            HexGrid[i].Neighbors[6] := 0;
          end;

        BordD:
          begin
            if HexGrid[i].PairImpaircolonne = false then                    //ligne impaire
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;                                 //ligne paire
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := 0;
              HexGrid[i].Neighbors[3] := 0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end;
          end;
        Classic:
          begin
            if HexGrid[i].PairImpaircolonne = false then                    //ligne impaire
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := HexGrid[i].Number - columns + 1;
               if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
              HexGrid[i].Neighbors[3] := HexGrid[i].Number + 1;
               if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - columns - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end
            else
            begin
              HexGrid[i].Neighbors[1] := HexGrid[i].Number - columns;       //ligne paire
               if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
              HexGrid[i].Neighbors[2] := HexGrid[i].Number + 1;
               if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
              HexGrid[i].Neighbors[3] := HexGrid[i].Number + columns + 1;
               if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
              HexGrid[i].Neighbors[4] := HexGrid[i].Number + columns;
               if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
              HexGrid[i].Neighbors[5] := HexGrid[i].Number + columns - 1;
               if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
              HexGrid[i].Neighbors[6] := HexGrid[i].Number - 1;
               if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
            end;
          end;
      end;
    end;
  end;
end;

procedure TrouveLesVoisinsPointyTop;
var
  I, j: Integer;
begin
  // Gérer les deux cas : CoinIn = false et CoinIn = true
 begin

        If CoinIn =False Then                                                    // separation pour etre plus lisible
        begin
           for I := 1 to TotalNbreHex  do
           begin
                case HexGrid[i].Poshexagone of
                 inconnu:
                   begin
                     for j := 1 to 6 do
                     begin
                       HexGrid[i].Neighbors[j]:=0;                              //hexagone inconnu donc pas de voisin
                     end;
                   end;
                 CoinHG:
                   begin                                                        // toujours ligne impaire
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 CoinHD:                                                        // toujours ligne impaire
                   begin
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                      if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 Coinbg:
                   if HexGrid[i].PairImpairLigne=true then                      //impair
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;      //pair
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end;
                 Coinbd:
                  if HexGrid[i].PairImpairLigne=true then                      //ligne impair
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=0;                                 //pair
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordH:                                                         //toujours impair
                 begin
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                      if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordB:
                 if HexGrid[i].PairImpairLigne=true then                        //ligne impaire
                 begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;      //ligne paire
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordG:
                 begin
                     if HexGrid[i].PairImpairLigne=true then                     //ligne impaire
                     begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                     end
                     else
                     begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;      //ligne paire
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                     end;
                     end;
                 BordD:
                     begin
                    if HexGrid[i].PairImpairLigne=true then                    //ligne impaire
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end
                    else
                    begin
                    HexGrid[i].Neighbors[1]:=0;                                 //ligne paire
                    HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end;
                    end;
                     Classic:
                     begin
                    if HexGrid[i].PairImpairLigne=true then                    //ligne impaire
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end
                    else
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;       //ligne paire
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end;
                    end;
                   end;
                end;
           end;



        If CoinIn =True Then
        begin
           for I := 1 to TotalNbreHex  do
           begin
                case HexGrid[i].Poshexagone of
                 inconnu:
                   begin
                     for j := 1 to 6 do
                     begin
                       HexGrid[i].Neighbors[j]:=0;                              //hexagone inconnu donc pas de voisin
                     end;
                   end;
                 CoinHG:
                   begin                                                        // toujours ligne impaire
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0 ;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0 ;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0 ;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 CoinHD:                                                        // toujours ligne impaire
                   begin
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 Coinbg:
                   if HexGrid[i].PairImpairLigne=true then                      //impair
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;      //pair
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 Coinbd:
                  if HexGrid[i].PairImpairLigne=true then                      //ligne impair
                   begin
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;                                 //pair
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordH:                                                         //toujours impair
                 begin
                     HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordB:
                 if HexGrid[i].PairImpairLigne=true then                        //ligne impaire
                 begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end
                   else
                   begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;      //ligne paire
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                      if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                   end;
                 BordG:
                 begin
                     if HexGrid[i].PairImpairLigne=true then                     //ligne impaire
                     begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                      if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                     end
                     else
                     begin
                     HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;      //ligne paire
                      if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                     HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                      if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                     HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                      if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                     HexGrid[i].Neighbors[4]:=0;
                     HexGrid[i].Neighbors[5]:=0;
                     HexGrid[i].Neighbors[6]:=0;
                     end;
                     end;
                 BordD:
                     begin
                    if HexGrid[i].PairImpairLigne=true then                    //ligne impaire
                    begin
                    HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end
                    else
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;                                 //ligne paire
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end;
                    end;
                     Classic:
                     begin
                    if HexGrid[i].PairImpairLigne=true then                    //ligne impaire
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns+1;
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns+1;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end
                    else
                    begin
                    HexGrid[i].Neighbors[1]:=HexGrid[i].Number-columns;       //ligne paire
                     if HexGrid[HexGrid[i].Neighbors[1]].Supprime=True Then HexGrid[i].Neighbors[1]:=0;
                    HexGrid[i].Neighbors[2]:=HexGrid[i].Number+1;
                     if HexGrid[HexGrid[i].Neighbors[2]].Supprime=True Then HexGrid[i].Neighbors[2]:=0;
                    HexGrid[i].Neighbors[3]:=HexGrid[i].Number+columns;
                     if HexGrid[HexGrid[i].Neighbors[3]].Supprime=True Then HexGrid[i].Neighbors[3]:=0;
                    HexGrid[i].Neighbors[4]:=HexGrid[i].Number+columns-1;
                     if HexGrid[HexGrid[i].Neighbors[4]].Supprime=True Then HexGrid[i].Neighbors[4]:=0;
                    HexGrid[i].Neighbors[5]:=HexGrid[i].Number-1;
                     if HexGrid[HexGrid[i].Neighbors[5]].Supprime=True Then HexGrid[i].Neighbors[5]:=0;
                    HexGrid[i].Neighbors[6]:=HexGrid[i].Number-columns-1;
                     if HexGrid[HexGrid[i].Neighbors[6]].Supprime=True Then HexGrid[i].Neighbors[6]:=0;
                    end;
                    end;
                   end;
                end;
           end;
        End;
 end;
procedure ExempterHexagone(hexNumber: Integer);
var
  j, k: Integer;
  voisinNum: Integer;
begin
  WriteLn('=== EXEMPTION HEXAGONE #' + IntToStr(hexNumber) + ' ===');

  // Marquer l'hexagone comme exempt
  HexGrid[hexNumber].Exempt := True;

  // L'hexagone connaît déjà ses voisins
  for j := 1 to 6 do
  begin
    voisinNum := HexGrid[hexNumber].Neighbors[j];
    if voisinNum > 0 then  // Si ce voisin existe
    begin
      WriteLn('Suppression référence à #' + IntToStr(hexNumber) + ' dans hexagone #' + IntToStr(voisinNum));

      // Dans ce voisin, chercher la référence à hexNumber et la remplacer par 0
      for k := 1 to 6 do
      begin
        if HexGrid[voisinNum].Neighbors[k] = hexNumber then
        begin
          HexGrid[voisinNum].Neighbors[k] := 0;
          WriteLn('  Voisin[' + IntToStr(k) + '] mis à 0');
          Break; // Une seule référence par voisin normalement
        end;
      end;
    end;
  end;

  WriteLn('Hexagone #' + IntToStr(hexNumber) + ' exempté avec succès');
  WriteLn('');
end;

procedure CalculateNeighbors;
begin
  PositionHexagone;

  case HexOrientation of
    hoFlatTop:   TrouveLesVoisins;           // Utilise l'ancienne méthode (qui gère déjà CoinIn)
    hoPointyTop: TrouveLesVoisinsPointyTop;  // Utilise la nouvelle méthode complète
  end;
  NettoyerVoisinagesExempts;
end;

end.

