unit SwapTrackedFemFaction;

var
  OldFaction, NewFaction: IInterface;

function FindFactionByEditorID(const EditorID: string): IInterface;
var
  i: integer;
  f, grp, rec: IInterface;
begin
  Result := nil;
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
    grp := GroupBySignature(f, 'FACT');
    if Assigned(grp) then begin
      rec := MainRecordByEditorID(grp, EditorID);
      if Assigned(rec) then begin
        Result := rec;
        exit;
      end;
    end;
  end;
end;

function Initialize: integer;
begin
  OldFaction := FindFactionByEditorID('_JSW_SUB_TrackedFemFaction');
  NewFaction := FindFactionByEditorID('FMA_TrackedFemFaction');

  if not Assigned(OldFaction) then begin
    AddMessage('ERROR: _JSW_SUB_TrackedFemFaction not found in loaded files.');
    Result := 1;
    exit;
  end;

  if not Assigned(NewFaction) then begin
    AddMessage('ERROR: FMA_TrackedFemFaction not found in loaded files.');
    Result := 1;
    exit;
  end;

  AddMessage('Ready: swapping faction references in condition parameters.');
  Result := 0;
end;

function SwapFactionLink(elem: IInterface): boolean;
var
  linked: IInterface;
begin
  Result := False;
  if not Assigned(elem) then exit;
  try
    linked := LinksTo(elem);
  except
    exit;
  end;

  if Assigned(linked) and (GetEditValue(linked) = GetEditValue(OldFaction)) then begin
    SetEditValue(elem, GetEditValue(NewFaction));
    Result := True;
  end;
end;

function ProcessConditionContainer(conds, parent: IInterface): boolean;
var
  i: integer;
  cond, comp, param1, param2: IInterface;
  swapped: boolean;
begin
  Result := False;
  if not Assigned(conds) then exit;

  for i := 0 to ElementCount(conds) - 1 do begin
    cond := ElementByIndex(conds, i);

    comp := ElementByPath(cond, 'CTDA - CTDA\Comparison Value - Faction');
    param1 := ElementByPath(cond, 'CTDA - CTDA\Parameter #1');
    param2 := ElementByPath(cond, 'CTDA - CTDA\Parameter #2');

    swapped := SwapFactionLink(comp) or SwapFactionLink(param1) or SwapFactionLink(param2);
    if swapped then begin
      AddMessage(Name(parent) + ': swapped a condition faction.');
      Result := True;
    end;
  end;
end;

function Process(e: IInterface): integer;
begin
  Result := 0;
  ProcessConditionContainer(ElementByPath(e, 'Conditions'), e);
  ProcessConditionContainer(ElementByPath(e, 'CNAM - Conditions'), e);
end;

end.
