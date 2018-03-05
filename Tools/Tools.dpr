program Tools;

{$APPTYPE CONSOLE}

uses
  WinApi.WIndows,
  Vcl.Graphics,
  System.Sysutils,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ;

{$R *.res}

function CreateBmp(AText: string; R, G, B: Byte; ASaveFileName: string): Boolean;
  function HasColor(clr: TGPColor; del255: Boolean = true): Boolean;
  var A, R, G, B: ARGB;
  begin
    A := GetAlpha(clr);
    R := GetRed(clr);
    G := GetGreen(clr);
    B := GetBlue(clr);
    Result := (A <> 0) and (((not del255) and (R = 255) and (G = 255) and (B=255)) or (R < 255) or (G < 255) or (B < 255) );
  end;

  function RemoveBlank(bmp: TGPBitmap; Top: Boolean = true; Left: Boolean = true; Right: Boolean = true; Bottom: Boolean = true; del255: Boolean = true): TGPBitmap;
  var
    num, num2, num3, num4, i, j: Integer;
    clr: TGPColor;
    flag: Boolean;
  begin
    num := 0;
    num2 := bmp.GetHeight - 1;
    clr := 0;
    if (Top) then
    begin
      for i := 0 to bmp.GetHeight - 1 do
      begin
        flag := false;
        for j := 0 to bmp.GetWidth -1 do
        begin
          bmp.GetPixel(j, i, clr);
          if (HasColor(clr, del255)) then
          begin
            flag := True;
            Break;
          end;
        end;
        if (flag) then
        begin
          num := i;
          Break;
        end;
      end;
    end;
    if (Bottom) then
    begin
      for i := bmp.GetHeight - 1 downto 0 do
      begin
        flag := false;
        for j := 0 to bmp.GetWidth - 1 do
        begin
          bmp.GetPixel(i, j, clr);
          if HasColor(clr, del255) then
          begin
            flag := true;
            break;
          end;
        end;
        if (flag) then
        begin
          num2 := i;
          break;
        end;
      end;
    end;
    num3 := 0;
    num4 := bmp.GetWidth() - 1;
    if (Left) then
    begin
      for i := 0 to bmp.GetWidth - 1 do
      begin
        flag := false;
        for j := 0 to bmp.GetHeight - 1 do
        begin
          bmp.GetPixel(i, j, clr);
          if HasColor(clr, del255) then
          begin
            flag := true;
            break;
          end;
        end;
        if (flag) then
        begin
          num3 := i;
          break;
        end;
      end;
    end;
    if (Right) then
    begin
      for i := bmp.GetWidth - 1 downto 0 do
      begin
        flag := false;
        for j := 0 to bmp.GetHeight - 1 do
        begin
          bmp.GetPixel(i, j, clr);
          if HasColor(clr, del255) then
          begin
            flag := true;
            break;
          end;
        end;
        if (flag) then
        begin
          num4 := i;
          break;
        end;
      end;
    end;
    Result := bmp.Clone(MakeRect(num3, num, num4 + 1 - num3, num2 + 1 - num), bmp.GetPixelFormat);
  end;
var
  vFont: TGPFont;
  vBrush: TGPSolidBrush;
  vBitmap, vBitmap2: TGPBitmap;
  vColor: TGPColor;
  sRoleName: string;
  vGraphis: TGPGraphics;
  I, iNum, iLastX: Integer;
  vBitList: TArray<TGPBitmap>;
  vBmp: TBitmap;
  hBit: HBITMAP;
begin
  Result := False;
  SetLength(vBitList, 0);
  vFont := TGPFont.Create('ËÎÌו', 12.0, FontStyleRegular, UnitPixel);
  vColor := MakeColor(R, G, B);
  vBrush := TGPSolidBrush.Create(vColor);
  sRoleName := Trim(AText);
  iNum := 0;
  for I := 1 to Length(sRoleName) do
  begin
    vBitmap := TGPBitmap.Create(30, 14);
    vGraphis := TGPGraphics.Create(vBitmap);
    try
      vGraphis.SetSmoothingMode(SmoothingModeDefault);
      vGraphis.SetInterpolationMode(InterpolationModeHighQualityBicubic);
      vGraphis.SetCompositingQuality(CompositingQualityHighQuality);
      //if sRoleName[I] = 'j' then
      //  vGraphis.DrawString(string(''), -1, vFont, MakePoint(0.0, 0.0), vBrush)
      //else
        vGraphis.DrawString(string(sRoleName[I]), -1, vFont, MakePoint(0.0, 0.0), vBrush);
      vBitmap := RemoveBlank(vBitmap, False, True, True, False, False);
      iNum := iNum + vBitmap.GetWidth + 1;
      SetLength(vBitList, Length(vBitList) + 1);
      vBitList[High(vBitList)] := vBitmap;
    finally
      FreeAndNil(vGraphis);
    end;
  end;
  vBitmap2 := TGPBitmap.Create(iNum + 1, 14);
  vGraphis := TGPGraphics.Create(vBitmap2);
  vBmp := TBitmap.Create;
  iLastX := 1;
  try
    for vBitmap in vBitList do
    begin
      vGraphis.DrawImage(vBitmap, MakePoint(iLastX, 1));
      iLastX := iLastX + vBitmap.GetWidth + 1;
    end;
    vBitmap2.GetHBITMAP(aclBlack, hBit);
    vBmp.Handle := hBit;
    vBmp.PixelFormat := pf24bit;
    vBmp.SaveToFile(ASaveFileName);
    //DebugInfo('MS - RoleBmp:%s', [ASaveFileName]);
  finally
    FreeAndNil(vBitmap);
    FreeAndNil(vBmp);
    FreeAndNil(vGraphis);
  end;
  Result := True;
end;

function CreateRoleBmp(ARoleName: string; ASaveFileName: string): Boolean;
begin
   Result := CreateBmp(ARoleName, 209, 185, 148, ASaveFileName);
end;

var
  sContent, sFile: string;
  iR, iG, iB: Integer;

begin
  try
  //Application.MainFormOnTaskbar := True;
  //Application.CreateForm(TForm1, Form1);
  sContent := ParamStr(1);
  iR := StrToIntDef(ParamStr(2), 0);
  iG := StrToIntDef(ParamStr(3), 0);
  iB := StrToIntDef(ParamStr(4), 0);
  sFile := ParamStr(5);
  CreateBmp(sContent, iR, iG, iB, sFile);
  except

  end;
end.
