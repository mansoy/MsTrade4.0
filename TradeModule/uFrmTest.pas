unit uFrmTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Imaging.jpeg
  ,Winapi.TlHelp32
  , uGlobal;

type
  TFrmTest = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    LstLog: TMemo;
    btnStart: TButton;
    Button1: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure LoadCfg;
    procedure WMAddLog(var Mes: TMessage); message WM_ADD_LOG;
  public
    { Public declarations }
  end;

  TDoCmd = class(TThread)
  private
    FOrderJosn: string;
  protected
    procedure Execute; override;
  public
    constructor Create(AOrderJosn: string);
  end;

  TWorkThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create(); overload;
    destructor Destroy; override;
  end;

var
  FrmTest: TFrmTest;

implementation

uses
  uAutoSend, uJsonClass, uCommFuns, ManSoy.Global;

{$R *.dfm}

{ TDoCmd }

constructor TDoCmd.Create(AOrderJosn: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FOrderJosn := Trim(string(AOrderJosn));
end;

procedure TDoCmd.Execute;
var
  sJson: string;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
  bIsMain: Boolean;
  I: Integer;
  //vList: TStringList;
begin
//  vList := TStringList.Create;
//  try
//    vOrderItem := TOrderItem.Create;
//    vOrderItem.GameArea := '河南2区';
//    sJson := TSerizalizes.AsJSON<TOrderItem>(vOrderItem);
//    vList.Text := sJson;
//    vList.SaveToFile('1.json');
//    vRoleItem := TRoleItem.Create;
//    vRoleItem.rowId := 123;
//    sJson := TSerizalizes.AsJSON<TRoleItem>(vRoleItem);
//    vList.Text := sJson;
//    vList.SaveToFile('2.json');
//    vList.Text := FOrderJosn;
//    vList.SaveToFile('3.json');
//  finally
//    FreeAndNil(vOrderItem);
//    FreeAndNil(vRoleItem);
//    FreeAndNil(vList);
//  end;
//  Exit;
  FrmTest.btnStart.Enabled := False;
  try
    try
      if not TSerizalizes.AsType<TOrderItem>(FOrderJosn, vOrderItem) then Exit;
      if vOrderItem = nil then Exit;
      if Length(vOrderItem.roles) = 0 then Exit;
      //if GSharedInfo.bWork then Exit;
      TAutoSend.Create(vOrderItem);
    except on E: Exception do
      AddLogMsg('TDoCmd.Execute fail[%s]', [E.Message]);
    end;
  finally
    FrmTest.btnStart.Enabled := True;
  end;
end;

procedure TFrmTest.btnStartClick(Sender: TObject);
var
  DoCmd: TDoCmd;
  vLst: TStringList;
begin
  vLst := TStringList.Create;
  try
    vLst.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'FHOrders.json');
    if vLst.Text = '' then Exit;
    DoCmd := TDoCmd.Create(vLst.Text);
  finally
    FreeAndNil(vLst);
  end;
end;

procedure TFrmTest.Button1Click(Sender: TObject);
  function RGBtoBGR(C : TColor): TBDColor;
  begin
    result:=((C and $FF0000) shr 16) or (C and $00FF00) or ((C and $0000FF) shl 16);
  end;

  function GetScreenBmp1(AX, AY, AX1, AY1: Integer; AFileName: string): Boolean;
  var
    vBmp: TBitmap;
    I, J, vPos: Integer;
    dwPos: DWORD;
    jpg: TJpegImage;
  begin
    Result := False;
    vBmp := TBitmap.Create;
    jpg := TJPEGImage.Create;
    try
      try
        AddLogMsg('X:%d Y:%d X1:%d Y1:%d', [AX, AY, AX1, AY1]);
        vPos := GCommFuns.GetScreenData(AX, AY, AX1, AY1);
        vBmp.Height := AY1 - AY;
        vBmp.Width := AX1 - AX;
        dwPos := 0;
        for I := 0 to vBmp.Height - 1 do
          for J := 0 to vBmp.Width - 1 do
          begin
            vBmp.Canvas.Pixels[J, I] := RGBtoBGR(DWORD(Pointer(vPos + dwPos)^));
            dwPos := dwPos + 4;
          end;
        vBmp.SaveToFile('2.bmp');
        jpg.CompressionQuality := 70;
        //vBmp.SaveToStream();
        //jpg.LoadFromStream();
        AddLogMsg('GetScreenBmp - 01', []);
        jpg.Assign(vBmp);
        AddLogMsg('GetScreenBmp - 02 Jpg[W: %d, H: %d]', [jpg.Width, jpg.Height]);

        AddLogMsg('GetScreenBmp - 03', []);
        jpg.Compress;
        AddLogMsg('GetScreenBmp - 04', []);
        jpg.SaveToFile(AFileName);
        //vBmp.SaveToFile(AFileName);
        Result := FileExists(AFileName);
        if Result then
          PostLogFile('截图成功(%s)', [AFileName])
        else
          PostLogFile('截图失败(%s)', [AFileName]);
      except on E: Exception do
        begin
          //--失败后，先保存一下， 原始图
          PostLogFile('GetScreenBmp - 05 Bmp[W: %d, H: %d] ', [vBmp.Width, vBmp.Height]);
          vBmp.SaveToFile('2.bmp');
          Result := FileExists('2.bmp');
          AddLogMsg('TDmFuns.GetScreenBmp fail[ErrMsg=%s]', [E.Message]);
        end;
      end;
    finally
      FreeAndNil(jpg);
      FreeAndNil(vBmp);
    end;
  end;

  function GetScreenBmp2(AX, AY, AX1, AY1: Integer; AFileName: string): Boolean;
  var
    vBmp: TBitmap;
    I, J, vPos: Integer;
    dwPos: DWORD;
    jpg: TJpegImage;
    vStream: TMemoryStream;
  begin
    Result := False;
    vBmp := TBitmap.Create;
    jpg := TJPEGImage.Create;
    vStream := TMemoryStream.Create;
    try
      try
        AddLogMsg('X:%d Y:%d X1:%d Y1:%d', [AX, AY, AX1, AY1]);
        vPos := GCommFuns.GetScreenData(AX, AY, AX1, AY1);
        vBmp.Height := AY1 - AY;
        vBmp.Width := AX1 - AX;
        dwPos := 0;
        for I := 0 to vBmp.Height - 1 do
          for J := 0 to vBmp.Width - 1 do
          begin
            vBmp.Canvas.Pixels[J, I] := RGBtoBGR(DWORD(Pointer(vPos + dwPos)^));
            dwPos := dwPos + 4;
          end;
        vBmp.SaveToFile('2.bmp');
        vBmp.SaveToStream(vStream);

        //jpg.LoadFromStream();
        AddLogMsg('GetScreenBmp - 01', []);
        //jpg.Assign(vBmp);
        vStream.Position := 0;
        jpg.LoadFromStream(vStream);
        AddLogMsg('GetScreenBmp - 02 Jpg[W: %d, H: %d]', [jpg.Width, jpg.Height]);
        jpg.CompressionQuality := 70;
        AddLogMsg('GetScreenBmp - 03', []);
        jpg.Compress;
        AddLogMsg('GetScreenBmp - 04', []);
        jpg.SaveToFile(AFileName);
        //vBmp.SaveToFile(AFileName);
        Result := FileExists(AFileName);
        if Result then
          PostLogFile('截图成功(%s)', [AFileName])
        else
          PostLogFile('截图失败(%s)', [AFileName]);
      except on E: Exception do
        begin
          //--失败后，先保存一下， 原始图
          PostLogFile('GetScreenBmp - 05 Bmp[W: %d, H: %d] ', [vBmp.Width, vBmp.Height]);
          vBmp.SaveToFile('2.bmp');
          Result := FileExists('2.bmp');
          AddLogMsg('TDmFuns.GetScreenBmp fail[ErrMsg=%s]', [E.Message]);
        end;
      end;
    finally
      FreeAndNil(jpg);
      FreeAndNil(vBmp);
    end;
  end;
var
  I: Integer;
begin
  Self.Close;
  Exit;
//  for I := 0 to 10000 do
//  begin
//    Sleep(1);
//    AddLogMsg('----------------------------------------------------', []);
//    if not GetScreenBmp1(0,0,800,600,'1.bmp') then Break;
//  end;
  GCommFuns.CaptureGif(0,0,800,600,'1.bmp', 0, 1);
  GCommFuns.GetScreenBmp(0,0,800,600,'2.bmp');
end;

procedure TFrmTest.FormCreate(Sender: TObject);
begin
  Self.LoadCfg;
  uGlobal.LoadCfg;
  GSharedInfo.MainFormHandle := Self.Handle;
  SystemParametersInfo(SPI_SETFONTSMOOTHING, 0, 0, 1);

  //LoadLibrary(PWideChar(GSharedInfo.AppPath + 'test.dll'));

  Self.Left := Screen.WorkAreaWidth - Self.Width;
  Self.Top  := Screen.WorkAreaHeight - Self.Height;

  GSharedInfo.MainFormHandle  := Self.Handle;
  GSharedInfo.bWork           := False;
  GSharedInfo.LocalIP := '0.0.0.0';
  AddLogMsg('Local IP: %s', [GSharedInfo.LocalIP], True);
  LstLog.Clear;
  TWorkThread.Create;
end;

procedure TFrmTest.FormDestroy(Sender: TObject);
begin
  SystemParametersInfo(SPI_SETFONTSMOOTHING, 1, 0, 1);
end;

procedure TFrmTest.LoadCfg;
var
  SysCfg: string;
  vLst: TStrings;
begin
  vLst := TStringList.Create;
  try
    SysCfg := ExtractFilePath(ParamStr(0)) + 'Config';
    if not DirectoryExists(SysCfg) then ForceDirectories(SysCfg);
    SysCfg := Format('%s\SvrSysCfg.cfg', [SysCfg]);

    if FileExists(SysCfg) then vLst.LoadFromFile(SysCfg);

    try
      TSerizalizes.AsType<TConsoleSet>(vLst.Text, GConsoleSet);
    except
    end;

    if GConsoleSet = nil  then
    begin
      GConsoleSet := TConsoleSet.Create;
    end;
  finally
    FreeAndNil(vLst);
  end;
end;

procedure TFrmTest.WMAddLog(var Mes: TMessage);
begin
//  if LstLog.Lines.Count > 100 then
//  begin
//    LstLog.Lines.Delete(0);
//  end;
  LstLog.Lines.Add(string(Mes.LParam));
end;

{ TWorkThread }

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
  function EnumWindowsProc(hWnd: HWND; lParam: LPARAM): Boolean; stdcall;
  var
    sProcessName: string;
    TempClassName: array[0..255] of Char;
    TempWindowText: array[0..255] of Char;
    dwPid: DWORD;
  begin
    Result := true;
    Sleep(1);
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
      if (sProcessName = 'tgp_gamead.exe') or (sProcessName = 'CrossProxy.exe') or (sProcessName = 'BackgroundDownloader.exe') or (sProcessName = 'TenioDL.exe') then
      begin
        //AddLogMsg(sProcessName, []);
        KillProcessByID(lppe.th32ProcessID);
        Break;
      end;
      { 未找到,继续下一个进程 }
      FoundAProc := Process32Next(SsHandle, lppe);
    end;
    CloseHandle(SsHandle);
  end;
begin
  while not Terminated do
  try
    Sleep(200);
    EnumWindows(@EnumWindowsProc, 0);
    KillAdditionalProcess;
  except
  end;
end;

end.
