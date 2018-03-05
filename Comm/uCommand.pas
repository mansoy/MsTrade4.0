unit uCommand;

interface

uses
  WinApi.Windows, System.SysUtils, System.Classes, ManSoy.Encode,
  uGlobal, uJsonClass;

function Cmd_Client_Send(AClient: Pointer; ACmd: string): Boolean;
function Cmd_Server_Send(AServer: Pointer; AConnId: DWORD; ACmd: string): Boolean;

//--发货机连接控制台
function Cmd_Conn(AClient:Pointer; AGroupName: string): Boolean;
function Cmd_RetConn(AServer:Pointer; AConnID: DWORD; AIsExist: Boolean = True): Boolean;
//--获取任务
function Cmd_GetTask(AClient:Pointer; AGroupName: string): Boolean;
//--控制台传给发货机订单信息
function Cmd_RetTask(AServer: Pointer; AConnID: DWORD; ACmd: string): Boolean;

//--获取控制台参数
function Cmd_GetParam(AClient:Pointer; AGroupName: string): Boolean;
//--返回控制台参数
function Cmd_RetParam(AServer: Pointer; AConnID: DWORD; ACmd: string): Boolean;

//关闭当前任务
function Cmd_EndTask(AClient:Pointer; AGroupName: string; AKey: string): Boolean; overload;
function Cmd_CmdOK(AServer:Pointer; AConnID: DWORD): Boolean; overload;

//--暂停任务
function Cmd_SuspendTask(AClient:Pointer; AGroupName: string): Boolean; overload;
//暂停任务--控制台发起暂停
function Cmd_SuspendTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean; overload;
//--恢复暂停中的任务
function Cmd_ResumeTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;

//结束任务
function Cmd_StopTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;

//执行中的状态描述
function Cmd_RetLog(AClient:Pointer; AJson: string): Boolean;
function Cmd_RetState(AClient:Pointer; AJson: string): Boolean;

//通知角色执行到哪一步了
function Cmd_SetRoleStep(AClient:Pointer; AGroupName:string; ARoleName: string; ARoleStep: Integer): Boolean;
function Cmd_ReSetRoleStep(AClient:Pointer; AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: Integer): Boolean;
function Cmd_GetRoleStep(AClient:Pointer; AGroupName: string): Boolean;
function Cmd_GetTargetRoleStep(AClient:Pointer; AGroupName: string; ARoleName: string; ATargetRoleName: string): Boolean;
function Cmd_SetMasterRecRoleName(AClient:Pointer; AGroupName: string; AOrderNo: string; AMasterRoleName: string; ARecRoleName: string): Boolean;
function Cmd_ClearRecvRoleName(AClient:Pointer; AGroupName: string; AOrderNo: string; ARoleName: string): Boolean;
function Cmd_GetMasterRecRoleName(AClient:Pointer; AGroupName: string; AMasterRoleName: string): Boolean;
function Cmd_RetRoleStep(AServer: Pointer; AConnID: DWORD; ARoleStep: TRoleStep): Boolean;
function Cmd_RetRecvRoleName(AServer: Pointer; AConnID: DWORD; ARecvRoleName: string): Boolean;

//--关机
function Cmd_Shutdown(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
//--重启
function Cmd_ReStart(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
//--注销
function Cmd_Logout(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;


//--
function PostDataToOA(AJson: string; AURL: string): Boolean;
function PostState(AStatusItem: TStatusItem; AURL: string): Boolean; overload;
function PostState(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string; AURL: string): Boolean; overload;
function PostLog(ALogItem: TLogItem; AURL: string): Boolean;
function SetException(AConsoleId: string; ATaskType: Integer; AState: TTaskState; AReason: string): string;
function AddLogLst(AMsg: string): Boolean;

var
  GSocktSC: TRTLCriticalSection;

implementation

uses
  uLogger,
  IdHTTP,
  HPSocketSDKUnit;

function AddLogLst(AMsg: string): Boolean;
var
  vLogItem: TLogItem;
  sAccFlag: string;
begin
  Result := False;
  if GSharedInfo.OrderItem = nil then Exit;

  vLogItem := TLogItem.Create;

  if GSharedInfo.OrderItem.taskType = Integer(tt分仓) then
    sAccFlag := '10'
  else
    sAccFlag := '20';

  vLogItem.GroupName := GSharedInfo.ClientSet.GroupName;
  vLogItem.logType := IntToStr((GSharedInfo.OrderItem.TaskType + 1) * 10);
  vLogItem.logLevel := '1';
  if GSharedInfo.OrderItem.taskType = 1 then
    vLogItem.orderNo := GSharedInfo.OrderItem.key
  else
    vLogItem.orderNo := GSharedInfo.OrderItem.OrderNo;
  vLogItem.detailNo := GSharedInfo.OrderItem.Roles[GSharedInfo.RoleIndex].rowID;
  vLogItem.iP := GSharedInfo.LocalIP;
  vLogItem.AccFlag := sAccFlag;
  vLogItem.Content := ManSoy.Encode.StrToBase64(AMsg);
  LogManager.AddItem(vLogItem);
end;

function PostDataToOA(AJson: string; AURL: string): Boolean;
var
  sRet: string;
  vHttp: TIdHTTP;
  vParams: TStrings;
begin
  Result := False;
  {$IFNDEF _MS_DEBUG}
  vHttp := TIdHTTP.Create();
  vParams := TStringList.Create;
  try
    try
      if AURL = '' then Exit;
      if AJson = '' then Exit;
      vParams.Add(Format('params=%s',[AJson]));
      sRet := vHttp.Post(AURL, vParams);
      Result := sRet = '0';
      if sRet <> '0' then
      begin
        //GCommFuns.PostStatus(sRet, []);
        //AddLogMsg(sRet, []);
        AddLogLst(sRet);
        if Pos('未查询到订单状态', sRet) > 0 then
          Result := True;
        if sRet = '订单状态已经终结！' then
          Result := True;
        if sRet = '订单状态只能升不能降！' then
          Result := True;
      end;
    except
    end;
  finally
    FreeAndNil(vParams);
    vHttp.Disconnect;
    FreeAndNil(vHttp);
  end;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

function PostState(AStatusItem: TStatusItem; AURL: string): Boolean;
var
  sJson: string;
begin
  Result := False;
  if AStatusItem = nil then
  begin
    AddLogMsg('状态类无效, 提交失败...', []);
    Exit;
  end;
  if AURL = '' then
  begin
    AddLogMsg('状态接口无效, 提交失败...', []);
    Exit;
  end;
  if AStatusItem.state in [0, 15, 20, 50, 55] then
  begin
    while True do
    try
      sJson := TSerizalizes.AsJSON<TStatusItem>(AStatusItem);
      if PostDataToOA(sJson, AURL) then Break;
      AddLogMsg('提交状态失败, 稍后尝试...', []);
      Sleep(2000);
    except
    end;
  end;
  Result := True;
end;

function PostState(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string; AURL: string): Boolean;
var
  //sJson: string;
  vStatusItem: TStatusItem;
begin
  Result := false;
  {$IFNDEF _MS_DEBUG}
  if AOrderItem = nil then Exit;
  if Length(AOrderItem.roles) = 0 then Exit;
  if ARoleIndex > Length(AOrderItem.roles) then ARoleIndex := High(AOrderItem.roles);

  vStatusItem := TStatusItem.Create();
  try
    vStatusItem.groupName := AGroupName;
    vStatusItem.rowId := AOrderItem.roles[ARoleIndex].rowId;
    vStatusItem.orderNo := AOrderItem.orderNo;
    vStatusItem.taskType := AOrderItem.taskType;
    vStatusItem.roleId := AOrderItem.roles[ARoleIndex].roleID;
    vStatusItem.isMain := AOrderItem.roles[ARoleIndex].isMain;
    vStatusItem.state := uGlobal.GetStateNum(TTaskState(AOrderItem.roles[ARoleIndex].taskState));
    vStatusItem.reason := ManSoy.Encode.StrToBase64(AOrderItem.roles[ARoleIndex].logMsg);
    vStatusItem.stock := AOrderItem.roles[ARoleIndex].reStock;
    if vStatusItem.state in [15, 20, 100] then
      vStatusItem.stock := -1
    else
      vStatusItem.stock := AOrderItem.roles[ARoleIndex].reStock;
    //sJson := TSerizalizes.AsJSON<TStatusItem>(vStatusItem);
    //AddLogMsg(sJson, [], True);
    Result := PostState(vStatusItem, AURL);
  finally
    FreeAndNil(vStatusItem);
  end;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

function PostLog(ALogItem: TLogItem; AURL: string): Boolean;
var
  sJson: string;
  I: Integer;
begin
  Result := False;
  EnterCriticalSection(GSocktSC);
  try
    sJson := TSerizalizes.AsJSON<TLogItem>(ALogItem);
    if sJson = '' then Exit;
    for I := 0 to 10 do
    begin
      Result := PostDataToOA(sJson, AURL);
      if Result then Break;
      Sleep(1000);
    end;
  finally
    LeaveCriticalSection(GSocktSC);
  end;
end;

function SetException(AConsoleId: string; ATaskType: Integer; AState: TTaskState; AReason: string): string;
var
  sRet: string;
  vHttp: TIdHTTP;
  vParams: TStrings;
begin
  Result := '未知错误...';
  vHttp := TIdHTTP.Create();
  vParams := TStringList.Create;
  try
    try
      if GConsoleSet.SetExceptionInterface = '' then Exit;
      vParams.Add(Format('consoleId=%s',[AConsoleId]));
      vParams.Add(Format('taskType=%d',[ATaskType]));
      vParams.Add(Format('orderState=%d',[uGlobal.GetStateNum(AState)]));
      vParams.Add(Format('exception=%s',[ManSoy.Encode.StrToBase64(AReason)]));
      sRet := vHttp.Post(GConsoleSet.SetExceptionInterface, vParams);
      Result := sRet;
    except on E: Exception do
      Result := E.Message;
    end;
  finally
    FreeAndNil(vParams);
    vHttp.Disconnect;
    FreeAndNil(vHttp);
  end;
end;

function Cmd_Client_Send(AClient: Pointer; ACmd: string): Boolean;
var
  sText: AnsiString;
  I: Integer;
begin
  Result := False;
  EnterCriticalSection(GSocktSC);
  try
    sText := AnsiString(ACmd);
    for I := 1 to 5 do
    begin
      Result := HP_Client_Send(AClient, PAnsiChar(sText), Length(sText) + 1);
      Sleep(10);
      if Result then Break;
    end;
  finally
    LeaveCriticalSection(GSocktSC);
  end;
end;

function Cmd_Server_Send(AServer: Pointer; AConnId: DWORD; ACmd: string): Boolean;
var
  sText: AnsiString;
  I: Integer;
begin
  sText := AnsiString(ACmd);
  for I := 1 to 5 do
  begin
    Result := HP_Server_Send(AServer, AConnId, PAnsiChar(sText), Length(sText) + 1);
    Sleep(10);
    if Result then Break;
  end;
end;

//--发货机连接控制台
function Cmd_Conn(AClient:Pointer; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=Connection,GroupName=%s';
var
  sCmd: string;
  //vBuff: TBytes;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_RetConn(AServer:Pointer; AConnID: DWORD; AIsExist: Boolean): Boolean;
const
  CMD_LINE = 'cmd=RetConn,IsOK=%s';
var
  sCmd: string;
  //vBuff: TBytes;
begin
  sCmd := Format(CMD_LINE, [BoolToStr(AIsExist)]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--获取任务
function Cmd_GetTask(AClient:Pointer; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=GetTask,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_RetTask(AServer: Pointer; AConnID: DWORD; ACmd: string): Boolean;
const
  CMD_LINE = 'cmd=RetTask,Json=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [ManSoy.Encode.StrToBase64(ACmd)]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--获取控制台参数
function Cmd_GetParam(AClient:Pointer; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=GetParam,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

//--返回控制台参数
function Cmd_RetParam(AServer: Pointer; AConnID: DWORD; ACmd: string): Boolean;
const
  CMD_LINE = 'cmd=RetParam,Json=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [ManSoy.Encode.StrToBase64(ACmd)]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//关闭当前任务，发货机结束发货
function Cmd_EndTask(AClient:Pointer; AGroupName: string; AKey: string): Boolean;
const
  CMD_LINE = 'cmd=EndTask,GroupName=%s,Key=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName, AKey]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

//控制台强制结束当前任务
function Cmd_CmdOK(AServer:Pointer; AConnID: DWORD): Boolean; overload;
const
  CMD_LINE = 'cmd=CmdOK';
begin
  Result := Cmd_Server_Send(AServer, AConnID, CMD_LINE);
end;

//暂停任务--发货机发起暂停
function Cmd_SuspendTask(AClient:Pointer; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=SuspendTask,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Client_Send(AClient, CMD_LINE);
end;

//暂停任务--控制台发起暂停
function Cmd_SuspendTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=SuspendTask,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--恢复暂停中的任务
function Cmd_ResumeTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=ResumeTask,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

function Cmd_StopTask(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=StopTask,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//执行中的状态描述
function Cmd_RetLog(AClient:Pointer; AJson: string): Boolean;
const
  CMD_LINE = 'cmd=RetLog,Json=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [ManSoy.Encode.StrToBase64(AJson)]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_RetState(AClient:Pointer; AJson: string): Boolean;
const
  CMD_LINE = 'cmd=RetState,Json=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [ManSoy.Encode.StrToBase64(AJson)]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_SetRoleStep(AClient:Pointer; AGroupName:string; ARoleName: string; ARoleStep: Integer): Boolean;
const
  CMD_LINE = 'cmd=SetRoleStep,GroupName=%s,RoleName=%s,RoleStep=%d';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName, ARoleName, ARoleStep]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_ReSetRoleStep(AClient:Pointer; AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: Integer): Boolean;
const
  CMD_LINE = 'cmd=ReSetRoleStep,GroupName=%s,RoleName=%s,TargetRoleName=%s,RoleStep=%d';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName, ARoleName, ATargetRoleName, ARoleStep]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_GetRoleStep(AClient:Pointer; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=GetRoleStep,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_GetTargetRoleStep(AClient:Pointer; AGroupName: string; ARoleName: string; ATargetRoleName: string): Boolean;
const
  CMD_LINE = 'cmd=GetTargetRoleStep,GroupName=%s,RoleName=%s,TargetRoleName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName, ARoleName, ATargetRoleName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_SetMasterRecRoleName(AClient:Pointer; AGroupName: string; AOrderNo: string; AMasterRoleName: string; ARecRoleName: string): Boolean;
const
  CMD_LINE = 'cmd=SetMasterRecRoleName,GroupName=%s,OrderNo=%s,MasterRoleName=%s,RecvRoleName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName,AOrderNo,AMasterRoleName,ARecRoleName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_ClearRecvRoleName(AClient:Pointer; AGroupName: string; AOrderNo: string; ARoleName: string): Boolean;
const
  CMD_LINE = 'cmd=ClearRecvRoleName,GroupName=%s,OrderNo=%s,RoleName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName,AOrderNo,ARoleName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_GetMasterRecRoleName(AClient:Pointer; AGroupName: string; AMasterRoleName: string): Boolean;
const
  CMD_LINE = 'cmd=GetMasterRecRoleName,GroupName=%s,MasterRoleName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName, AMasterRoleName]);
  Result := Cmd_Client_Send(AClient, sCmd);
end;

function Cmd_RetRecvRoleName(AServer: Pointer; AConnID: DWORD; ARecvRoleName: string): Boolean;
const
  CMD_LINE = 'cmd=RetRecvRoleName,RecvRoleName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [ARecvRoleName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

function Cmd_RetRoleStep(AServer: Pointer; AConnID: DWORD; ARoleStep: TRoleStep): Boolean;
const
  CMD_LINE = 'cmd=RetRoleStep,RoleStep=%d';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [Integer(ARoleStep)]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--关机
function Cmd_Shutdown(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=Shutdown,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--重启
function Cmd_ReStart(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=ReStart,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

//--注销
function Cmd_Logout(AServer:Pointer; AConnID: DWORD; AGroupName: string): Boolean;
const
  CMD_LINE = 'cmd=Logout,GroupName=%s';
var
  sCmd: string;
begin
  sCmd := Format(CMD_LINE, [AGroupName]);
  Result := Cmd_Server_Send(AServer, AConnID, sCmd);
end;

initialization
  InitializeCriticalSection(GSocktSC);

finalization
  DeleteCriticalSection(GSocktSC);

end.

