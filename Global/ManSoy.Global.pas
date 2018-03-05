unit ManSoy.Global;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Winapi.Messages, Winapi.TlHelp32,
  Winapi.WinSvc, System.DateUtils, System.Win.Registry, WinApi.Imm, Winapi.WinInet
  , Winapi.PsAPI, Winapi.ShlObj;

  {----------------功能:加载驱动程序---------------
   参数:sztheDriverName :驱动程序完成路径.
        szSvrName       :驱动程序名称.
  --------------------------------------------------}
  function InstallDriver(sztheDriverName,szSvrName:string):Boolean;
  {----------------功能:卸载驱动程序----------------
     参数:szSvrName        :驱动程序名称.
  --------------------------------------------------}
  function UnInstallDriver(szSvrName:string):Boolean;

  function Is2KXp(): Boolean;

  function IIF(lExp:boolean; vExp1,vExp2 : variant): variant;

  procedure MouseDown(hDes: HWND; dwPoint: DWORD; IsAttach: Boolean = True); overload;
  procedure MouseDown(hDes: HWND; wX, wY: Integer; IsAttach: Boolean = True); overload;
  procedure MNMouseDown(hDes: HWND; wX, wY: Integer);
  procedure DBClick(hDes: HWND; wX, wY: Integer);

  procedure PressKey(hDes: HWND; vk: Byte; bShift: Boolean = False);
  procedure PressBack(hDes: HWND; ATimes: Cardinal = 1);
  procedure PressEnter(hDes: HWND);
  procedure PressStr(hDes: HWND; AText: string; ADealy: Cardinal = 20);

  //--串值化字符串--------------------------------
  function StrToHexStr(const S: string): string;
  function HexStrToStr(const S: string): string;

  {$REGION '剪贴板操作'}
  function WriteClipboard(AStr: String): Boolean;
  function ReadClipboard(var AStr: AnsiString): Boolean;
  {$ENDREGION}

  {$REGION '注册COM'}
  function RegisterOleFile(strOleFileName : string; AReg: Boolean = True): Boolean;
  {$ENDREGION}

  //--
  function EnabledDebugPrivilege(AName: string = 'SeDebugPrivilege'; const Enabled : Boolean = True) : Boolean;
  function GetProcessIdByHandle(AhWnd: HWND): DWORD;
  function GetProcessName(dwPID: DWORD): string; overload;
  function GetProcessName(hWindow: HWND): string; overload;
  function GetProcessIdByName(AAppName: PWideChar): DWORD; overload;
  function GetProcessIdByName(const AFilename: string; const PathMatch: Boolean = False): DWORD; overload;
  function GetWindowHandleByPid(APid: DWORD): HWND;

  function KillProcessByHandle(AHandle: THandle): Boolean;
  function KillProcessByID(APid: DWORD): Boolean;

  function GetTimeStamp: Int64;

  function MyWinExec(ACmd: string; AVisible: Boolean = False): Boolean;

  {$REGION '路径'}
  function GetPath(FID: Integer): string;
  function GetAppdataPath: string;
  {$ENDREGION}

{$REGION '远线程'}
  //--远线程
  function InjectDll(const DllFullPath: string; const dwRemoteProcessId: Cardinal): Boolean;
  function UnInjectDll(const DllFullPath: string; const dwRemoteProcessId: Cardinal): Boolean;

  //--注册表
  function RegisterAppInitDLLs(ADllPath: string; AReg: Boolean = True): Boolean;

  //--输入法
const
  GUID_SHAREMEMORY='{5E183D3E-049A-4CDC-BA47-C71342BF6663}';
  GUID_LOADDLL='{DA97DEE2-6393-480E-80C0-F053568C5B38}';
  GUID_UNLOADDLL='{1E99EEB2-29B9-469B-8C90-559B92F42A29}';
type
  //用来设置注入参数的共享区域
  PImeInjectShareMemory = ^TImeInjectShareMemory;
  TImeInjectShareMemory = packed record
    DllName: array[0..MAX_PATH] of Char;//注入的dll路径
    ProcessId: DWORD;//注入的进程ID
  end;

  //设置注入参数，由控制程序调用
  procedure CreateImeInjectShareMemory(DllName: string; ProcessId: DWORD; var FileMapHandle:THandle);

  //获取注入参数，由输入法dll调用
  procedure GetImeInjectShareMemory(ImeInjectShareMemory:PImeInjectShareMemory);

  function ImeInject(AhGame: HWND; AdllPath: string): Boolean;
{$ENDREGION}

{$REGION '打印调试信息'}
  function DebugInf(const Format: string; const Args: array of const): Boolean;
{$ENDREGION}

  function GetGUID: string;
  function GetOnlyOneString(): string;

  function IsConnInternet: Boolean;

implementation

function HexStrToStr(const S: string): string;
var
  i, iIndex, iCount: Integer;
  vBuff: TBytes;
  vLst: TStringList;
  ansiStr: AnsiString;
  sTmp: string;
begin
  Result := '';
  if s = '' then Exit;
  ansiStr := AnsiString(S);
  iCount := Length(ansiStr) div 2;
  SetLength(vBuff, iCount);
  for I := 1 to Length(ansiStr) do begin
    if I mod 2 <> 0 then Continue;
    iIndex := (I div 2) - 1;
    sTmp := string('$' + ansiStr[I-1] + ansiStr[I]);
    vBuff[iIndex] := StrToIntDef(sTmp, 0);
  end;
  Result := String(StringOf(vBuff));
end;

function StrToHexStr(const S: string): string;
var
  i: Integer;
  vBuff: TBytes;
begin
  Result := '';
  if s = '' then Exit;
  vBuff := BytesOf(AnsiString(s));
  for I := 0 to Length(vBuff) - 1 do begin
    Result := Result  + System.SysUtils.IntToHex(vBuff[i], 2);
    //if (Result <> '') and (i < Length(vBuff) - 1) then Result := Result + '|';
  end;
end;

function Is2KXp(): Boolean;
var
  OSVer: TOSVersionInfo;
begin
  Result := False;
  OSVer.dwOSVersionInfoSize := Sizeof(TOSVersionInfo);
  if GetVersionEx(OSVer) then
  begin
    if (OSVer.dwPlatformId = VER_PLATFORM_WIN32_NT) then
    begin
      if (OSVer.dwMajorVersion = 5) and ((OSVer.dwMinorVersion = 0) or (OSVer.dwMinorVersion = 1)) then
      begin
        Result := True;
      end;
    end;
  end;
end;

{$REGION '安装驱动'}
function InstallDriver(sztheDriverName,szSvrName:string):Boolean;
var
    hServiceMgr,hServiceTwdm:SC_HANDLE;
    szDir:array[0..1023]of char;
    lpsztheDriverName,p:PChar;
begin
    ZeroMemory(@szDir,1024);
    strcopy(szDir,Pchar(sztheDriverName));
    lpsztheDriverName:=@szDir;
    {打开服务控制管理器}
    hServiceMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS );

    if hServiceMgr=0 then
      begin
        {OpenSCManager() Faild.}
        Result:=False;
        Exit;
      end;

    hServiceTwdm:=CreateService(hServiceMgr,
                                PChar(szSvrName),       {SYSTEM\CurrentControlSet\Services驱动程序的在注册表中的名字}
                                PChar(szSvrName),       {注册表驱动程序的 DisplayName 值}
                                SERVICE_ALL_ACCESS,     {加载驱动程序的访问权限}
                                SERVICE_KERNEL_DRIVER,{表示加载的服务是驱动程序}
                                SERVICE_DEMAND_START, {注册表驱动程序的 Start 值}
                                SERVICE_ERROR_IGNORE, {注册表驱动程序的 ErrorControl 值}
                                lpsztheDriverName,      {注册表驱动程序的 ImagePath 值}
                                nil,nil,nil,nil,nil);

    if hServiceTwdm=0 then
      begin
        if GetLastError()=ERROR_SERVICE_EXISTS then
          begin
            {Service Exists}
            hServiceTwdm:=OpenService(hServiceMgr,PChar(szSvrName),SERVICE_ALL_ACCESS);
            if hServiceTwdm=0 then
              begin
                CloseServiceHandle(hServiceMgr);
                Result:=False;
                Exit;
              end;
          end
        else
          begin
            CloseServiceHandle(hServiceMgr);
            Result:=False;
            Exit;
          end;
      end;

    {Start the drivers}
    if hServiceTwdm<>0 then
      begin
        if StartService(hServiceTwdm,0,p)=False then
          begin
            if ERROR_SERVICE_ALREADY_RUNNING=GetLastError() then
              begin
                {no real problem}
              end
            else
              begin
                CloseServiceHandle(hServiceMgr);
                CloseServiceHandle(hServiceTwdm);
                Result:=False;
                Exit;
              end;
          end;

        CloseServiceHandle(hServiceMgr);
        CloseServiceHandle(hServiceTwdm);
      end;

    Result:=True;
end;

function UnInstallDriver(szSvrName:string):Boolean;
var
    hServiceMgr,hServiceTwdm:SC_HANDLE;
    SvrSta:SERVICE_STATUS;
begin
    hServiceMgr:=OpenSCManager(nil,nil,SC_MANAGER_ALL_ACCESS );
    if hServiceMgr=0 then
      begin
        {OpenSCManager() Faild.}
        Result:=False;
        Exit;
      end;

    hServiceTwdm:=OpenService(hServiceMgr,PChar(szSvrName),SERVICE_ALL_ACCESS );
    if hServiceTwdm=0 then
      begin
        {OpenService() Faild.}
        CloseServiceHandle(hServiceMgr);
        Result:=False;
        Exit;
      end;

    {停止驱动程序,如果停止失败,只有重新启动才能,再动态加载。}
    if ControlService(hServiceTwdm,SERVICE_CONTROL_STOP,SvrSta)=False then
      begin
        {ControlService() Faild.}
        CloseServiceHandle(hServiceTwdm);
        CloseServiceHandle(hServiceMgr);
        Result:=False;
        Exit;
      end;
    {动态卸载驱动程序.}
    if DeleteService(hServiceTwdm)=False then
      begin
        {DeleteSrevice() Faild.}
        CloseServiceHandle(hServiceTwdm);
        CloseServiceHandle(hServiceMgr);
        Result:=False;
        Exit;
      end;

    CloseServiceHandle(hServiceTwdm);
    CloseServiceHandle(hServiceMgr);
    Result:=True;
end;
{$ENDREGION}

function IIF(lExp:boolean; vExp1,vExp2 : variant): variant;
begin
  if lExp then
    Result := vExp1
  else
    Result := vExp2 ;
end;

{$REGION '鼠标点击'}
procedure MouseDown(hDes: HWND; dwPoint: DWORD; IsAttach: Boolean = True);
begin
  if IsAttach then
    AttachThreadInput(GetCurrentThreadId(), GetWindowThreadProcessId(hDes, nil), TRUE);
  PostMessage(hDes, WM_MOUSEMOVE, 0, dwPoint);
  Sleep(20);
  PostMessage(hDes, WM_LBUTTONDOWN, 0, dwPoint);
  Sleep(20);
  PostMessage(hDes, WM_LBUTTONUP, 0, dwPoint);
  Sleep(20);
  if IsAttach then
    AttachThreadInput(GetCurrentThreadId(), GetWindowThreadProcessId(hDes, nil), FALSE);
end;

procedure MouseDown(hDes: HWND; wX, wY: Integer; IsAttach: Boolean = True); overload;
begin
  MouseDown(hDes, MAKELONG(wX, wY), IsAttach);
end;

procedure MNMouseDown(hDes: HWND; wX, wY: Integer);
var
  vPos: TPoint;
begin
  vPos.X := wX; vPos.Y := wY;
  if IsWindow(hDes) then begin
    Debuginf('MS - 原坐标： X：%d Y: %d', [vPos.X, vPos.Y]);
    ClientToScreen(hDes, vPos);
    Debuginf('MS - 新坐标： X：%d Y: %d', [vPos.X, vPos.Y]);
  end;
  SetCursorPos(vPos.X, vPos.Y);
  Sleep(300);
  mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);
  Sleep(20);
  mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);
end;

procedure DBClick(hDes: HWND; wX, wY: Integer);
begin
  //SendMessage(hDes, WM_LBUTTONDBLCLK, 0, MAKELONG(wX, wY));
  MNMouseDown(hDes, wX, wY);
  Sleep(20);
  MNMouseDown(hDes, wX, wY);
end;
{$ENDREGION}


procedure wmkeydown(hWnd: HWND; dwKeyCode: DWORD; dwFlags: DWORD);
var
  tmp: SmallInt;
  ch: WideChar;
  wParam: Longint;
  lParam: Longint;
begin
  ch := WideChar(dwKeyCode);
  tmp := VkKeyScan(ch);
  wParam := tmp; //tmp and $FF;
  lParam := 1;
  lParam := lParam + MapVirtualKey(wParam, MAPVK_VK_TO_VSC) shl 16;
  //bool shift = (tmp & 0x0100) == 0x0100 ? true : false;
  //未考虑SHIFT，大小写的区分需通过SHIFT，注意设置第29位，可用Spy++捕获消息查看，此处只作备忘用
  PostMessage(hWnd, WM_KEYDOWN, wParam, lParam);
end;

	//
	//
procedure wmkeyup(hWnd: HWND; dwKeyCode: DWORD; dwFlags: DWORD);
var
  tmp: SHORT;
  ch: WideChar;
  wParam: Longint;
  lParam: Longint;
begin
	ch := WideChar(dwKeyCode);
  tmp := VkKeyScan(ch);
  wParam := tmp;// and $FF;
  lParam := 1;
  lParam := lParam + MapVirtualKey(wParam, MAPVK_VK_TO_VSC) shl 16;
  //bool shift = (tmp & 0x0100) == 0x0100 ? true : false;
  //未考虑SHIFT，大小写的区分需通过SHIFT，注意设置第29位，可用Spy++捕获消息查看，此处只作备忘用
  PostMessage(hWnd, WM_KEYUP, wParam, lParam);
end;

procedure PressKey(hDes: HWND; vk: Byte; bShift: Boolean);
begin
  //SetForegroundWindow(hDes);
	if (bShift) then wmkeydown(hDes, VK_SHIFT, 0);
	wmkeydown(hDes, vk, 0);
	Sleep(1);
	wmkeyup(hDes, vk, 0);
	Sleep(20);
  if (bShift) then begin
    Sleep(20);
		wmkeyup(hDes, VK_SHIFT, 0);
  end;
end;

procedure PressBack(hDes: HWND; ATimes: Cardinal);
var
  i: Integer;
begin
  for I := 0 to ATimes do begin
    Sleep(20);
    PressKey(hDes, VK_BACK);
  end;
end;

procedure PressEnter(hDes: HWND);
begin
  PressKey(hDes, VK_RETURN);
end;

procedure PressStr(hDes: HWND; AText: string; ADealy: Cardinal);
var
  nLen: Integer;
  i: Integer;
begin
  nLen := Length(AText);
  for I := 1 to nLen do begin
    Sleep(ADealy);
    PostMessage(hDes, WM_CHAR, WORD(AText[i]), 1);
  end;
end;

{$REGION '剪贴板操作'}
function WriteClipboard(AStr: String): Boolean;
var
  hMem:HGLOBAL;
  pStr: PAnsiChar;
begin
  hMem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, Length(AStr) * SizeOf(Char) + 1);
  pStr := GlobalLock(hMem);
  StrCopy(pStr, PAnsiChar(AnsiString(AStr)));
  try
    if OpenClipboard(0) then
    begin
      EmptyClipboard;
      SetClipboardData(CF_TEXT, hMem);
      CloseClipboard;
    end;
  finally
    GlobalUnlock(hMem);
    GlobalFree(hMem);
  end;
  Result := False;
end;

function ReadClipboard(var AStr: AnsiString): Boolean;
var
  hMem:HGLOBAL;
  pStr: PAnsiChar;
begin
  if IsClipboardFormatAvailable(CF_TEXT) then
  begin
    if OpenClipboard(0) then
    begin
      hMem := GetClipboardData(CF_TEXT);
      pStr := GlobalLock(hMem);
      AStr := AnsiString(pStr);
      GlobalUnlock(hMem);
    end;
  end;
  Result := True;
end;

{$ENDREGION}

{$REGION '注册COM'}
function RegisterOleFile(strOleFileName : string; AReg: Boolean): Boolean;
type
  TOleRegisterFunction = function : HResult;//注册或卸载函数的原型

var
  hLibraryHandle : THandle;//由LoadLibrary返回的DLL或OCX句柄
  hFunctionAddress: TFarProc;//DLL或OCX中的函数句柄，由GetProcAddress返回
  RegFunction : TOleRegisterFunction;//注册或卸载函数指针
begin
  Result := False;
  //打开OLE/DCOM文件，返回的DLL或OCX句柄
  hLibraryHandle := LoadLibrary(PCHAR(strOleFileName));
  if (hLibraryHandle > 0) then //DLL或OCX句柄正确
  try
    //返回注册函数的指针
    if AReg then
      hFunctionAddress := GetProcAddress(hLibraryHandle, pchar('DllRegisterServer'))
    else
      hFunctionAddress := GetProcAddress(hLibraryHandle, pchar('UnDllRegisterServer'));
    if (hFunctionAddress <> NIL) then begin //注册函数存在
      RegFunction := TOleRegisterFunction(hFunctionAddress);//获取操作函数的指针
      if RegFunction >= 0 then //执行注册或卸载操作，返回值>=0表示执行成功
        Result := true;
    end;
  finally
    FreeLibrary(hLibraryHandle);//关闭已打开的OLE/DCOM文件
  end;
end;
{$ENDREGION}

function EnabledDebugPrivilege(AName: string; const Enabled : Boolean) : Boolean;
var
  hTk : THandle; { 打开令牌句柄 }
  rtnTemp : Dword; { 调整权限时返回的值 }
  TokenPri : TOKEN_PRIVILEGES;
const
  SE_DEBUG = 'SeDebugPrivilege'; { 查询值 }
begin
  Result := False;
  { 获取进程令牌句柄,设置权限 }
  if (OpenProcessToken(GetCurrentProcess(),TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hTk)) then
  begin
    TokenPri.PrivilegeCount := 1;
    { 获取Luid值 }
    if LookupPrivilegeValue(nil,PWideChar(AName),TokenPri.Privileges[0].Luid) then begin
      if Enabled then
        TokenPri.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
      else
        TokenPri.Privileges[0].Attributes := 0;
    end;

    rtnTemp := 0;
    { 设置新的权限 }
    Result := AdjustTokenPrivileges(hTk,False,TokenPri,sizeof(TokenPri),nil,rtnTemp);

    //Result := GetLastError = ERROR_SUCCESS;
    CloseHandle(hTk);
  end;
end;

function GetProcessIdByHandle(AhWnd: HWND): DWORD;
var
  dwPid: DWORD;
begin
  GetWindowThreadProcessId(AhWnd, dwPid);
  Result := dwPid;
end;

function GetProcessIdByName(AAppName: PWideChar): DWORD; overload;
var
  hTmp: HWND;
  tp  : TProcessEntry32;
begin
  Result := 0;
  hTmp := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  tp.dwSize := SizeOf(TProcessEntry32);
  if Process32First(hTmp, tp) then begin
    repeat
      //vExeName := UpperCase(string(tp.szExeFile));
      if lstrcmp(tp.szExeFile, AAppName) = 0 then begin
        Result := tp.th32ProcessID;
        CloseHandle(hTmp);;
      end;
    until not Process32Next(hTmp, tp);
  end;

end;

function GetProcessName(dwPID: DWORD): string;
var
  hTmp: HWND;
  tp  : TProcessEntry32;
begin
  Result := '';
  hTmp := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  tp.dwSize := SizeOf(TProcessEntry32);
  if Process32First(hTmp, tp) then begin
    repeat
      Sleep(1);
      if tp.th32ProcessID = dwPID then begin
        Result := string(tp.szExeFile);
        CloseHandle(hTmp);
        Exit;
      end;
    until not Process32Next(hTmp, tp);
  end;
end;

function GetProcessName(hWindow: HWND): string;
var
  pid: Cardinal;
  pHandle: THandle;
  buf: array[0..MAX_PATH] of Char;
begin
  {先获取进程 ID}
  GetWindowThreadProcessId(hWindow, @pid);
  {再获取进程句柄}
  pHandle := OpenProcess(PROCESS_ALL_ACCESS, False, pid);
  {获取进程路径}
  GetModuleFileNameEx(pHandle, 0, buf, Length(buf));
  //GetModuleFileName(pHandle, buf, Length(buf));
  CloseHandle(pHandle);
  Result := buf;
end;

{ 列举进程 }
function GetProcessIdByName(const AFilename: string; const PathMatch: Boolean): DWORD; overload;
var
  lppe: TProcessEntry32;
  SsHandle: Thandle;
  FoundAProc, FoundOK: boolean;
begin
  Result :=0;
  { 创建系统快照 }
  SsHandle := CreateToolHelp32SnapShot(TH32CS_SnapProcess, 0);

  { 取得快照中的第一个进程 }
  { 一定要设置结构的大小,否则将返回False }
  lppe.dwSize := sizeof(TProcessEntry32);
  FoundAProc := Process32First(Sshandle, lppe);
  while FoundAProc do
  begin
    { 进行匹配 }
    if PathMatch then
      FoundOK := AnsiStricomp(lppe.szExefile, PChar(AFilename)) = 0
    else
      FoundOK := AnsiStricomp(PChar(ExtractFilename(lppe.szExefile)), PChar(ExtractFilename(AFilename))) = 0;
    if FoundOK then
    begin
      Result := lppe.th32ProcessID;
      Break;
    end;
    { 未找到,继续下一个进程 }
    FoundAProc := Process32Next(SsHandle, lppe);
  end;
  CloseHandle(SsHandle);
end;

function GetWindowHandleByPid(APid: DWORD): HWND;
var
  h: HWND;
  dwPid, dwTid : DWORD;
begin
  h := GetTopWindow(0);
  while IsWindow(h) do
  begin
    dwPid := 0;
    dwTid := GetWindowThreadProcessId(h, dwPid);
    if dwTid <> 0  then
    begin
      if dwPid = APid then
      begin
        Result := h;
        Exit;
      end;
    end;
    h := GetNextWindow(h, GW_HWNDNEXT);
  end;
end;

function KillProcessByHandle(AHandle: THandle): Boolean;
var
  dwProcessID: DWORD;
begin
  Result := False;
  try
    GetWindowThreadProcessId(AHandle, dwProcessID);
    Result := KillProcessByID(dwProcessID);
  except
  end;
end;

function KillProcessByID(APid: DWORD): Boolean;
var
  hProcess: THANDLE;
  dwExitCode: DWORD;
begin
  Result := False;
  try
    hProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, APid);
    if hProcess = 0 then Exit;
    GetExitCodeProcess(hProcess, dwExitCode);
    Result := TerminateProcess(hProcess, dwExitCode);
    CloseHandle(hProcess);
  except
  end;
end;

function GetTimeStamp: Int64;
var
  dJavaStart: TDateTime;
begin
  //java里的时间是从1970年1月1日0点到当前的间隔
  dJavaStart := EncodeDateTime( 1970, 1, 1, 0, 0, 0, 0 );
  Result := MilliSecondsBetween( Now, dJavaStart );
end;

function MyWinExec(ACmd: string; AVisible: Boolean = False): Boolean;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  dwExitCode: DWORD;
begin
  FillChar( StartUpInfo, SizeOf(StartUpInfo), $00 );
  StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
  if AVisible then
    StartUpInfo.wShowWindow := SW_SHOWNORMAL
  else
    StartUpInfo.wShowWindow := SW_HIDE;
  if CreateProcess( nil, PWideChar(ACmd), nil, nil, {运行批处理文件}
  False, IDLE_PRIORITY_CLASS, nil, nil, StartUpInfo,
  ProcessInfo ) then
  begin
      WaitForSingleObject(Processinfo.hProcess,INFINITE);
      GetExitCodeProcess(ProcessInfo.hProcess, dwExitCode);

      CloseHandle( ProcessInfo.hThread );
      CloseHandle( ProcessInfo.hProcess );
  end;
end;

{$REGION '路径'}
function GetPath(FID: Integer): string;
var
  pidl: PItemIDList;
  path: array[0..MAX_PATH] of Char;
begin
  SHGetSpecialFolderLocation(0, FID, pidl);
  SHGetPathFromIDList(pidl, path);
  Result := path;
  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
end;

function GetAppdataPath: string;
begin
  Result := 'C:\';
  Result := GetPath(CSIDL_APPDATA);
end;
{$ENDREGION}

{$REGION '远线程'}
function InjectDll(const DllFullPath: string; const dwRemoteProcessId: Cardinal): Boolean;
var
  hRemoteProcess, hRemoteThread: HWND;
  pszLibFileRemote: Pointer;
  pszLibAFileName: PWideChar;
  pfnStartAddr: TFNThreadStartRoutine;
  memSize, lpThread: Cardinal;
  WriteSize: Size_T;
begin
  Result := False;
  if EnabledDebugPrivilege then begin
    //--打开远程线程
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, False, dwRemoteProcessId);
    try
      // 为注入的dll文件路径分配内存大小,由于为WideChar,故要乘2
      GetMem(pszLibAFileName, Length(DllFullPath) * 2 + 1);
      // 之所以要转换成 WideChar, 是因为当DLL位于有中文字符的路径下时不会出错
      StringToWideChar(DllFullPath, pszLibAFileName, Length(DllFullPath) * 2 + 1);
      // 计算 pszLibAFilename 的长度，注意，是以字节为单元的长度
      memSize := (1 + lstrlenW(pszLibAFilename)) * SizeOf(WCHAR);
      //使用VirtualAllocEx函数在远程进程的内存地址空间分配DLL文件名空间
      pszLibFileRemote := VirtualAllocEx(hRemoteProcess, nil, memSize, MEM_COMMIT, PAGE_READWRITE);
      if Assigned(pszLibFileRemote) then begin
        //使用WriteProcessMemory函数将DLL的路径名写入到远程进程的内存空间
        //if WriteProcessMemory(hRemoteProcess, pszLibFileRemote, pszLibAFileName, memSize, WriteSize) then begin
        if WriteProcessMemory(hRemoteProcess, pszLibFileRemote, pszLibAFilename, memSize, WriteSize) then begin
          if memSize = WriteSize then begin
            lpThread := 0;
            // 计算LoadLibraryW的入口地址
            pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'), 'LoadLibraryW');
            // 启动远程线程LoadLbraryW,通过远程线程调用创建新的线程
            hRemoteThread := CreateRemoteThread(hRemoteProcess, nil, 0, pfnStartAddr, pszLibFileRemote, 0, lpThread);
            Result := hRemoteThread <> 0;
            CloseHandle(hRemoteThread);
          end;
        end;
      end;
    finally
      CloseHandle(hRemoteProcess);
    end;
  end;
end;

function UnInjectDll(const DllFullPath: string; const dwRemoteProcessId: Cardinal): Boolean;
// 进程注入和取消注入其实都差不多，只是运行的函数不同而已
var
  hRemoteProcess, hRemoteThread: THandle;
  pszLibFileRemote: PChar;
  pszLibAFilename: PwideChar;
  pfnStartAddr: TFNThreadStartRoutine;
  memSize, lpThreadId, dwHandle: Cardinal;
  WriteSize: Size_T;
begin
  Result := false;

  // 调整权限，使程序可以访问其他进程的内存空间
  if EnabledDebugPrivilege then
  begin
    //打开远程线程 PROCESS_ALL_ACCESS 参数表示打开所有的权限
    hRemoteProcess := OpenProcess(PROCESS_ALL_ACCESS, false, dwRemoteProcessId);

    try

      // 为注入的dll文件路径分配内存大小,由于为WideChar,故要乘2
      GetMem(pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // 之所以要转换成 WideChar, 是因为当DLL位于有中文字符的路径下时不会出错
      StringToWideChar(DllFullPath, pszLibAFilename, Length(DllFullPath) * 2 + 1);
      // 计算 pszLibAFilename 的长度，注意，是以字节为单元的长度
      memSize := (1 + lstrlenW(pszLibAFilename)) * SizeOf(WCHAR);

      //使用VirtualAllocEx函数在远程进程的内存地址空间分配DLL文件名空间
      pszLibFileRemote := VirtualAllocEx(hRemoteProcess, nil,
        memSize, MEM_COMMIT, PAGE_READWRITE);

      if Assigned(pszLibFileRemote) then
      begin
        //使用WriteProcessMemory函数将DLL的路径名写入到远程进程的内存空间
        if WriteProcessMemory(hRemoteProcess, pszLibFileRemote,
          pszLibAFilename, memSize, WriteSize) and
          (WriteSize = memSize) then
        begin
          // 计算GetModuleHandleW的入口地址
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'),
            'GetModuleHandleW');
          //使目标进程调用GetModuleHandleW，获得DLL在目标进程中的句柄
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil,
            0, pfnStartAddr, pszLibFileRemote, 0, lpThreadId);
          // 等待GetModuleHandle运行完毕
          WaitForSingleObject(hRemoteThread, INFINITE);
          // 获得GetModuleHandle的返回值,存在dwHandle变量中
          GetExitCodeThread(hRemoteThread, dwHandle);
          // 计算FreeLibrary的入口地址
          pfnStartAddr := GetProcAddress(LoadLibrary('Kernel32.dll'),
            'FreeLibrary');
          // 使目标进程调用FreeLibrary，卸载DLL
          hRemoteThread := CreateRemoteThread(hRemoteProcess, nil,
            0, pfnStartAddr, Pointer(dwHandle), 0, lpThreadId);
          // 等待FreeLibrary卸载完毕
          WaitForSingleObject(hRemoteThread, INFINITE);
          // 如果执行成功返回　True;
          if hRemoteProcess <> 0 then
            Result := true;
          // 释放目标进程中申请的空间
          VirtualFreeEx(hRemoteProcess, pszLibFileRemote,
            Length(DllFullPath) + 1, MEM_DECOMMIT);
          // 释放句柄
          CloseHandle(hRemoteThread);
        end;
      end;
    finally
      // 释放句柄
      CloseHandle(hRemoteProcess);
    end;
  end;
end;

//--注册表
function RegisterAppInitDLLs(ADllPath: string; AReg: Boolean = True): Boolean;
var
  vWindowsKey: TRegistry;
begin
  Result := False;
  vWindowsKey := TRegistry.Create;
  try
    vWindowsKey.RootKey := HKEY_LOCAL_MACHINE;
    if not vWindowsKey.OpenKey('Software\Microsoft\Windows NT\CurrentVersion\Windows', False) then begin
      DebugInf('MS - 输入法注入失败，没有找到指定Key', []);
      Exit;
    end;
    if AReg then begin
      vWindowsKey.WriteString('AppInit_DLLs', ADllPath);
      vWindowsKey.WriteInteger('LoadAppInit_Dlls', 1);
    end else begin
      vWindowsKey.WriteString('AppInit_DLLs', '');
      vWindowsKey.WriteInteger('LoadAppInit_Dlls', 0);
    end;
  finally
    vWindowsKey.CloseKey;
    FreeAndNil(vWindowsKey);
  end;
end;

procedure CreateImeInjectShareMemory(DllName: string; ProcessId: DWORD;
  var FileMapHandle:THandle);
var
  ShareMemory:PImeInjectShareMemory;
begin
  FileMapHandle:=0;
  FileMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE,
    0,SizeOf(TImeInjectShareMemory),GUID_SHAREMEMORY);
  if FileMapHandle > 0 then
  begin
    ShareMemory:=MapViewOfFile(FileMapHandle,FILE_MAP_ALL_ACCESS,0,0,0);
    if ShareMemory<>nil then
    begin
      ZeroMemory(ShareMemory,SizeOf(TImeInjectShareMemory));
      StrLCopy(PChar(ShareMemory),PChar(DllName),MAX_PATH-1);
      ShareMemory.ProcessId:=ProcessId;
      UnmapViewOfFile(ShareMemory);
    end;
  end;
end;

//--输入法
procedure GetImeInjectShareMemory(ImeInjectShareMemory:PImeInjectShareMemory);
var
  FileMapHandle:THandle;
  ShareMemory:PImeInjectShareMemory;
begin
  ZeroMemory(ImeInjectShareMemory,SizeOf(TImeInjectShareMemory));
  FileMapHandle:=OpenFileMapping(FILE_MAP_READ,False,GUID_SHAREMEMORY);
  if FileMapHandle>0 then
  begin
    ShareMemory:=MapViewOfFile(FileMapHandle,FILE_MAP_READ,0,0,0);
    if ShareMemory<>nil then
    begin
      CopyMemory(ImeInjectShareMemory,ShareMemory,SizeOf(TImeInjectShareMemory));
      UnmapViewOfFile(ShareMemory);
    end;
    CloseHandle(FileMapHandle);
  end;
end;

function ImeInject(AhGame: HWND; AdllPath: string): Boolean;
var
  SysDir: array[0..MAX_PATH] of Char;
  InjectProcessId: DWORD;
  LoadDllEvent: THandle;
  UnLoadDllEvent: THandle;
  DefaultImeHandle: THandle;
  ImeHandle: THandle;
  ImePath: string;
  FileMapHandle: THandle;
begin
  Result := False;
  try
    //找到窗口句柄
    if not IsWindow(AhGame) then Exit;

    //找到需要注入的进程ID
    GetWindowThreadProcessId(AhGame, InjectProcessId);
    if InjectProcessId <= 0 then Exit;

    //设置共享内存，并写入注入信息
    if FileMapHandle > 0 then
      CloseHandle(FileMapHandle);
    CreateImeInjectShareMemory(PChar(AdllPath), InjectProcessId,
      FileMapHandle);
    if FileMapHandle <= 0 then Exit;

    //保存原来的默认输入法
    SystemParametersInfo(SPI_GETDEFAULTINPUTLANG, 0, @DefaultImeHandle, 0);
    //获取系统目录
    ZeroMemory(@SysDir, MAX_PATH);
    GetSystemDirectory(@SysDir, MAX_PATH);
    ImePath := string(SysDir) + '\MythIme.ime';
    //复制输入法文件到系统目录
    if not CopyFile(PChar(ExtractFilePath(ExtractFilePath(ParamStr(0))) + 'ManSoyIme.ime'), PChar(ImePath), False) then begin
      DebugInf('复制输入法文件失败', []);
      Exit;
    end;
    if not FileExists(ImePath) then  begin
      DebugInf('输入法文件不存在', []);
      Exit;
    end;

    //安装输入法
  //ImeHandle := ImmInstallIME('C:\Windows\SysWOW64\MythIme.ime', 'ManSoyInput'); //
    ImeHandle := ImmInstallIME(PChar(ImePath), 'ManSoyInput');
    if ImeHandle <= 0 then begin
      DebugInf('MS - 安装输入法失败', []);
      Exit;
    end;

    //创建事件，同步dll注入
    UnLoadDllEvent := CreateEvent(nil, True, True, GUID_UNLOADDLL);
    LoadDllEvent := CreateEvent(nil, True, False, GUID_LOADDLL);
    //向目标窗口发送激活输入法的消息
    PostMessage(AhGame, WM_INPUTLANGCHANGEREQUEST, 0,
      ImeHandle);
    //等待注入完成
    if WaitForSingleObject(LoadDllEvent, 3000) = WAIT_OBJECT_0 then
    begin
      //广播消息，使我们的输入法卸载
      PostMessage(HWND_BROADCAST, WM_INPUTLANGCHANGEREQUEST, 0,
        DefaultImeHandle);
      //等待输入法卸载
      if WaitForSingleObject(UnLoadDllEvent, 3000) = WAIT_OBJECT_0 then
      begin
        DebugInf('MS - 注入成功！', []);
        Result := True;
      end;
    end;
    //卸载输入法
    UnloadKeyboardLayout(ImeHandle);
    DeleteFile(ImePath);
    CloseHandle(UnLoadDllEvent);
    CloseHandle(LoadDllEvent);
    CloseHandle(FileMapHandle);
  except on e: Exception do
    DebugInf('MS - 注入时发生异常[%s]', [e.Message]);
  end;
end;
{$ENDREGION}

{$REGION '打印调试信息'}
function DebugInf(const Format: string; const Args: array of const): Boolean;
//{$IFDEF DEBUG}
var
  sInfo: string;
//{$ENDIF}
begin
  Result := False;
  //{$IFDEF DEBUG}
  sInfo := System.SysUtils.Format(Format, Args, FormatSettings);
  OutputDebugString(PWideChar(sInfo));
  //{$ENDIF}
  Result := True;
end;

{$ENDREGION}

function GetGUID: string;
var
  vGuid: TGUID;
begin
  CreateGUID(vGuid);
  Result := GUIDToString(vGuid);
end;

function GetOnlyOneString(): string;
begin
  Result := ManSoy.Global.GetGUID;
  Result := StringReplace(Result, '{','', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '}','', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '-','', [rfReplaceAll, rfIgnoreCase]);
end;

function IsConnInternet: Boolean;
begin
  Result := False;
  try
    Result := InternetCheckConnection('http://www.baidu.com/', 1, 0);
  except

  end;
end;

end.
