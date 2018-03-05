unit uWinIO;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils
  , VMProtectSDK;

const
  KBC_KEY_CMD = $64;
  KBC_KEY_DATA = $60;

function InitializeWinIo:Boolean;stdcall;external 'WinIo.dll' name'InitializeWinIo';
function InstallWinIoDriver(pszWinIoDriverPath:PWideChar; IsDemandLoaded:boolean=false):Boolean;stdcall;external 'WinIo.dll' name 'InstallWinIoDriver';
function RemoveWinIoDriver:Boolean;stdcall;external 'WinIo.dll' name 'RemoveWinIoDriver';
function GetPortVal(PortAddr:Word; PortVal:PDWORD; bSize: Byte):Boolean;stdcall;external 'WinIo.dll' name 'GetPortVal';
function SetPortVal(PortAddr:Word; PortVal:DWord; bSize:Byte):Boolean;stdcall;external 'WinIo.dll' name 'SetPortVal';
function GetPhysLong(PhysAddr:PByte; PhysVal:PDWord):Boolean;stdcall;external 'WinIo.dll' name 'GetPhysLong';
function SetPhysLong(PhysAddr:PByte; PhysVal:DWord):Boolean;stdcall;external 'WinIo.dll' name 'SetPhysLong';
function MapPhysToLin(PhysAddr:PByte; PhysSize:DWord;PhysMemHandle:PHandle):PByte;stdcall;external 'WinIo.dll' name 'MapPhysToLin';
function UnMapPhysicalMemory(PhysMemHandle:THandle; LinAddr:PByte):Boolean;stdcall;external 'WinIo.dll' name 'UnmapPhysicalMemory';
procedure ShutdownWinIo;stdcall;external 'WinIo.dll' name'ShutdownWinIo';

procedure MsKeyPress(vKeyCode: Integer; AShift: Boolean = False);

function IoPressPwd(APwd: string; ADealy: Cardinal = 100): Boolean;
function IoPressKey(AKeyCode: Integer; AShift: Boolean = False): Boolean;

implementation

var
  GKeyMapLst    : TStringList;
  GKeyMapLstCode: TStringList;

procedure KBCWait4IBE; //µÈ´ý¼üÅÌ»º³åÇøÎª¿Õ
var
  dwVal:DWord;
begin
  VMProtectBeginUltra('KBCWait4IBE');
  repeat
    GetPortVal($64,@dwVal,1);
  until (dwVal and $2)=0;
  VMProtectEnd;
end;

procedure MyKeyDown(vKeyCoad:Integer);
var
  btScancode:DWord;
begin
  VMProtectBeginUltra('MyKeyDown');
  try
    btScancode:=MapVirtualKey(vKeyCoad, 0);
    KBCWait4IBE;
    SetPortVal(KBC_KEY_CMD, $D2, 1);
    KBCWait4IBE;
    //SetPortVal(KBC_KEY_DATA, $E2, 1);
    //KBCWait4IBE;
    SetPortVal(KBC_KEY_CMD, $D2, 1);
    KBCWait4IBE;
    SetPortVal(KBC_KEY_DATA, btScancode, 1);
  finally
    VMProtectEnd;
  end;
end;

procedure MyKeyUp(vKeyCoad:Integer);
var
  btScancode:DWord;
begin
  VMProtectBeginUltra('MyKeyUp');
  try
    btScancode:=MapVirtualKey(vKeyCoad, 0);
    KBCWait4IBE;
    SetPortVal(KBC_KEY_CMD, $D2, 1);
    KBCWait4IBE;
    //SetPortVal(KBC_KEY_DATA, $E2, 1);
    //KBCWait4IBE;
    SetPortVal(KBC_KEY_CMD, $D2, 1);
    KBCWait4IBE;
    SetPortVal(KBC_KEY_DATA, (btScancode or $80), 1);
  finally
    VMProtectEnd;
  end;
end;

procedure MsKeyPress(vKeyCode: Integer; AShift: Boolean);
begin
  if AShift then
  begin
    MyKeyDown(VK_SHIFT);
    Sleep(100);
  end;
  MyKeyDown(vKeyCode);
  Sleep(100);
  MyKeyUp(vKeyCode);
  if AShift then
  begin
    Sleep(100);
    MyKeyUp(VK_SHIFT);
  end;
end;

function InitKeyMap: Boolean;
begin
  VMProtectBeginUltra('InitKeyMap');
  try
    GKeyMapLst.Clear;
    GKeyMapLst.Values['~'] := '`';
    GKeyMapLst.Values['!'] := '1';
    GKeyMapLst.Values['@'] := '2';
    GKeyMapLst.Values['#'] := '3';
    GKeyMapLst.Values['$'] := '4';
    GKeyMapLst.Values['%'] := '5';
    GKeyMapLst.Values['^'] := '6';
    GKeyMapLst.Values['&'] := '7';
    GKeyMapLst.Values['*'] := '8';
    GKeyMapLst.Values['('] := '9';
    GKeyMapLst.Values[')'] := '0';
    GKeyMapLst.Values['_'] := '-';
    GKeyMapLst.Values['+'] := '=';
    GKeyMapLst.Values['{'] := '[';
    GKeyMapLst.Values['}'] := ']';
    GKeyMapLst.Values['|'] := '\';
    GKeyMapLst.Values[':'] := ';';
    GKeyMapLst.Values['"'] := '''';
    GKeyMapLst.Values['<'] := ',';
    GKeyMapLst.Values['>'] := '.';
    GKeyMapLst.Values['?'] := '/';
  finally
    VMProtectEnd;
  end;
end;

function InitKeyMapCode: Boolean;
begin
  VMProtectBeginUltra('InitKeyMapCode');
  try
    GKeyMapLstCode.Values['~'] := '192';
    GKeyMapLstCode.Values['_'] := '189';
    GKeyMapLstCode.Values['+'] := '187';
    GKeyMapLstCode.Values['{'] := '219';
    GKeyMapLstCode.Values['}'] := '221';
    GKeyMapLstCode.Values['|'] := '220';
    GKeyMapLstCode.Values[':'] := '186';
    GKeyMapLstCode.Values['"'] := '222';
    GKeyMapLstCode.Values['<'] := '188';
    GKeyMapLstCode.Values['>'] := '190';
    GKeyMapLstCode.Values['?'] := '191';

    GKeyMapLstCode.Values['`'] := '192';
    GKeyMapLstCode.Values['-'] := '189';
    GKeyMapLstCode.Values['='] := '187';
    GKeyMapLstCode.Values['['] := '219';
    GKeyMapLstCode.Values[']'] := '221';
    GKeyMapLstCode.Values['\'] := '220';
    GKeyMapLstCode.Values[';'] := '186';
    GKeyMapLstCode.Values['''']:= '222';
    GKeyMapLstCode.Values[','] := '188';
    GKeyMapLstCode.Values['.'] := '190';
    GKeyMapLstCode.Values['/'] := '191';

    GKeyMapLstCode.Values['a'] := '65';
    GKeyMapLstCode.Values['b'] := '66';
    GKeyMapLstCode.Values['c'] := '67';
    GKeyMapLstCode.Values['d'] := '68';
    GKeyMapLstCode.Values['e'] := '69';
    GKeyMapLstCode.Values['f'] := '70';
    GKeyMapLstCode.Values['g'] := '71';
    GKeyMapLstCode.Values['h'] := '72';
    GKeyMapLstCode.Values['i'] := '73';
    GKeyMapLstCode.Values['j'] := '74';
    GKeyMapLstCode.Values['k'] := '75';
    GKeyMapLstCode.Values['l'] := '76';
    GKeyMapLstCode.Values['m'] := '77';
    GKeyMapLstCode.Values['n'] := '78';
    GKeyMapLstCode.Values['o'] := '79';
    GKeyMapLstCode.Values['p'] := '80';
    GKeyMapLstCode.Values['q'] := '81';
    GKeyMapLstCode.Values['r'] := '82';
    GKeyMapLstCode.Values['s'] := '83';
    GKeyMapLstCode.Values['t'] := '84';
    GKeyMapLstCode.Values['u'] := '85';
    GKeyMapLstCode.Values['v'] := '86';
    GKeyMapLstCode.Values['w'] := '87';
    GKeyMapLstCode.Values['x'] := '88';
    GKeyMapLstCode.Values['y'] := '89';
    GKeyMapLstCode.Values['z'] := '90';
  finally
    VMProtectEnd;
  end;
end;

function MsPressPwd(APwd: string; ADealy: Cardinal): Boolean;
var
  nLen, i, iIndex: Integer;
  bCode: Byte;
  bShift: Boolean;
{$IFDEF _MS_DEBUG}
  s: string;
{$ENDIF}
begin
  nLen := Length(APwd);
  if( nLen <= 0 ) then Exit;
  for i := 1 to nLen do
  try
    VMProtectBeginUltra('MsPressPwd');
    try
      Sleep(ADealy);
      bShift := False;
      bCode := Word(APwd[i]);
      iIndex := GKeyMapLst.IndexOfName(APwd[i]);
      if iIndex >= 0 then
      begin
        {$IFDEF _MS_DEBUG}
        s := GKeyMapLst.Values[APwd[i]];
        s := GKeyMapLst.Values[APwd[i]][1];
        {$ENDIF}
        bCode := Word(GKeyMapLst.Values[APwd[i]][1]);
        bShift := True;
      end;

      if (bCode >= 65) and (bCode <= 90) then
        bShift := True;

      iIndex := GKeyMapLstCode.IndexOfName(APwd[i]);
      if iIndex >= 0 then
      begin
        bCode := StrToIntDef(GKeyMapLstCode.Values[APwd[i]], 0);
      end;
    finally
      VMProtectEnd;
    end;

    uWinIO.MsKeyPress(bCode, bShift);
  except
  end;
end;

function IoPressPwd(APwd: string; ADealy: Cardinal): Boolean;
begin
  if GKeyMapLst = nil then
    GKeyMapLst := TStringList.Create;
  if GKeyMapLstCode = nil then
    GKeyMapLstCode := TStringList.Create;
  try
    InitKeyMap;
    InitKeyMapCode;
    MsPressPwd(APwd, ADealy);
  finally
    FreeAndNil(GKeyMapLst);
    FreeAndNil(GKeyMapLstCode);
  end;
  Sleep(500);
end;

function IoPressKey(AKeyCode: Integer; AShift: Boolean): Boolean;
begin
  Result := False;
  try
    uWinIO.MsKeyPress(AKeyCode, AShift);
  except
  end;
  Result := True;
end;

initialization
  InitializeWinIo;

finalization
  ShutdownWinIo;

end.
