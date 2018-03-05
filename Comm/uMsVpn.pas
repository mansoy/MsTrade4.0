unit uMsVpn;

interface 

uses 
  Windows, SysUtils;

type
 GUID = record
  Data1: Integer;
  Data2: ShortInt;
  Data3: ShortInt;
  Data4: array[0..7] of Byte;
end;
type
  TRasIPAddr = record
     a: byte;
     b: byte;
     c: byte;
     d: byte;
  end;

  LPRasDialExtensions = ^TRasDialExtensions;
  TRasDialExtensions = record
    dwSize : LongInt;
    dwfOptions : LongInt;
    hwndParent : HWnd;
    reserved : LongInt;
  end;

type
 TRasEntry = record
  dwSize,
  dwfOptions,
  dwCountryID,
  dwCountryCode          : Longint;
  szAreaCode             : array[0.. 10] of Byte;
  szLocalPhoneNumber     : array[0..128] of Byte;
  dwAlternatesOffset     : Longint;
  ipaddr,
  ipaddrDns,
  ipaddrDnsAlt,
  ipaddrWins,
  ipaddrWinsAlt          : TRasIPAddr;
  dwFrameSize,
  dwfNetProtocols,
  dwFramingProtocol      : Longint;
  szScript               : Array [0..259] of Byte;
  szAutodialDll          : Array [0..259] of Byte;
  szAutodialFunc         : Array [0..259] of Byte;
  szDeviceType           : Array [0..16] of Byte;
  szDeviceName           : Array [0..128] of Byte;
  szX25PadType           : Array [0..32] of Byte;
  szX25Address           : Array [0..200] of Byte;
  szX25Facilities        : Array [0..200] of Byte;
  szX25UserData          : Array [0..200] of Byte;
  dwChannels,
  dwReserved1,
  dwReserved2,
  dwSubEntries,
  dwDialMode,
  dwDialExtraPercent,
  dwDialExtraSampleSeconds,
  dwHangUpExtraPercent,
  dwHangUpExtraSampleSeconds,
  dwIdleDisconnectSeconds,
  dwType,
  dwEncryptionType,
  dwCustomAuthKey       : Longint;
  guidId                : GUID;
  szCustomDialDll       : Array [0..259] of Byte;
  dwVpnStrategy,
  dwfOptions2,
  dwfOptions3           : Longint;
  szDnsSuffix           : Array [0..255] of Byte;
  dwTcpWindowSize       : Longint;
  szPrerequisitePbk     : Array [0..259] of Byte;
  szPrerequisiteEntry   : Array [0..256] of Byte;
  dwRedialCount,
  dwRedialPause         : Longint;
end;

TRasCredentialsA = record
  dwSize, dwMask: Longint;
  szUserName: array[0..256] of Byte;
  szPassword: array[0..256] of Byte;
  szDomain: array[0..15] of Byte;
end;

//LPRasDialParamsA = ^TRasDialParamsA;
//	TRasDialParamsA = record
//		dwSize : LongInt;
//		szEntryName : array[0..RAS_MaxEntryName] of AnsiChar;
//		szPhoneNumber : array[0..RAS_MaxPhoneNumber] of AnsiChar;
//		szCallbackNumber : array[0..RAS_MaxCallbackNumber] of AnsiChar;
//		szUserName : array[0..UNLEN] of AnsiChar;
//		szPassword : array[0..PWLEN] of AnsiChar;
//		szDomain : array[0..DNLEN] of AnsiChar;
//	end;

function RasSetEntryPropertiesA(lpszPhonebook, lpszEntry: PAnsichar; lpRasEntry: Pointer; dwEntryInfoSize: LongInt;lpbDeviceInfo:Pointer;dwDeviceInfoSize: Longint): Longint; stdcall;
function RasSetCredentialsA(lpszPhoneBook, lpszEntry: PAnsichar; lpCredentials: Pointer; fClearCredentials: Longint): Longint; stdcall;
function RasDialA(lpRasDialExt: LPRasDialExtensions; lpszPhoneBook: PAnsiChar; var Params: TRasCredentialsA; dwNotifierType: Longint; lpNotifier: Pointer; var RasConn: LongInt): Longint; stdcall;
function Create_VPN_Connection(sEntryName, sServer, sUsername, sPassword: AnsiString): Boolean;

implementation

function RasSetEntryPropertiesA; external 'Rasapi32.dll' name 'RasSetEntryPropertiesA';
function RasSetCredentialsA; external 'Rasapi32.dll' name 'RasSetCredentialsA';
function RasDialA; external 'Rasapi32.dll' name 'RasDialA';


function Create_VPN_Connection(sEntryName, sServer, sUsername, sPassword: AnsiString): Boolean;
var
  sDeviceName, sDeviceType: AnsiString;
  re: TRasEntry;
  rc: TRasCredentialsA;
  hRAS: Longint;
begin
  sDeviceName := 'WAN 微型端口 (PPTP)';
  sDeviceType := 'VPN';
  with re do
  begin
    Result := False;
    ZeroMemory(@re,SizeOf(re));
    dwSize := Sizeof(re);
    dwType := 2; //5;
    dwfOptions := 67110160; //1024262928-16;
    StrCopy(@szDeviceName[0], PansiChar(sDeviceName));
    StrCopy(@szDeviceType[0], PansiChar(sDeviceType));
    StrCopy(@szLocalPhoneNumber[0], PansiChar(sServer));
    dwFramingProtocol := 1;
    dwfNetProtocols := 4;
    dwVpnStrategy := 1;

    dwCountryCode := 86;
    dwCountryID := 86;
    dwDialExtraPercent := 75;
    dwDialExtraSampleSeconds := 120;
    dwDialMode := 1;
    dwEncryptionType := 0;

    dwfOptions2 := 367;

    dwHangUpExtraPercent := 10;
    dwHangUpExtraSampleSeconds := 120;
    dwRedialCount := 3;
    dwRedialPause := 60;

    dwEncryptionType := 3;  //0 无  1 VPN 默认值 3 拨号默认值 可选
  end;
  with rc do
  begin
    ZeroMemory(@rc,Sizeof(rc));
    dwSize := sizeof(rc);
    dwMask := 11;
    StrCopy(@szUserName[0],PansiChar(sUsername));
    StrCopy(@szPassword[0],PansiChar(sPassword));
    //StrCopy(@szDomain[0],PansiChar('PPTP'));
  end;
  if RasSetEntryPropertiesA(Nil, PAnsiChar(sEntryName),@re, SizeOf(re), nil, 0)=0 then
  if RasSetCredentialsA(Nil, PAnsiChar(sEntryName),@rc,0) = 0 then
  Result := True;

  //Result := RasDialA(nil, nil, rc, nil, nil, hRAS) = 0;
end;

//procedure TVpnForm.Button1Click(Sender: TObject);
//var
// sServer, sEntryName, sUsername, sPassword: string;
//begin
//  //WinExec('rasdial '+'vpn 1 17 /domain:PPTP',SW_hide);
//  //Exit;
//  WinExec('rasphone.exe   -h   '+'vpn',SW_SHOWNORMAL);
//  sEntryName := 'VPN';
//  sServer := ServerIPEd.Text;
//  sUsername := UserEd.Text;
//  sPassword := PwdEd.Text;
//  if Create_VPN_Connection(sEntryName, sServer, sUsername, sPassword) then
//  begin
// // Application.MessageBox('VPN连接建立成功!','VPN连接',MB_OK+MB_ICONWARNING+MB_TOPMOST);
// // WinExec('rasphone.exe   -h   '+'vpn',SW_SHOWNORMAL);
//    WinExec('rasdial ' + 'vpn 1 17', SW_hide);
//  end
//  else
//  begin
//    Application.MessageBox('VPN连接建立失败!', 'VPN连接', MB_OK + MB_ICONWARNING + MB_TOPMOST);
//  end;
//end;
//
//
//
//procedure TVpnForm.Button2Click(Sender: TObject);
//begin
//  //WinExec('rasphone.exe   -r   '+'vpn',SW_SHOWNORMAL);
//  WinExec('rasphone.exe   -h   '+'vpn',SW_SHOWNORMAL);
//end;

end.
