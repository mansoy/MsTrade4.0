unit uGlobal;

interface

uses
  Windows, Messages, System.SysUtils, Generics.Collections, System.Classes,
  uJsonClass, QLog
  ;

const
  RetOK = 1;
  RetErr = 0;

const
  //控制台
  WM_ADD_LOG              = WM_USER + 1001;
  //--注入:
  WM_HOOK_ON              = WM_USER + 1006;

  WM_ADD_SEND_MACHINE     = WM_USER + 2001;
  WM_DEL_SEND_MACHINE     = WM_USER + 2003;
  WM_ADD_ORDER            = WM_USER + 2006;
  WM_DEL_ORDER            = WM_USER + 2007;
  //--------------------------------------------
  WM_UPDATE_CONN_UI       = WM_USER + 2011;
  WM_UPDATE_TASK_UI       = WM_USER + 2012;
  //--------------------------------------------
  WM_DIS_CONN             = WM_USER + 2021;   //--发货机断开连接

type
  //状态 ：0开始发货,1完成,2正在发货,3,暂停中,4失败,5结束任务
  TTaskState = (tsNormal = 100, tsStart = 0, tsSuccess = 1, tsDoing = 2, tsSuspend = 3, tsTargetFail = 4, tsFail = 5, tsKillTask = 6);
  //TTaskState = (tsNormal = 100, tsUnTreated = 10, tsPickUp = 15, tsDoing = 20, tsTargetFail = 50, tsSelfFail = 55, tsKillTas, tsSuccess = 0);
  TTaskType = (ttNormal = 100, tt发货 = 0, tt分仓 = 1, tt检库 = 2, tt邮件 = 3);

  //--发货机状态
  TSendMachineState = (sms空闲, sms繁忙, sms异常);

  //--当前角色执行到哪一步了
  TRoleStep = (
  /// <remarks>
  /// 初始状态
  /// </remarks>
  rsNormal = 0,
  /// <remarks>
  /// 子号摆摊完成，主号可以开始附魔
  /// </remarks>
  rs准备就绪=1,
  /// <remarks>
  /// 主号附魔完成
  /// </remarks>
  rs主号附魔完成=2,
  /// <remarks>
  /// 子号收到钱了
  /// </remarks>
  rs子号收到金额=3,
  /// <remarks>
  /// 子号未收到金额
  /// </remarks>
  rs子号未收到金额=4,
  /// <remarks>
  /// 对方掉线
  /// </remarks>
  rs对方任务失败=5,
  /// <remarks>
  /// 最后完成后，执行这个动作
  /// </remarks>
  rsFinished=6
  );

  //--客户端“设置”页
  TClientSet = record
    GroupName         : string;
    TheHost           : string;
    GamePath          : string;
    Capture           : string;

    ConsoleHost       : string;
    ConsolePort       : Word;

    CodingMachineHost : string;
    CodingMachinePort : Word;

    UseDama2          : Boolean;
    Dama2User         : string;
    Dama2Pwd          : string;

    UseVpn            : Boolean;
    VpnServerName     : string;
    VpnUserName       : string;
    VpnPassword       : string;

    TokenHost         : string;
    TokenPort         : Word;

    AutoConn          : Boolean;    //自动重连
    MutiRoleFenYe     : Boolean;    //多角色翻页
    AutoRun           : Boolean;    //开机自动运行
    Less10FFenPi      : Boolean;    //小于10级分页

    //-------------------------------------
    Url携带量         : string;
    Url上传图片       : string;
  end;

  TSharedInfo = record
    OrderItem     : TOrderItem;
    RoleIndex     : Integer;      //--正在处理第几个角色,默认是0
    RoleStep      : TRoleStep;    //--角色执行到哪一步了
    RecvRoleName  : string;       //--主号的接收角色
    TaskIndex     : Integer;      //--處理到第几个任务了
    ClientSet     : TClientSet;   //--客户端设置
    //TaskParam     : TTaskParam;
    //BagMoney      : Integer;
    GameWindow    : HWND;          //--游戏窗口句柄
    MainFormHandle: HWND;          //--发货机主窗口句柄
    bWork         : Boolean;       //--发货机是否正在工作
    bReStart      : Boolean;       //--是否重启任务进行发货
    bSuspendTask  : Boolean;       //--暂停任务
    bStopTask     : Boolean;       //--关闭当前任务
    bCmdOk        : Boolean;       //--当发出结束任务的命令， 用这个标示来判断对方是否已经结束了任务
    bConnOK       : Boolean;       //--判断是不是连接成功了
    LocalIP       : string;        //--本机IP
    AppPath       : string;        //--发货机路径根目录
    TaskStatus    : TTaskState;
    TaskType      : TTaskType;     //--当前任务类型
    procedure Init();
  end;

const   //发货机
  CON_REAPT_TIMES = 3;

var
  GSharedInfo: TSharedInfo;
  GConsoleSet: TConsoleSet;
  GAppQuit: Boolean = False;

  CS_OP_Task: TRTLCriticalSection;
  CS_LOG: TRTLCriticalSection;
  CS_ThreadIds: TRTLCriticalSection;

  //--------------------------------------
  GKeyMapLst    : TStringList;
  GKeyMapLstCode: TStringList;

var
  CON_SYS_DICT: string = 'Config\系统字库.txt';
  CON_DNF_DICT: string = 'Config\DNFDict.txt';
  CON_BMP_PATH: string = 'Bmp\';
  PATH_IMAGE  : string = '%sBmp\%s.jpg';


function InitAppPath(): Boolean;
function LoadCfg: Boolean;
function SaveCfg: Boolean;

function InitKeyMap: Boolean;
function InitKeyMapCode: Boolean;



procedure PostLogFile(AFormat: string; const Args: array of const);
procedure AddLogMsg(AFormat: string; const Args: array of const; AOnlyDebugShow: Boolean = False);
//procedure DebugInfo(AFormat: string; const Args: array of const; AOnlyDebugShow: Boolean = False);

function GetStateNum(ATaskState: TTaskState): Integer;
implementation

uses
  Vcl.Forms
  , System.IniFiles
  , System.Win.Registry
  , ManSoy.Encode
  , ManSoy.Global
  ;

{ TSharedInfo }

function InitAppPath(): Boolean;
var
  szFilePath: array[0..259] of WideChar;
begin
  GetModuleFileName(HInstance, @szFilePath, 260);
  GSharedInfo.AppPath  := ExtractFilePath(string(PWideChar(@szFilePath)));
  QLog.SetDefaultLogFile(Format('%s\Log\Logs_%s.log', [GSharedInfo.AppPath, FormatDateTime('yyyyMMdd', Now)]), 1024 * 1024 * 10, False, True);
end;

function LoadCfg: Boolean;
var
  iniLocalFile, iniSysFile: TIniFile;
  sDama2: string;
  iDupPos: Integer;
begin
  Debuginf('MS - 开始加载配置', []);
  //DebugInf('MS - 模块路径 %s', [string(PWideChar(@szFilePath))]);
  //iniLocalFile := TIniFile.Create(Format('%sConfig\LocalCfg.ini', [GSharedInfo.AppPath]));
  iniLocalFile := TIniFile.Create(Format('%sConfig\LocalCfg.ini', [GSharedInfo.AppPath]));
  iniSysFile := TIniFile.Create(Format('%sConfig\SysCfg.ini', [GSharedInfo.AppPath]));
  try
    GSharedInfo.ClientSet.GroupName         := iniLocalFile.ReadString('设置', '分组标识符', '');
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.ConsoleHost       := iniLocalFile.ReadString('设置', '控制台IP', '');
    GSharedInfo.ClientSet.ConsolePort       := iniLocalFile.ReadInteger('设置', '控制台端口', 0);
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.CodingMachineHost := iniLocalFile.ReadString('设置', '打码机IP', '');
    GSharedInfo.ClientSet.CodingMachinePort := iniLocalFile.ReadInteger('设置', '打码机端口', 0);
    GSharedInfo.ClientSet.UseDama2          := iniLocalFile.ReadBool('设置', '使用打码兔', False);
    sDama2 := iniLocalFile.ReadString('设置', '打码兔', '');
    sDama2 := Trim(sDama2);
    if ( sDama2 <> '') then
    begin
      iDupPos := Pos('|', sDama2);
      if iDupPos > 0 then
      begin
        GSharedInfo.ClientSet.Dama2User := string(ManSoy.Encode.Base64ToStr(AnsiString(Copy(sDama2, 1, iDupPos - 1))));
        GSharedInfo.ClientSet.Dama2Pwd  := string(ManSoy.Encode.Base64ToStr(AnsiString(Copy(sDama2, iDupPos + 1, Length(sDama2)))));
      end;
    end;
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.UseVpn        := iniLocalFile.ReadBool('VPN', '使用VPN', False);
    GSharedInfo.ClientSet.VpnServerName := iniLocalFile.ReadString('VPN', '服务器', '');
    GSharedInfo.ClientSet.VpnUserName   := iniLocalFile.ReadString('VPN', '账号', '');
    GSharedInfo.ClientSet.VpnPassword   := ManSoy.Encode.Base64ToStr(iniLocalFile.ReadString('VPN', '密码', ''));
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.TokenHost         := iniLocalFile.ReadString('设置', '令牌机IP', '');
    GSharedInfo.ClientSet.TokenPort         := iniLocalFile.ReadInteger('设置', '令牌机端口', 0);
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.TheHost           := iniLocalFile.ReadString('设置', '宿主程序', 'C:\Program Files (x86)\Tencent\QQMusic\QQMusic1213.17.49.21\QQMusic.exe');
    GSharedInfo.ClientSet.GamePath          := iniLocalFile.ReadString('设置', '游戏路径', '');
    GSharedInfo.ClientSet.Capture           := iniLocalFile.ReadString('设置', '截图存放目录', '');
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.AutoConn          := iniLocalFile.ReadBool('设置', '自动重连', False);
    GSharedInfo.ClientSet.MutiRoleFenYe     := iniLocalFile.ReadBool('设置', '多角色翻页', False);
    GSharedInfo.ClientSet.AutoRun           := iniLocalFile.ReadBool('设置', '开机自动运行', False);
    GSharedInfo.ClientSet.Less10FFenPi      := iniLocalFile.ReadBool('设置', '10级以下分批', False);
    //------------------------------------------------------------------------
    GSharedInfo.ClientSet.Url携带量     := iniSysFile.ReadString('连接', '携带量', '');
    GSharedInfo.ClientSet.Url上传图片   := iniSysFile.ReadString('连接', '上传图片', '');
  finally
    FreeAndNil(iniSysFile);
    FreeAndNil(iniLocalFile);
  end;
  //}
  Debuginf('MS - 配置加载完成，AppPath[%s]', [GSharedInfo.AppPath]);
  Result := True;
end;

function SaveCfg: Boolean;
  function SetAutoRunValue(AKeyName: string; APath: string; AFlag: Boolean): Boolean;
  var
    vReg: TRegistry;
  begin
    Result := False;
    vReg := TRegistry.Create;
    try
      vReg.RootKey := HKEY_LOCAL_MACHINE;
      vReg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', True);
      if AFlag then
        vReg.WriteString(AKeyName, APath)
      else
        vReg.DeleteValue(AKeyName)
    finally
      vReg.CloseKey;
      FreeAndNil(vReg);
    end;
  end;

var
  iniLocalFile, iniSysFile: TIniFile;
  sTmp: string;
begin
  iniLocalFile := TIniFile.Create(Format('%sConfig\LocalCfg.ini', [GSharedInfo.AppPath]));
  iniSysFile := TIniFile.Create(Format('%sConfig\SysCfg.ini', [GSharedInfo.AppPath]));
  try
    iniLocalFile.WriteString('设置', '分组标识符', GSharedInfo.ClientSet.GroupName);
    //------------------------------------------------------------------------
    iniLocalFile.WriteString('设置', '控制台IP', GSharedInfo.ClientSet.ConsoleHost);
    iniLocalFile.WriteInteger('设置', '控制台端口', GSharedInfo.ClientSet.ConsolePort);
    //------------------------------------------------------------------------
    //iniLocalFile.WriteString('设置', '打码机IP', GSharedInfo.ClientSet.CodingMachineHost);
    //iniLocalFile.WriteInteger('设置', '打码机端口', GSharedInfo.ClientSet.CodingMachinePort);
    //------------------------------------------------------------------------
    iniLocalFile.WriteBool('设置', '使用打码兔', GSharedInfo.ClientSet.UseDama2);
    sTmp := ManSoy.Encode.StrToBase64(GSharedInfo.ClientSet.Dama2User);
    sTmp := sTmp + '|' + ManSoy.Encode.StrToBase64(GSharedInfo.ClientSet.Dama2Pwd);
    iniLocalFile.WriteString('设置', '打码兔', sTmp);
    //------------------------------------------------------------------------
    iniLocalFile.WriteBool('VPN', '使用VPN', GSharedInfo.ClientSet.UseVpn);
    iniLocalFile.WriteString('VPN', '服务器', GSharedInfo.ClientSet.VpnServerName);
    iniLocalFile.WriteString('VPN', '账号', GSharedInfo.ClientSet.VpnUserName);
    iniLocalFile.WriteString('VPN', '密码', ManSoy.Encode.StrToBase64(GSharedInfo.ClientSet.VpnPassword));


    //------------------------------------------------------------------------
    //iniLocalFile.WriteString('设置', '令牌机IP', GSharedInfo.ClientSet.TokenHost);
    //iniLocalFile.WriteInteger('设置', '令牌机端口', GSharedInfo.ClientSet.TokenPort);
    //------------------------------------------------------------------------
    iniLocalFile.WriteString('设置', '游戏路径', GSharedInfo.ClientSet.GamePath);
    iniLocalFile.WriteString('设置', '宿主程序', GSharedInfo.ClientSet.TheHost);
    iniLocalFile.WriteString('设置', '截图存放目录', GSharedInfo.ClientSet.Capture);
    iniLocalFile.WriteBool('设置', '自动重连', GSharedInfo.ClientSet.AutoConn);
    iniLocalFile.WriteBool('设置', '多角色翻页', GSharedInfo.ClientSet.MutiRoleFenYe);
    iniLocalFile.WriteBool('设置', '开机自动运行', GSharedInfo.ClientSet.AutoRun);
    //iniLocalFile.WriteBool('设置', '10级以下分批', GSharedInfo.ClientSet.Less10FFenPi);
    SetAutoRunValue('发货机3.0', GSharedInfo.AppPath + 'AutoUpdate.exe', GSharedInfo.ClientSet.AutoRun);
  finally
    FreeAndNil(iniSysFile);
    FreeAndNil(iniLocalFile);
  end;
  Result := True;
end;

function InitKeyMap: Boolean;
begin
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
end;

function InitKeyMapCode: Boolean;
begin
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
  GKeyMapLstCode.Values['''']:= '222';;
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
end;

procedure PostLogFile(AFormat: string; const Args: array of const);
begin
  QLog.PostLog(TQLogLevel.llMessage, PWideChar(AFormat), Args);
end;

procedure AddLogMsg(AFormat: string; const Args: array of const; AOnlyDebugShow: Boolean = False);
var
  sMsg: string;
begin
  if AOnlyDebugShow then
  begin
    {$IFNDEF _MS_DEBUG}
      Exit;
    {$ENDIF}
  end;
  PostLogFile(AFormat, Args);
  if not IsWindow(GSharedInfo.MainFormHandle) then Exit;
  sMsg := System.SysUtils.Format(AFormat, Args, FormatSettings);
  if sMsg = '' then Exit;
  sMsg := Format('[%s]%s', [FormatDateTime('yyyy-MM-dd hh:nn:ss', Now), sMsg]);
  SendMessage(GSharedInfo.MainFormHandle, WM_ADD_LOG, 0, LPARAM(sMsg));
  Application.ProcessMessages;
end;

//procedure DebugInfo(AFormat: string; const Args: array of const; AOnlyDebugShow: Boolean = False);
//var
//  sMsg: string;
//begin
//  if AOnlyDebugShow then
//  begin
//    {$IFNDEF _MS_DEBUG}
//      Exit;
//    {$ENDIF}
//  end;
//  sMsg := System.SysUtils.Format(AFormat, Args, FormatSettings);
//  if sMsg = '' then Exit;
//  OutputDebugString(PWideChar(sMsg));
//  Application.ProcessMessages;
//end;

procedure AddLogFile(AFileNam: string; AFormat: string; const Args: array of const);
var
  sMsg: string;
  vFile: Text;
begin
  sMsg := System.SysUtils.Format(AFormat, Args, FormatSettings);
  if sMsg = '' then Exit;
  sMsg := Format('[%s]%s', [FormatDateTime('yyyy-MM-dd hh:nn:ss', Now), sMsg]);
  EnterCriticalSection(CS_LOG);
  try
    try
      AssignFile(vFile, AFileNam);
      if FileExists(AFileNam) then
        Append(vFile)
      else
        Rewrite(vFile);
      if Trim(sMsg) <> '' then
      begin
        Writeln(vFile, sMsg);
      end;
    except

    end;
  finally
    CloseFile(vFile);
    LeaveCriticalSection(CS_LOG);
  end;
end;

function GetStateNum(ATaskState: TTaskState): Integer;
begin
  Result := 15;
  case ATaskState of
    tsNormal: Result := 100;
    tsStart: Result := 15;
    tsSuccess: Result := 0;
    tsDoing: Result := 20;
    tsSuspend: Result := 20;
    tsTargetFail: Result := 55;
    tsFail: Result := 50;
    { TODO : 如果需要区分失败类别的话，在这里修改 }
    tsKillTask: Result := 55;
  end;
end;

procedure TSharedInfo.Init;
begin
  bReStart      := True;
  bWork         := False;
  bSuspendTask  := False;
  bStopTask     := False;
  bCmdOk        := True;
  bConnOK       := False;
  TaskStatus    := tsNormal;
  TaskType      := ttNormal;
end;

initialization
  InitAppPath;
  LoadCfg;
 // if TOSVersion.Major = 6 then
  begin
    CON_SYS_DICT := 'Config\系统字库(W7).txt';
    CON_DNF_DICT := 'Config\DNFDict(W7).txt';
    CON_BMP_PATH := 'Bmp(W7)\';
    PATH_IMAGE   := '%sBmp(W7)\%s.jpg';
  end;

  InitializeCriticalSection(CS_OP_Task);
  InitializeCriticalSection(CS_LOG);
  InitializeCriticalSection(CS_ThreadIds);
  GKeyMapLst := TStringList.Create;
  InitKeyMap;
  GKeyMapLstCode := TStringList.Create;
  InitKeyMapCode;
  GSharedInfo.Init;
finalization
  DeleteCriticalSection(CS_OP_Task);
  DeleteCriticalSection(CS_LOG);
  DeleteCriticalSection(CS_ThreadIds);
  GKeyMapLst.Free;
  GKeyMapLst := nil;

end.
