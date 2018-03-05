Unit uDToolServer;

interface

uses
  Windows, Messages, Forms, Classes, System.SysUtils,
  System.Generics.Collections,
  HPSocketSDKUnit,
  uGlobal
  ;

const
  S_RET_OK = 'OK';

type
  TConsoleSvr = class
  private
    FAppState : EnAppState;
    FServer   : Pointer;
    FListener : Pointer;
    FHost: string;
    FPort: Word;
  public
    constructor Create();
    destructor Destroy; override;
    function Start(): En_HP_HandleResult;
    function Stop(): En_HP_HandleResult;
    function DisConn(AConnID: DWORD): En_HP_HandleResult;
    {$REGION '通讯'}
    function SuspendTask(AConnID: DWORD; AGroupName: string): Boolean;
    function ResumeTask(AConnID: DWORD; AGroupName: string): Boolean;
    function StopTask(AConnID: DWORD; AGroupName: string): Boolean;

    function Shutdown(AConnID: DWORD; AGroupName: string): Boolean;
    function ReBoot(AConnID: DWORD; AGroupName: string): Boolean;
    function LogOff(AConnID: DWORD; AGroupName: string): Boolean;
    //--发货机关闭或者，发货机异常后，处理订单
    function SendMachineClose(AConnId: DWORD): Boolean;
    function RetCmdOk(AConnId: DWORD): Boolean;

    //---
    function RetRoleStep(AConnId: DWORD; ARoleStep: TRoleStep): Boolean;
    function RetRecvRoleName(AConnId: DWORD; ARecvRoleName: string): Boolean;
    {$ENDREGION}
    property Host: string read FHost write FHost;
    property Port: Word read FPort write FPort;
    property AppState: EnAppState read FAppState write FAppState;
    property Server: Pointer read FServer write FServer;
  end;

  TDoCmd = class(TThread)
  private
    FCmd      : string;
    FConnID   : DWORD;
  protected
    procedure Execute; override;
  public
    constructor Create(AConnID: DWORD; ALen: Integer; AData: Pointer);
    destructor Destroy; override;
  end;

var
  ConsoleSvr: TConsoleSvr;

implementation

uses
  ManSoy.Global,
  ManSoy.Encode,
  uJsonClass,
  uTaskManager,
  uCommand;

{ TDataHandleThread }
constructor TDoCmd.Create(AConnID: DWORD; ALen: Integer; AData: Pointer);
var
  sCmd: AnsiString;
begin
  FreeOnTerminate := True;
  inherited Create(True);
  // 以下是一个pData转字符串的演示
  SetLength(sCmd, ALen);
  Move(AData^, sCmd[1],  ALen);
  FCmd := Trim(string(sCmd));
  FConnID := AConnID;
end;

destructor TDoCmd.Destroy;
begin
  inherited;
end;

procedure TDoCmd.Execute;
var
  vLst: TStrings;
  sCmd, sGroupName, sKey, sJson, sTargetRoleName, sRoleName: string;
  iRoleStep: Integer;
begin
  try
    { TODO : 在这里处理，客户端请求 }
    if FCmd = '' then Exit;
    vLst := TStringList.Create;
    try
      vLst.Delimiter := ',';
      vLst.DelimitedText := FCmd;
      if vLst.Count = 0 then Exit;
      sCmd := Trim(vLst.Values['cmd']);
      if sCmd = '' then Exit;
      if sCmd = 'GetTask' then
      begin
        sGroupName := vLst.Values['GroupName'];
        sJson := ConnManager.GetConnOrderInfo(sGroupName);
        uCommand.Cmd_RetTask(ConsoleSvr.Server, FConnID, sJson);
      end else if sCmd = 'GetParam' then
      begin
        sJson := TSerizalizes.AsJSON<TConsoleSet>(GConsoleSet);
        uCommand.Cmd_RetParam(ConsoleSvr.Server, FConnID, sJson);
      end else if sCmd = 'RetState' then
      begin
        //--设置状态
        sJson := Trim(vLst.Values['Json']);
        SetTaskState(sJson);
      end else if sCmd = 'EndTask' then
      begin
        //--发货机已经发完货， 或者异常了
        sGroupName := Trim(vLst.Values['GroupName']);
        sKey := Trim(vLst.Values['Key']);
        uTaskManager.EndTask(sGroupName, sKey);
      end else if sCmd = 'SuspendTask' then
      begin
        //--发货机已经发完货， 或者异常了
        sGroupName := Trim(vLst.Values['GroupName']);
        uTaskManager.SuspendTask(sGroupName);
      end else if sCmd = 'Connection' then
      begin
        sGroupName := Trim(vLst.Values['GroupName']);
        uTaskManager.AddConnItem(FConnID, sGroupName);
      end else if sCmd = 'SetRoleStep' then
      begin
        ManSoy.Global.DebugInf('MS - %s', [FCmd]);
        TaskManager.SetRoleStep(FCmd, FConnID);
      end else if sCmd = 'ReSetRoleStep' then
      begin
        sGroupName := Trim(vLst.Values['GroupName']);
        sRoleName := Trim(vLst.Values['RoleName']);
        sTargetRoleName := Trim(vLst.Values['TargetRoleName']);
        iRoleStep := StrToIntDef(Trim(vLst.Values['RoleStep']), 0);
        ConnManager.ReSetRoleStep(FConnID, sGroupName, sRoleName, sTargetRoleName, TRoleStep(iRoleStep));
      end else if sCmd = 'GetRoleStep' then
      begin
        sGroupName := Trim(vLst.Values['GroupName']);
        ConnManager.RetRoleStep(FConnID, sGroupName);
      end else if sCmd = 'GetTargetRoleStep' then
      begin
        ManSoy.Global.DebugInf('MS - %s', [FCmd]);
        sGroupName := Trim(vLst.Values['GroupName']);
        sRoleName := Trim(vLst.Values['RoleName']);
        sTargetRoleName := Trim(vLst.Values['TargetRoleName']);
        ConnManager.RetTargetRoleStep(FConnID, sGroupName, sRoleName, sTargetRoleName);
      end else if sCmd = 'GetMasterRecRoleName' then
      begin
        sGroupName := Trim(vLst.Values['GroupName']);
        sRoleName := Trim(vLst.Values['MasterRoleName']);
        ConnManager.RetRecvRoleName(FConnID, sGroupName, sRoleName);
      end else if sCmd = 'SetMasterRecRoleName' then
      begin
        AddLogMsg('MS - %s', [FCmd], True);
        TaskManager.SetMasterRecRoleName(FCmd, FConnID);
      end else if sCmd = 'ClearRecvRoleName' then
      begin
        AddLogMsg('MS - %s', [FCmd], True);
        TaskManager.ClearRecvRoleName(FCmd, FConnID);
      end;
    finally
      FreeAndNil(vLst);
    end;
  except
  end
end;

{ TConsoleSvr }
function OnPrepareListen(soListen: Pointer): En_HP_HandleResult; stdcall;
begin
    Result := HP_HR_OK;
end;

function OnAccept(dwConnId: DWORD; pClient: Pointer): En_HP_HandleResult; stdcall;
var
  ip: array [0 .. 40] of WideChar;
  ipLength: Integer;
  port: USHORT;
begin
  ipLength := 40;
  if HP_Server_GetRemoteAddress(ConsoleSvr.Server, dwConnId, ip, @ipLength, @port) then
  begin
    //uGlobal.AddLogMsg(' > [%d,OnAccept] -> PASS(%s:%d)', [dwConnId, string(ip), port]);
  end else
  begin
    //uGlobal.AddLogMsg(' > [%d,OnAccept] -> HP_Server_GetClientAddress() Error', [dwConnId]);
  end;

  Result := HP_HR_OK;
end;

function OnServerShutdown(): En_HP_HandleResult; stdcall;
begin
  //uGlobal.AddLogMsg(' > [OnServerShutdown]', []);
  Result := HP_HR_OK;
end;

function OnSend(dwConnId: DWORD; const pData: Pointer; iLength: Integer): En_HP_HandleResult; stdcall;
begin
  //uGlobal.AddLogMsg(' > [%d,OnSend] -> (%d bytes)', [dwConnId, iLength]);
  Result := HP_HR_OK;
end;

function OnReceive(dwConnId: DWORD; const pData: Pointer; iLength: Integer): En_HP_HandleResult; stdcall;
var
{$IFDEF _MS_DEBUG}
  testString: Ansistring;
{$ENDIF}
  doRec : TDoCmd;
begin
//  uGlobal.AddLogMsg(' > [%d,OnReceive] -> (%d bytes)', [dwConnId, iLength]);
//
  {$IFDEF _MS_DEBUG}
  // 以下是一个pData转字符串的演示
  SetLength(testString, iLength);
  Move(pData^, testString[1],  iLength);
  //uGlobal.AddLogMsg(' > [%d,OnReceive] -> say:%s', [dwConnId, string(testString)]);
  {$ENDIF}
  doRec := TDoCmd.Create(dwConnId, iLength, pData);
  doRec.Resume;

  Result := HP_HR_OK;
end;

function OnCloseConn(dwConnId: DWORD): En_HP_HandleResult; stdcall;
begin
  ConsoleSvr.SendMachineClose(dwConnId);
  //uGlobal.AddLogMsg(' > [%d,OnCloseConn]', [dwConnId]);
  Result := HP_HR_OK;
end;

function OnError(dwConnId: DWORD; enOperation: En_HP_SocketOperation; iErrorCode: Integer): En_HP_HandleResult; stdcall;
begin
  //ConsoleSvr.SendMachineClose(dwConnId);
  uGlobal.AddLogMsg('> [%d,OnError] -> OP:%d,CODE:%d', [dwConnId, Integer(enOperation), iErrorCode]);
  Result := HP_HR_OK;
end;

constructor TConsoleSvr.Create;
begin
  // 创建监听器对象
  FListener := Create_HP_TcpServerListener();
  // 创建 Socket 对象
  FServer := Create_HP_TcpServer(FListener);

  // 设置 Socket 监听器回调函数
  HP_Set_FN_Server_OnPrepareListen(FListener, OnPrepareListen);
  HP_Set_FN_Server_OnAccept(FListener, OnAccept);
  HP_Set_FN_Server_OnSend(FListener, OnSend);
  HP_Set_FN_Server_OnReceive(FListener, OnReceive);
  HP_Set_FN_Server_OnClose(FListener, OnCloseConn);
  HP_Set_FN_Server_OnError(FListener, OnError);
  HP_Set_FN_Server_OnShutdown(FListener, OnServerShutdown);

  FAppState := ST_STOPED;
end;

destructor TConsoleSvr.Destroy;
begin
  // 销毁 Socket 对象
  Destroy_HP_TcpServer(FServer);
  // 销毁监听器对象
  Destroy_HP_TcpServerListener(FListener);
  inherited;
end;

function TConsoleSvr.DisConn(AConnID: DWORD): En_HP_HandleResult;
begin
  Result := HP_HR_ERROR;
  if HP_Server_Disconnect(FServer, AConnID, 1) then
    uGlobal.AddLogMsg('(%d) Disconnect OK', [AConnID])
  else
    uGlobal.AddLogMsg('(%d) Disconnect Error', [AConnID]);
  Result := HP_HR_OK;
end;

function TConsoleSvr.Start: En_HP_HandleResult;
var
  errorId: En_HP_SocketError;
  errorMsg: PWideChar;
begin
  Result := HP_HR_ERROR;
  FAppState := ST_STARTING;
  if not HP_Server_Start(FServer, PWideChar(Host), Port) then
  begin
    errorId := HP_Server_GetLastError(FServer);
    errorMsg := HP_Server_GetLastErrorDesc(FServer);
    uGlobal.AddLogMsg('Server Start Error -> %s(%d)', [errorMsg, Integer(errorId)]);
    FAppState := ST_STOPED;
    Exit;
  end;
  uGlobal.AddLogMsg('Server Start OK -> (%s:%d)', [Host, Port]);
  FAppState := ST_STARTED;
  Result := HP_HR_OK;
end;

function TConsoleSvr.Stop: En_HP_HandleResult;
var
  errorId: En_HP_SocketError;
  errorMsg: PWideChar;
begin
  Result := HP_HR_ERROR;
  FAppState := ST_STOPING;
  if not HP_Server_Stop(FServer) then
  begin
    errorId := HP_Server_GetLastError(FServer);
    errorMsg := HP_Server_GetLastErrorDesc(FServer);
    uGlobal.AddLogMsg('Stop Error -> %s(%d)', [errorMsg, Integer(errorId)]);
    Exit;
  end;
  uGlobal.AddLogMsg('Server Stop', []);
  FAppState := ST_STOPED;
  Result := HP_HR_OK;
end;

{$REGION '通讯'}
function TConsoleSvr.SuspendTask(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_SuspendTask(Server, AConnID, AGroupName);
end;

function TConsoleSvr.ResumeTask(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_ResumeTask(Server, AConnID, AGroupName);
end;

function TConsoleSvr.StopTask(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_StopTask(Server, AConnID, AGroupName);
end;

function TConsoleSvr.Shutdown(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_Shutdown(Server, AConnID, AGroupName);
end;

function TConsoleSvr.ReBoot(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_ReStart(Server, AConnID, AGroupName);
end;

function TConsoleSvr.LogOff(AConnID: DWORD; AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_Logout(Server, AConnID, AGroupName);
end;

function TConsoleSvr.SendMachineClose(AConnId: DWORD): Boolean;
var
  sGroupName: string;
  vConnItem: TConnItem;
  vOrderInfo: TOrderItem;
  I, iRoleIndex: Integer;
begin

  sGroupName := ConnManager.GetGroupName(AConnId);
  if sGroupName = '' then Exit;
  vConnItem := ConnManager.Items[sGroupName];
  if vConnItem = nil then Exit;
  try
    vOrderInfo := vConnItem.OrderItem;
    if vOrderInfo = nil then
    begin
      SendMessage(GSharedInfo.MainFormHandle, WM_DEL_SEND_MACHINE, 0, LPARAM(sGroupName));
      Exit;
    end;
    if Length(vOrderInfo.roles) = 0 then Exit;
    vConnItem.LogMsgs.Add('发货机异常中断');
    vConnItem.IsAbnormal := True;
    vConnItem.State := sms异常;
    vConnItem.RoleStep := rsNormal;
    vConnItem.Suspend := False;
    for i := Low(vOrderInfo.roles) to High(vOrderInfo.roles) do
    begin
      vOrderInfo.roles[i].taskState := Integer(tsFail);
      vOrderInfo.roles[i].logMsg := '发货机异常中断';
      //uCommand.PostState(vOrderInfo, I, GSharedInfo.ClientSet.GroupName, GConsoleSet.StateInterface);
    end;
  finally
    //SendMessage(GSharedInfo.MainFormHandle, WM_DEL_SEND_MACHINE, 0, LPARAM(sGroupName));
  end;
end;

function TConsoleSvr.RetCmdOk(AConnId: DWORD): Boolean;
begin
  Result := uCommand.Cmd_CmdOK(Server, AConnId);
end;

function TConsoleSvr.RetRoleStep(AConnId: DWORD; ARoleStep: TRoleStep): Boolean;
begin
  Result := uCommand.Cmd_RetRoleStep(Server, AConnId, ARoleStep);
end;

function TConsoleSvr.RetRecvRoleName(AConnId: DWORD; ARecvRoleName: string): Boolean;
begin
  Result := uCommand.Cmd_RetRecvRoleName(Server, AConnId, ARecvRoleName);
end;

{$ENDREGION}

end.

