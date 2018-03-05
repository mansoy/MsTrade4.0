unit uTradeClient;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  System.Generics.Collections,
  HPSocketSDKUnit,
  uJsonClass,
  uCommFuns,
  uGlobal
  ;

type
  TTradeClient = class
  private
    FAppState: EnAppState;
    FClient: Pointer;
    FListener: Pointer;
    FPort: Word;
    FHost: string;
  public
    constructor Create();
    destructor Destroy; override;
    function Start(): En_HP_HandleResult;
    function Stop(): En_HP_HandleResult;
    function DisConn(AConnID: DWORD): En_HP_HandleResult;
    function SendString(AText: string): Boolean;
    {$REGION '通讯'}
    function PostStatus(A信息: string; const Args: array of const; ATaskState: TTaskState = tsNormal; AReStart: Boolean = True): Boolean;
    function GetTask(AGroupName: string): Boolean;
    function GetParam(AGroupName: string): Boolean;
    function SendLog(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string): Boolean;
    /// <remarks>
    /// 结束任务
    /// </remarks>
    function EndTask(AGroupName: string; AKey: string): Boolean;
    function SendStatus(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string): Boolean;
    /// <remarks>
    /// 子号告诉主号，自己的角色，要收多少货, 以及设置自己执行到哪一步了
    /// </remarks>
    function SetRoleStep(AGroupName:string; ARoleName: string; ARoleStep: Integer): Boolean;
    function ReSetRoleStep(AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: Integer): Boolean;
    function GetRoleStep(AGroupName: string): TRoleStep;
    function GetTargetRoleStep(AGroupName: string; ARoleName: string; ATargetRoleName: string): TRoleStep;
    function SetMasterRecRoleName(AGroupName: string; AOrderNo: string; AMasterRoleName: string; ARecRoleName: string): Boolean;
    function ClearRecvRoleName(AGroupName: string; AOrderNo: string; ARoleName: string): Boolean;
    function GetMasterRecRoleName(AGroupName: string; AMasterRoleName: string): string;
    function SuspendTask(AGroupName: string): Boolean;
    {$ENDREGION}
    property Host: string read FHost write FHost;
    property Port: Word read FPort write FPort;
    property AppState: EnAppState read FAppState write FAppState default ST_STOPED;
    property Client: Pointer read FClient write FClient;
    property Listener: Pointer read FListener write FListener;
  end;

  //--解析接收过来的数据
  TDoCmd = class(TThread)
  private
    FCmd: string;
    function StartTask(AJson: string): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(ALen : Integer; AData: Pointer);
  end;

var
  TradeClient: TTradeClient;

implementation

uses
  uAutoSend,
  uCommand,
  ManSoy.Encode,
  ManSoy.Global
  ;

{ TTradeClient }

function OnConnect(dwConnID: DWORD): En_HP_HandleResult; stdcall;
begin
  TradeClient.AppState := ST_STARTED;
  Result := HP_HR_OK;
end;

function OnSend(dwConnID: DWORD; const pData: Pointer; iLength: Integer): En_HP_HandleResult; stdcall;
begin
  //uGlobal.AddLogMsg(' > [%d,OnSend] -> (%d bytes)', [dwConnID, iLength]);
  Result := HP_HR_OK;
  {$IFDEF _MS_DEBUG}
  //Inc(TradeClient.FSendCount);
  //AddLogMsg('Send: %d Recv: %d', [TradeClient.SendCount, TradeClient.RecvCount]);
  {$ENDIF}
end;

function OnReceive(dwConnID: DWORD; const pData: Pointer; iLength: Integer): En_HP_HandleResult; stdcall;
var
  testString: AnsiString;
  doRec : TDoCmd;
begin
  //{$IFDEF _MS_DEBUG}
  //Inc(TradeClient.FRecvCount);
  //{$ENDIF}
  //uGlobal.AddLogMsg(' > [%d,OnReceive] -> (%d bytes)', [dwConnID, iLength], True);

  SetLength(testString, iLength);
  Move(pData^, testString[1],  iLength);
  //uGlobal.AddLogMsg(' > [%d,OnReceive] -> %s', [dwConnId, testString], True);

  doRec := TDoCmd.Create(iLength, pData);
  doRec.Resume;
  Result := HP_HR_OK;
end;

function OnCloseConn(dwConnID: DWORD): En_HP_HandleResult; stdcall;
begin
  uGlobal.AddLogMsg(' > [%d,OnCloseConn]', [dwConnID], True);
  TradeClient.AppState := ST_STOPED;
  Result := HP_HR_OK;
end;

function OnError(dwConnID: DWORD; enOperation: En_HP_SocketOperation; iErrorCode: Integer): En_HP_HandleResult; stdcall;
begin
  uGlobal.AddLogMsg('> [%d,OnError] -> OP:%d,CODE:%d', [dwConnID, Integer(enOperation), iErrorCode], True);
  TradeClient.AppState := ST_STOPED;
  Result := HP_HR_OK;
end;

constructor TTradeClient.Create;
begin
  //{创建监听器对象}
  FListener := Create_HP_TcpClientListener();
  //{创建 Socket 对象}
  FClient := Create_HP_TcpClient(FListener);
  //{设置 Socket 监听器回调函数}
  HP_Set_FN_Client_OnConnect(FListener, OnConnect);
  HP_Set_FN_Client_OnSend(FListener, OnSend);
  HP_Set_FN_Client_OnReceive(FListener, OnReceive);
  HP_Set_FN_Client_OnClose(FListener, OnCloseConn);
  HP_Set_FN_Client_OnError(FListener, OnError);
  FAppState := ST_STOPED;
end;

destructor TTradeClient.Destroy;
begin
  // 销毁 Socket 对象
  Destroy_HP_TcpClient(FClient);
  // 销毁监听器对象
  Destroy_HP_TcpClientListener(FListener);
  inherited;
end;

function TTradeClient.DisConn(AConnID: DWORD): En_HP_HandleResult;
begin

end;

function TTradeClient.SendString(AText: string): Boolean;
var
  sText: AnsiString;
begin
  sText := AnsiString(AText);
  Result := HP_Client_Send(FClient, PAnsiChar(sText), Length(sText) + 1);
end;

{$REGION '通讯'}
function TTradeClient.PostStatus(A信息: string; const Args: array of const; ATaskState: TTaskState = tsNormal; AReStart: Boolean = True): Boolean;
var
  sMsg: string;
  sAccFlag: string;
begin
  sMsg := System.SysUtils.Format(A信息, Args, FormatSettings);
  AddLogMsg(sMsg, []);


  GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].taskState := Integer(ATaskState);
  GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].logMsg := sMsg;
  if GSharedInfo.bReStart then
    GSharedInfo.bReStart := AReStart;
  PostLogFile('PostStatus: 内容[%s]状态[%d]重启[%s-%s]', [sMsg, Integer(ATaskState), BoolToStr(AReStart), BoolToStr(GSharedInfo.bReStart)]);
  GSharedInfo.TaskStatus := ATaskState;

  //---添加日志列表
  uCommand.AddLogLst(sMsg);
  GSharedInfo.bSuspendTask := GSharedInfo.TaskStatus = tsSuspend;
  TradeClient.SendStatus(GSharedInfo.OrderItem, GSharedInfo.RoleIndex, GSharedInfo.ClientSet.GroupName);

  Result := True;
end;

function TTradeClient.GetTask(AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_GetTask(Client, AGroupName);
end;

function TTradeClient.GetParam(AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_GetParam(Client, AGroupName);
end;

function TTradeClient.SendLog(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string): Boolean;
var
  sJson: string;
  vLogItem: TLogItem;
  sAccFlag: string;
begin
  Result := false;
  if AOrderItem = nil then Exit;
  if Length(AOrderItem.roles) = 0 then Exit;
  if ARoleIndex > Length(AOrderItem.roles) then ARoleIndex := High(AOrderItem.roles);

  vLogItem := TLogItem.Create();
  try
    vLogItem.groupName  := AGroupName;
    vLogItem.detailNo   := AOrderItem.roles[ARoleIndex].rowId;
    vLogItem.orderNo    := AOrderItem.orderNo;
    vLogItem.logLevel   := '1';
    vLogItem.logType    := IntToStr((AOrderItem.taskType + 1) * 10);
    if AOrderItem.roles[ARoleIndex].isMain then
      sAccFlag := '10'
    else
      sAccFlag := '20';
    vLogItem.accFlag    := sAccFlag;
    vLogItem.ip         := GSharedInfo.LocalIP;
    vLogItem.content    := AOrderItem.roles[ARoleIndex].logMsg;
    sJson := TSerizalizes.AsJSON<TLogItem>(vLogItem);
    { TODO : TODO }
    AddLogMsg(sJson, []);
    Result := uCommand.Cmd_RetLog(Client, sJson);
    if not Result then
    begin
      AddLogMsg('发送日志[%s]失败', [vLogItem.content]);
    end;
  finally
    FreeAndNil(vLogItem);
  end;
end;

function TTradeClient.SetRoleStep(AGroupName:string; ARoleName: string; ARoleStep: Integer): Boolean;
begin
  Result := False;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    Result := uCommand.Cmd_SetRoleStep(Client, AGroupName, ARoleName, ARoleStep);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := True;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.ReSetRoleStep(AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: Integer): Boolean;
begin
  Result := False;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_ReSetRoleStep(Client, AGroupName, ARoleName, ATargetRoleName, ARoleStep);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := True;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.GetRoleStep(AGroupName: string): TRoleStep;
begin
  Result := rsNormal;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_GetRoleStep(Client, AGroupName);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := GSharedInfo.RoleStep;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.GetTargetRoleStep(AGroupName: string; ARoleName: string; ATargetRoleName: string): TRoleStep;
begin
  Result := rsNormal;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_GetTargetRoleStep(Client, AGroupName, ARoleName, ATargetRoleName);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := GSharedInfo.RoleStep;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.SetMasterRecRoleName(AGroupName: string; AOrderNo: string; AMasterRoleName: string; ARecRoleName: string): Boolean;
begin
  Result := False;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_SetMasterRecRoleName(Client, AGroupName, AOrderNo, AMasterRoleName, ARecRoleName);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := True;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.ClearRecvRoleName(AGroupName: string; AOrderNo: string; ARoleName: string): Boolean;
begin
  Result := False;
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_ClearRecvRoleName(Client, AGroupName, AOrderNo, ARoleName);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      Result := True;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.GetMasterRecRoleName(AGroupName: string; AMasterRoleName: string): string;
begin
  Result := '';
  GSharedInfo.bCmdOk := False;
  while True do
  try
    uCommand.Cmd_GetMasterRecRoleName(Client, AGroupName, AMasterRoleName);
    Sleep(200);
    if GSharedInfo.bCmdOk then
    begin
      if GSharedInfo.RecvRoleName <> '' then
      begin
        if GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].ReceiptRole <> GSharedInfo.RecvRoleName then
          GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].ReceiptRole := GSharedInfo.RecvRoleName;
      end;
      Result := GSharedInfo.RecvRoleName;
      Exit;
    end;
  except
  end;
end;

function TTradeClient.EndTask(AGroupName: string; AKey: string): Boolean;
begin
  Result := uCommand.Cmd_EndTask(Client, AGroupName, AKey);
end;

function TTradeClient.SendStatus(AOrderItem: TOrderItem; ARoleIndex: Integer; AGroupName: string): Boolean;
var
  sJson: string;
  vStatusItem: TStatusItem;
begin
  Result := false;
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
    vStatusItem.state := AOrderItem.roles[ARoleIndex].taskState;
    if AOrderItem.roles[ARoleIndex].logMsg = '' then
      vStatusItem.reason := ''
    else
      vStatusItem.reason := ManSoy.Encode.StrToBase64(AOrderItem.roles[ARoleIndex].logMsg);
    vStatusItem.stock := AOrderItem.roles[ARoleIndex].reStock;
    sJson := TSerizalizes.AsJSON<TStatusItem>(vStatusItem);
    Result := uCommand.Cmd_RetState(Client, sJson);
  finally
    FreeAndNil(vStatusItem);
  end;
end;

function TTradeClient.SuspendTask(AGroupName: string): Boolean;
begin
  Result := uCommand.Cmd_SuspendTask(Client, AGroupName);
end;

{$ENDREGION}

function TTradeClient.Start: En_HP_HandleResult;
begin
  Result := HP_HR_OK;
  // 异常检查自己做
  if (Host = '') or (Port = 0) then
  begin
    uGlobal.AddLogMsg('启动失败, 请检查服务器IP是否已经设置', []);
    Exit;
  end;

  // 写在这个位置是上面可能会异常
  FAppState := ST_STARTING;
  if not (HP_Client_Start(FClient, PWideChar(Host), Port, False)) then
  begin
    FAppState := ST_STOPED;
    uGlobal.AddLogMsg('Client Start Error -> %s(%d)',
      [
        HP_Client_GetLastErrorDesc(FClient),
        Integer( HP_Client_GetLastError(FClient))
      ]);
    Exit;
  end;

  FAppState := ST_STARTED;
  AddLogMsg('$Client Starting ... -> (%s:%d)', [Host, port], True);
end;

function TTradeClient.Stop: En_HP_HandleResult;
begin
  Result := HP_HR_ERROR;
  FAppState := ST_STOPING;
  // 停止服务

  if not (HP_Client_Stop(FClient)) then
  begin
    uGlobal.AddLogMsg('$Stop Error -> %s(%d)',
      [
        HP_Client_GetLastErrorDesc(FClient),
        Integer(HP_Client_GetLastError(FClient))
      ]);
    Exit;
  end;
  FAppState := ST_STOPED;
  uGlobal.AddLogMsg('$Server Stop', [], True);
  Result := HP_HR_OK;
end;

{ TDoCmd }

constructor TDoCmd.Create(ALen: Integer; AData: Pointer);
var
  sCmd: AnsiString;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  // 以下是一个pData转字符串的演示
  SetLength(sCmd, ALen);
  Move(AData^, sCmd[1],  ALen);
  FCmd := Trim(string(sCmd));
end;

procedure TDoCmd.Execute;
var
  vLst: TStrings;
  sJson, sGroupName: string;
  bResume, bOk: Boolean;
begin
  //inherited;
  if FCmd = '' then Exit;
  { TODO : 在这里处理，服务端请求 }
  vLst := TStringList.Create;
  try
    vLst.DelimitedText := FCmd;
    vLst.Delimiter := ',';
    if vLst.Count = 0 then Exit;
    if vLst.Values['cmd'] = '' then Exit;
    if vLst.Values['cmd'] = 'RetTask' then
    begin
      // TODO : 获取到了新任务
      vLst.SaveToFile(GSharedInfo.AppPath + '123.json');
      sJson := Trim(ManSoy.Encode.Base64ToStr(vLst.Values['Json']));
      if sJson = '' then Exit;
      if sJson = 'nil' then Exit;
      StartTask(sJson);
    end else if vLst.Values['cmd'] = 'CmdOK' then
    begin
      GSharedInfo.bCmdOk := True;
    end else if vLst.Values['cmd'] = 'RetConn' then
    begin
      bOk := StrToBoolDef(vLst.Values['IsOk'], False);
      if not bOk then
      begin
        TradeClient.Stop;
        GSharedInfo.bConnOK := False;
        AddLogMsg('发货机名称重复...', []);
        SendMessage(GSharedInfo.MainFormHandle, WM_DIS_CONN, 0, 0);
        Exit;
      end;
      GSharedInfo.bConnOK := True;
    end else if vLst.Values['cmd'] = 'RetRoleStep' then
    begin
      ManSoy.Global.DebugInf('MS - RetRoleStep: %s', [FCmd]);
      GSharedInfo.RoleStep := TRoleStep(StrToIntDef(vLst.Values['RoleStep'], 0));
      GSharedInfo.bCmdOk := True;
    end else if vLst.Values['cmd'] = 'RetRecvRoleName' then
    begin
      ManSoy.Global.DebugInf('MS - RetRecvRoleName: %s', [FCmd]);
      GSharedInfo.RecvRoleName := Trim(vLst.Values['RecvRoleName']);
      GSharedInfo.bCmdOk := True;
    end else if vLst.Values['cmd'] = 'SuspendTask' then
    begin
      AddLogMsg(vLst.Text, [], True);
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      GSharedInfo.bSuspendTask := True;
    end else if vLst.Values['cmd'] = 'ResumeTask' then
    begin
      AddLogMsg(vLst.Text, [], True);
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      GSharedInfo.bSuspendTask := False;
    end else if vLst.Values['cmd'] = 'StopTask' then
    begin
      AddLogMsg(vLst.Text, [], True);
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      GSharedInfo.bStopTask := True;
    end else if vLst.Values['cmd'] = 'RetParam' then
    begin
      sJson := Trim(ManSoy.Encode.Base64ToStr(vLst.Values['Json']));
      if sJson = '' then Exit;
      if sJson = 'nil' then Exit;

      if not TSerizalizes.AsType<TConsoleSet>(sJson, GConsoleSet) then Exit;
      if GConsoleSet = nil then Exit;
    end else if vLst.Values['cmd'] = 'Shutdown' then
    begin
      AddLogMsg(vLst.Text, [], True);
      if GSharedInfo.bWork then Exit;
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE,   0);
    end else if vLst.Values['cmd'] = 'ReStart' then
    begin
      AddLogMsg(vLst.Text, [], True);
      if GSharedInfo.bWork then Exit;
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      ExitWindowsEx(EWX_REBOOT or EWX_FORCE,   0);
    end else if vLst.Values['cmd'] = 'Logout' then
    begin
      AddLogMsg(vLst.Text, [], True);
      if GSharedInfo.bWork then Exit;
      sGroupName := vLst.Values['GroupName'];
      if sGroupName <> GSharedInfo.ClientSet.GroupName then Exit;
      ExitWindowsEx(EWX_LOGOFF or EWX_FORCE, 0);
    end;
  finally
    FreeAndNil(vLst);
  end;
end;

function TDoCmd.StartTask(AJson: string): Boolean;
var
  sJson: string;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
  bIsMain: Boolean;
  I: Integer;
begin
  Result := False;
  try
    if not TSerizalizes.AsType<TOrderItem>(AJson, vOrderItem) then Exit;
    if vOrderItem = nil then Exit;
    if Length(vOrderItem.roles) = 0 then Exit;
    if GSharedInfo.bWork then Exit;
    TAutoSend.Create(vOrderItem);
    Result := True;
  except
  end;
end;

initialization
  TradeClient := TTradeClient.Create;

finalization
  if TradeClient.FAppState = ST_STARTED then
  begin
    TradeClient.Stop;
  end;
  FreeAndNil(TradeClient);

end.
