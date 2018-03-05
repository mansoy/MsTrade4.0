unit uFrmLogs;

interface

uses
  Windows, Messages, SysUtils, Vcl.Forms, IdComponent, IdIPWatch, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls, System.Classes
  , IdBaseComponent
  , Winapi.TlHelp32
  , uGlobal;

type
  TFrmLogs = class(TForm)
    LstLog: TListBox;
    Panel2: TPanel;
    btnClear: TButton;
    btnSelAll: TButton;
    btnCopy: TButton;
    Timer1: TTimer;
    IdIPWatch1: TIdIPWatch;
    chkAutoConn: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnSelAllClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkAutoConnClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMAddLog(var Mes: TMessage); message WM_ADD_LOG;
  protected
    procedure CreateParams(var Parames:TCreateParams); override;
  public
    { Public declarations }
  end;

  TWorkThread = class(TThread)
  private
    function ConnConsole: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(); overload;
    destructor Destroy; override;
  end;

var
  FrmLogs: TFrmLogs;

implementation

uses
   Vcl.Clipbrd
  , ManSoy.Global
  , ManSoy.MsgBox
  , uTradeClient
  , HPSocketSDKUnit
  , uCommand
  , uCommFuns
  {$IFDEF _MS_DEBUG}
  , uJsonClass
  , uAutoSend
  {$ENDIF}
  ;

{$R *.dfm}

procedure TFrmLogs.btnClearClick(Sender: TObject);
begin
  LstLog.Clear;
end;

procedure TFrmLogs.btnCopyClick(Sender: TObject);
var
  I: Integer;
  sText: string;
begin
  for I := 0 to LstLog.Count - 1 do
  begin
    if LstLog.Selected[I] then
    begin
      sText := sText + LstLog.Items.Strings[i] + #13;
    end;
  end;
  Clipboard.SetTextBuf(PWideChar(sText));
end;

procedure TFrmLogs.btnSelAllClick(Sender: TObject);
begin
  LstLog.SelectAll;
end;

procedure TFrmLogs.chkAutoConnClick(Sender: TObject);
begin
  GSharedInfo.ClientSet.AutoConn := chkAutoConn.Checked;
end;

procedure TFrmLogs.CreateParams(var Parames: TCreateParams);
var
  sClassName: string;
  sCaption: string;
begin
  inherited CreateParams(Parames);
  sClassName := ManSoy.Global.GetGUID;
  sCaption := ManSoy.Global.GetOnlyOneString;
  Parames.Caption := PWideChar(sCaption);
  lstrcpyn(Parames.WinClassName, PWideChar(sClassName), SizeOf(Parames.WinClassName));
end;

procedure TFrmLogs.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if GSharedInfo.bWork then
  begin
    CanClose := ManSoy.MsgBox.AskMsg(Self.Handle, '正在处理任务，确定退出?', []) = IDYES;
  end;
  if CanClose then
  begin
    PostQuitMessage(0);
  end;
end;

procedure TFrmLogs.FormCreate(Sender: TObject);
var
  hWnd: THandle;
begin
  //LoadCfg;
  GSharedInfo.MainFormHandle := Self.Handle;
  SystemParametersInfo(SPI_SETFONTSMOOTHING, 0, 0, 1);

  //LoadLibrary(PWideChar(GSharedInfo.AppPath + 'test.dll'));

  Self.Left := Screen.WorkAreaWidth - Self.Width;
  Self.Top  := Screen.WorkAreaHeight - Self.Height;

  GSharedInfo.MainFormHandle  := Self.Handle;
  GSharedInfo.bWork           := False;
  GSharedInfo.LocalIP         := IdIPWatch1.LocalIP;
  if GSharedInfo.LocalIP = '' then GSharedInfo.LocalIP := '0.0.0.0';
  AddLogMsg('Local IP: %s', [GSharedInfo.LocalIP], True);
  chkAutoConn.Checked := GSharedInfo.ClientSet.AutoConn;
  TWorkThread.Create;
  LstLog.Clear;

  //--关闭启动器
  hWnd := FindWindow('TFrmMain', 'DToolClient');
  if IsWindow(hWnd) then
  begin
    SendMessage(hWnd, WM_CLOSE, 0, 0);
  end;
end;

procedure TFrmLogs.FormDestroy(Sender: TObject);
begin
  SystemParametersInfo(SPI_SETFONTSMOOTHING, 1, 0, 1);
  GAppQuit := True;
  ExitProcess(0);
end;

procedure TFrmLogs.WMAddLog(var Mes: TMessage);
begin
  if LstLog.Count > 100 then
  begin
    LstLog.Items.Delete(0);
  end;
  LstLog.Items.Add(string(Mes.LParam));
  LstLog.ClearSelection;
  LstLog.Selected[LstLog.Count - 1] := True;
end;

{ TWorkThread }

function TWorkThread.ConnConsole: Boolean;
begin
  Result := False;
  try
    if GSharedInfo.ClientSet.AutoConn and (TradeClient.AppState = ST_STOPED) then
    begin
      GSharedInfo.bConnOK := False;
      TradeClient.Host := GSharedInfo.ClientSet.ConsoleHost;
      TradeClient.Port := GSharedInfo.ClientSet.ConsolePort;
      TradeClient.Start;
      if TradeClient.AppState = ST_STARTED then
        uCommand.Cmd_Conn(TradeClient.Client, GSharedInfo.ClientSet.GroupName);
    end;

    if (not GSharedInfo.ClientSet.AutoConn) and (TradeClient.AppState = ST_STARTED) then
    begin
      TradeClient.Stop;
      GSharedInfo.bConnOK := False;
    end;
    Result := False;
  except
  end;
end;

constructor TWorkThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False);
end;

destructor TWorkThread.Destroy;
begin
  inherited;
end;

procedure TWorkThread.Execute;
  procedure KillAdditionalProcess;
  var
    lppe: TProcessEntry32;
    SsHandle: Thandle;
    FoundAProc: boolean;
    sProcessName: string;
    hGame: HWND;
  begin
    { 创建系统快照 }
    SsHandle := CreateToolHelp32SnapShot(TH32CS_SnapProcess, 0);

    { 取得快照中的第一个进程 }
    { 一定要设置结构的大小,否则将返回False }
    lppe.dwSize := sizeof(TProcessEntry32);
    FoundAProc := Process32First(Sshandle, lppe);
    hGame := FindWindow(nil, '地下城与勇士登录程序');
    if IsWindow(hGame) then Exit;
    hGame := FindWindow('地下城与勇士', '地下城与勇士');
    if not IsWindow(hGame) then Exit;
    if not IsWindowVisible(hGame) then Exit;
    while FoundAProc do
    begin
      Sleep(1);
      sProcessName := ExtractFilename(lppe.szExefile);
      if (sProcessName = 'CrossProxy.exe') then
      //if (sProcessName = 'tgp_gamead.exe') or (sProcessName = 'CrossProxy.exe') or (sProcessName = 'QQProtect.exe') or (sProcessName = 'BackgroundDownloader.exe') or (sProcessName = 'TenioDL.exe') then
      begin
        AddLogMsg(sProcessName, [], True);
        KillProcessByID(lppe.th32ProcessID);
        Break;
      end;
      { 未找到,继续下一个进程 }
      FoundAProc := Process32Next(SsHandle, lppe);
    end;
    CloseHandle(SsHandle);
  end;

  function EnumWindowsProc(hWnd: HWND; lParam: LPARAM): Boolean; stdcall;
  var
    sProcessName: string;
    TempClassName: array[0..255] of Char;
    TempWindowText: array[0..255] of Char;
    dwPid: DWORD;
  begin
    Result := true;
    dwPid := GetProcessIdByHandle(hWnd);
    sProcessName := ExtractFileName(GetProcessName(hWnd));

    GetClassName(hWnd, TempClassName , 256);
    GetWindowText(hWnd, TempWindowText, 256);

    if ((sProcessName = 'QQMusicExternal.exe') or
        (sProcessName = 'QQMusicService.exe') or
        (sProcessName = 'QQMusicIE.exe')) and
        ((string(TempClassName) <> 'Progman') and (string(TempWindowText) <> 'Program Manager')) and
        ((string(TempClassName) <> 'SysListView32') and (string(TempWindowText) <> 'FolderView')) and
        ((string(TempClassName) <> 'SysHeader32')) and
        ((string(TempClassName) <> 'SHELLDLL_DefView')) and
        IsWindowVisible(hWnd) then
    begin
      //CloseWindow(hWnd);
      //SendMessage(hWnd, WM_CLOSE, 0, 0);
      ShowWindow(hWnd, SW_HIDE);
      Result := False;
    end;

    if (sProcessName = 'QQMusic.exe') and (lstrcmp('TXGuiFoundation', TempClassName) = 0) and IsWindowVisible(hWnd) then
    begin
      ShowWindow(hWnd, SW_HIDE);
      Result := False;
    end;

    if (lstrcmp('公告', TempWindowText) = 0) and (lstrcmp('#32770', TempClassName) = 0) then
    begin
      SendMessage(hWnd, WM_CLOSE, 0, 0);
      Result := False;
    end;

    if (lstrcmp('DNF视频播放器', TempWindowText) = 0) and (lstrcmp('TWINCONTROL', TempClassName) = 0) then
    begin
      SendMessage(hWnd, WM_CLOSE, 0, 0);
      Result := False;
    end;

    if (lstrcmp('<错误> 插件版本:3.1233', TempWindowText) = 0) then
    begin
      SendMessage(hWnd, WM_CLOSE, 0, 0);
      Result := False;
    end;

    if (lstrcmp('Dungeon & Fighter', TempWindowText) = 0) then
    begin
      SendMessage(hWnd, WM_CLOSE, 0, 0);
      Result := False;
    end;

    if (lstrcmp('TASLogin Application', TempWindowText) = 0) then
    begin
      SendMessage(hWnd, WM_CLOSE, 0, 0);
      Result := False;
    end;
  end;

var
  bConned : Boolean;
  I: Integer;
begin
  while not Terminated do
  try
    Sleep(200);
    if GAppQuit then Break;
    {$IFNDEF _MS_DEBUG}
    EnumWindows(@EnumWindowsProc, 0);
    //colin20150707
    KillAdditionalProcess;
    ConnConsole;
    {$ENDIF}
    //--如果发货机没有连接到控制台，则不进行处理
    if TradeClient.AppState <> ST_STARTED then Continue;
    if not GSharedInfo.bConnOK then Continue;

    if GConsoleSet = nil then
    begin
      TradeClient.GetParam(GSharedInfo.ClientSet.GroupName);
      Sleep(1000);
    end;

    if GConsoleSet = nil then Continue;

    if GSharedInfo.bWork then
    begin
      Continue;
    end;
    //--如果发货机空闲，则获取订单进行发货
    TradeClient.GetTask(GSharedInfo.ClientSet.GroupName);
  except
  end;
end;

end.
