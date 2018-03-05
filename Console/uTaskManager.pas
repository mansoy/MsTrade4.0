unit uTaskManager;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  uJsonClass,
  uGlobal,
  ManSoy.Encode,
  ManSoy.Global,
  uDToolServer,
  uCommand
  ;

type
  TTaskManager = class
  private
    FCS: TRTLCriticalSection;
    FItems: TObjectDictionary<string,TOrderItem>;
    function GetCount: Integer;
    function GetItem(AKey: string): TOrderItem;
    procedure SetItem(AKey: string; const Value: TOrderItem);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AOrderItem: TOrderItem);
    procedure Del(AKey: string);
    procedure DelByOrderNo(AOrderNo: string);
    procedure DelQueueByOrderNo(AOrderNo: string);
    procedure DelByKey(AKey: string);
    function GetMasterOrderItem(AOrderItem: TOrderItem): TOrderItem; overload;
    function GetMasterOrderItem(AOrderNo: string; AMasterRoleName: string): TOrderItem; overload;
    /// <remarks>
    /// 获取同一个订单低下的任务还有多少个， IsBusy: 0: 不判断IsBusy 1：IsBusy=True 2：IsBusy=False
    /// </remarks>
    function GetSameTaskCount(AOrderNo: string; AIsBusy: Integer = 0): Integer;
    /// <remarks>
    /// 设置子号信息
    /// </remarks>
    function SetRoleStep(AChildInfo: string; AConnID: DWORD): Boolean;
    function SetMasterRecRoleName(ACmd: string; AConnID: DWORD): Boolean;
    function ClearRecvRoleName(ACmd: string; AConnID: DWORD): Boolean;
    function GetCanSendTask(ATaskType: TTaskType = tt发货): TOrderItem;
    function ContainsKey(AKey: string): Boolean;
    function EndChildTask(AOrderNo: string): Boolean;
    property Count: Integer read GetCount;
    property Items[AKey: string]: TOrderItem read GetItem write SetItem;
  end;

  TConnItem = class
  private
    FConnID: Integer;
    FGroupName: string;
    FOrderItem: TOrderItem;
    FState: TSendMachineState;
    FRoleStep: TRoleStep;
    FInterval: DWORD;
    //FLogMsg: string;
    FSuspend: Boolean;
    FIsAbnormal: Boolean;
    FLogMsgs: TStrings;
    FIsMain: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    property ConnID: Integer read FConnID write FConnID;
    /// <remarks>
    /// 发货机编号
    /// </remarks>
    property GroupName: string read FGroupName write FGroupName;
    /// <remarks>
    /// 当前任务实体
    /// </remarks>
    property OrderItem: TOrderItem read FOrderItem write FOrderItem;
    /// <remarks>
    /// 发货机状态
    /// </remarks>
    property State: TSendMachineState read FState write FState;
    /// <remarks>
    /// 角色执行到哪一步了
    /// </remarks>
    property RoleStep: TRoleStep read FRoleStep write FRoleStep;
    /// <remarks>
    /// 当前任务耗时
    /// </remarks>
    property Interval: DWORD read FInterval write FInterval;
    //property LogMsg: string read FLogMsg write FLogMsg;
    /// <remarks>
    /// 任务暂停标记
    /// </remarks>
    property Suspend: Boolean read FSuspend write FSuspend;
    /// <remarks>
    /// 发货机异常中断
    /// </remarks>
    property IsAbnormal: Boolean read FIsAbnormal write FIsAbnormal default False;
    /// <remarks>
    /// 发货机日志记录
    /// </remarks>
    property LogMsgs: TStrings read FLogMsgs write FLogMsgs;
    /// <remarks>
    /// 如果是分仓任务的话， 标记是不是主号
    /// </remarks>
    //property IsMain: Boolean read FIsMain write FIsMain;
  end;

  TConnManager = class
  private
    FCS: TRTLCriticalSection;
    FItems: TObjectDictionary<string,TConnItem>;
    function GetCount: Integer;
    function GetItem(AKey: string): TConnItem;
    procedure SetItem(AKey: string; const Value: TConnItem);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AConnItem: TConnItem);
    procedure Del(AKey: string);
    function GetFreeMachine: TConnItem;
    function GetFreeCount: Integer;
    function GetGroupName(AConnID: DWORD): string;
    function GetMasterConnItem(AConnItem: TConnItem): TConnItem; overload;
    function GetMasterConnItem(AOrderNo: string): TConnItem; overload;
    function GetTargerConnItem(ATargetRoleName:string; AOrderNo:string): TConnItem;
    function GetConnOrderInfo(AGroupName: string): string;
    function GetConnItem(AOrderNo: string; ARoleName: string): TConnItem;

    function SuspendTask(AGroupName: string): Boolean;
    function ReStartTask(AGroupName: string): Boolean;
    function StopTask(AGroupName: string): Boolean;
    function SuspendAllTask: Boolean;
    function ReStartAllTask: Boolean;
    function StopAllTask(AOrderNo: string): Boolean;
    function ReSetRoleStep(AConnID: DWORD; AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: TRoleStep): Boolean;
    function RetRoleStep(AConnID: DWORD; AGroupName: string): Boolean;
    function RetTargetRoleStep(AConnID: DWORD; AGroupName: string; ARoleName: string; ATargetRoleName: string): Boolean;
    function RetRecvRoleName(AConnId: DWORD; AGroupName: string; AMasterRoleName: string): Boolean;

    function ClearLog(AGroupName: string): Boolean;
    function ClearAllLog: Boolean;

    function LogoutAll: Boolean;
    function ReBootAll: Boolean;
    function ShutdownAll: Boolean;

    property Count: Integer read GetCount;
    property Items[AKey: string]: TConnItem read GetItem write SetItem;
  end;

var
  TaskManager: TTaskManager;
  ConnManager: TConnManager;


function DispatchOrder(ATaskType: TTaskType): Boolean;
function AddConnItem(AConnID: DWORD; AGroupName: string): Boolean;
function DelConnItem(AConnID: DWORD; AGroupName: string): Boolean;
/// <remarks>
/// 发货机发货完成(失败)时调用
/// </remarks>
function EndTask(AGroupName: string; AKey: string): Boolean;
function SuspendTask(AGroupName: string): Boolean;
//function SetTaskLog(AJson: string): Boolean;
function SetTaskState(AJson: string): Boolean;

function AddOrder(AJson: string): Boolean;

implementation

function DispatchOrder(ATaskType: TTaskType): Boolean;
var
  iFreeCount: Integer;
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;

begin
  Result := False;
  EnterCriticalSection(CS_OP_Task);
  try
    if GSharedInfo.TaskType = ttNormal then Exit;
    try
      vOrderItem := TaskManager.GetCanSendTask(ATaskType);
      if vOrderItem = nil then Exit;

      vConnItem := ConnManager.GetFreeMachine;
      if vConnItem = nil then Exit;

      vConnItem.OrderItem := vOrderItem;
      vConnItem.State := sms繁忙;
      vConnItem.RoleStep := rsNormal;
      vConnItem.Interval := GetTickCount;
      vConnItem.LogMsgs.Add('开始处理任务');
      vOrderItem.isBusy := True;
      for vRoleItem in vOrderItem.roles do
        vRoleItem.taskState := Integer(tsStart);

      SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(vOrderItem.key));
      SendMessage(GSharedInfo.MainFormHandle, WM_UPDATE_CONN_UI, 0, LParam(vConnItem.GroupName));
    except on E: Exception do
      AddLogMsg('分配订单异常: %s', [E.Message]);
    end;
  finally
    LeaveCriticalSection(CS_OP_Task);
  end;
end;

function AddConnItem(AConnID: DWORD; AGroupName: string): Boolean;
var
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
begin
  Result := False;
  EnterCriticalSection(CS_OP_Task);
  try
    try
      if AGroupName = '' then Exit;
      if ConnManager.Items[AGroupName] <> nil then
      begin
        { TODO : 通知发货机，已经有一个同名的存在了 }
        uCommand.Cmd_RetConn(ConsoleSvr.Server, AConnID, False);
        Exit;
      end;
      vConnItem := TConnItem.Create;
      vConnItem.ConnID := AConnID;
      vConnItem.GroupName := AGroupName;
      ConnManager.Add(vConnItem);
      SendMessage(GSharedInfo.MainFormHandle, WM_ADD_SEND_MACHINE, 0, LParam(vConnItem));
      uCommand.Cmd_RetConn(ConsoleSvr.Server, AConnID, True);
    except on E: Exception do
      AddLogMsg('添加发货机异常: %s', [E.Message]);
    end;
  finally
    LeaveCriticalSection(CS_OP_Task);
  end;
end;

function DelConnItem(AConnID: DWORD; AGroupName: string): Boolean;
var
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
begin
  Result := False;
  EnterCriticalSection(CS_OP_Task);
  try
    try
      if AGroupName = '' then Exit;
      if ConnManager.Items[AGroupName] = nil then
      begin
        Exit;
      end;
      SendMessage(GSharedInfo.MainFormHandle, WM_DEL_SEND_MACHINE, 0, LParam(vConnItem.GroupName));
      ConnManager.Del(AGroupName);
    except on E: Exception do
      AddLogMsg('删除发货机异常: %s', [E.Message]);
    end;
  finally
    LeaveCriticalSection(CS_OP_Task);
  end;
end;

function EndTask(AGroupName: string; AKey: string): Boolean;
var
  vConnItem, vMasterConnItem: TConnItem;
  vOrderItem, vMasterOrderItem: TOrderItem;
  iCount: Integer;
  vRoleItem, vMasterRoleItem: TRoleItem;
begin
  EnterCriticalSection(CS_OP_Task);
  try
    try
      if AGroupName = '' then Exit;
      vConnItem := ConnManager.Items[AGroupName];
      if vConnItem = nil then Exit;
      vOrderItem := vConnItem.OrderItem;
      if vOrderItem = nil then Exit;

      if vOrderItem.key = AKey then
      begin

        if vOrderItem.taskType = Integer(tt分仓) then
        begin
          { TODO : 在这里处理分仓，任务结束逻辑 }
          //--子号的话先查看一下有没有相同的子号（接收来自同一个库存角色）存在， 如果没有，就将主号的状态设置为finished
          for vRoleItem in vOrderItem.roles do
          begin
            if vRoleItem.isMain then
            begin
              TaskManager.EndChildTask(vOrderItem.orderNo);
            end else
            begin
              vMasterConnItem := ConnManager.GetMasterConnItem(vOrderItem.orderNo);
              if vMasterConnItem = nil then Continue;
              vMasterOrderItem := vMasterConnItem.OrderItem;
              if vMasterOrderItem = nil then Continue;

              iCount := TaskManager.GetSameTaskCount(vOrderItem.orderNo);
              if iCount <= 1 then
              begin
                vMasterConnItem.RoleStep := rsFinished;
              end;

              for vMasterRoleItem in vMasterOrderItem.roles do
              begin
                if vRoleItem.receiptRole <> vMasterRoleItem.role then Continue;
                AddLogMsg('子号角色：%s', [vMasterRoleItem.receiptRole], True);
                vMasterRoleItem.receiptRole := '';
                SendMessage(GSharedInfo.MainFormHandle, WM_UPDATE_CONN_UI, 0, LPARAM(vMasterConnItem.GroupName));
                AddLogMsg('子号角色：%s', [vMasterRoleItem.receiptRole], True);
              end;
            end;
          end;
        end;

        TaskManager.Del(vOrderItem.key);
        vConnItem.OrderItem := nil;
        vConnItem.State := sms空闲;
        vConnItem.RoleStep := rsNormal;
        vConnItem.Suspend := False;
        //vConnItem.LogMsg := '';
        SendMessage(GSharedInfo.MainFormHandle, WM_UPDATE_CONN_UI, 0, LPARAM(AGroupName));
      end;
      ConsoleSvr.RetCmdOk(vConnItem.ConnID);
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_Task);
  end;
end;

function SuspendTask(AGroupName: string): Boolean;
var
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
begin
  EnterCriticalSection(CS_OP_Task);
  try
    try
      if AGroupName = '' then Exit;
      vConnItem := ConnManager.Items[AGroupName];
      if vConnItem = nil then Exit;
      if vConnItem.OrderItem = nil then Exit;
      if vConnItem.State <> sms空闲 then Exit;
      vConnItem.Suspend := True;
      SendMessage(GSharedInfo.MainFormHandle, WM_UPDATE_CONN_UI, 0, LPARAM(AGroupName));
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_Task)
  end;
end;

function SetTaskState(AJson: string): Boolean;
var
  vStateItem: TStatusItem;
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
begin
  Result := False;
  if AJson = '' then Exit;
  EnterCriticalSection(CS_OP_Task);
  try
    try
      AJson := ManSoy.Encode.Base64ToStr(AJson);
      //AddLogMsg(AJson, [], True);
      if not TSerizalizes.AsType<TStatusItem>(AJson, vStateItem) then Exit;
      if vStateItem = nil then Exit;
      try
        if vStateItem.groupName = '' then Exit;
        vConnItem := ConnManager.Items[vStateItem.groupName];
        if vConnItem = nil then Exit;
        {$IFNDEF _MS_DEBUG}
        vOrderItem := vConnItem.OrderItem;
        if vOrderItem = nil then Exit;
        {$ENDIF}

        if vStateItem.reason <> '' then
          vConnItem.LogMsgs.Add(ManSoy.Encode.Base64ToStr(vStateItem.reason));
        {$IFNDEF _MS_DEBUG}
        for vRoleItem in vOrderItem.roles do
        begin
          if vRoleItem.rowId = vStateItem.rowId then
          begin
            if vStateItem.state <> 100 then
            vRoleItem.taskState := vStateItem.state;
            if (vStateItem.state = Integer(tsSuspend)) and (not vConnItem.Suspend) then
            begin
              vConnItem.Suspend := True;
            end;

            if vStateItem.reason <> '' then
              vRoleItem.logMsg := ManSoy.Encode.Base64ToStr(vStateItem.reason);
          end;
        end;
        {$ENDIF}
        // TODO :: 按时屏蔽SendMessage消息
        SendMessage(GSharedInfo.MainFormHandle, WM_UPDATE_CONN_UI, 0, LPARAM(vStateItem.groupName));
      finally
        FreeAndNil(vStateItem);
      end;
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_Task)
  end;
end;

function AddOrder(AJson: string): Boolean;
var
  sJson: string;
  vOrders: TArray<TOrderItem>;
  vOrderItem: TOrderItem;
begin
  EnterCriticalSection(CS_OP_Task);
  try
    try
      sJson := AJson;
      //MessageBox(0, PWideChar(sJson), 0, 0);
      if not TSerizalizes.AsType<TArray<TOrderItem>>(sJson, vOrders) then Exit;
      if Length(vOrders) = 0 then Exit;
      for vOrderItem in vOrders do
      begin
        if TaskManager.ContainsKey(vOrderItem.key) then Continue;
        TaskManager.Add(vOrderItem);
        //--提交状态
        SendMessage(GSharedInfo.MainFormHandle, WM_ADD_ORDER, 0, LPARAM(vOrderItem));
      end;
    except

    end;
  finally
    LeaveCriticalSection(CS_OP_Task)
  end;
end;

{ TTaskManager }

function TTaskManager.ContainsKey(AKey: string): Boolean;
begin
  EnterCriticalSection(FCS);
  try
    Result := FItems.ContainsKey(AKey);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

constructor TTaskManager.Create;
begin
  FItems := TObjectDictionary<string,TOrderItem>.Create([doOwnsValues]);
  InitializeCriticalSection(FCS);
end;

destructor TTaskManager.Destroy;
begin
  FItems.Free;
  DeleteCriticalSection(FCS);
  inherited;
end;

function TTaskManager.EndChildTask(AOrderNo: string): Boolean;
var
  vOrderItem: TOrderItem;
  I: Integer;
  bDoing: Boolean;
begin
  EnterCriticalSection(FCS);
  try
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = AOrderNo then
      begin
        for I := Low(vOrderItem.roles) to High(vOrderItem.roles) do
        begin
          if vOrderItem.roles[I].isMain then Continue;
          if vOrderItem.isBusy then
          begin
            bDoing := ConnManager.GetConnItem(vOrderItem.orderNo, vOrderItem.roles[i].role) <> nil;
            if bDoing then Continue;
          end;
          vOrderItem.roles[I].taskState := Integer(tsFail);
          vOrderItem.roles[I].logMsg := '主号退出, 任务失败';
          uCommand.PostState(vOrderItem, I, '', GConsoleSet.StateInterface);
          SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(vOrderItem.key));
          FItems.Remove(vOrderItem.key);
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TTaskManager.Add(AOrderItem: TOrderItem);
begin
  EnterCriticalSection(FCS);
  try
    if ContainsKey(AOrderItem.key) then Exit;
    FItems.AddOrSetValue(AOrderItem.key, AOrderItem);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TTaskManager.Del(AKey: string);
var
  sKey: string;
  I: Integer;
begin
  EnterCriticalSection(FCS);
  try
    SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(AKey));
    FItems.Remove(AKey);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TTaskManager.DelByOrderNo(AOrderNo: string);
var
  vOrderItem: TOrderItem;
  I: Integer;
begin
  EnterCriticalSection(FCS);
  try
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = AOrderNo then
      begin
        for I := Low(vOrderItem.roles) to High(vOrderItem.roles) do
        begin
          vOrderItem.roles[I].taskState := Integer(tsFail);
          vOrderItem.roles[I].logMsg := '人为终止任务';
          uCommand.PostState(vOrderItem, I, '', GConsoleSet.StateInterface);
        end;
        SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(vOrderItem.key));
        FItems.Remove(vOrderItem.key);
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;


procedure TTaskManager.DelQueueByOrderNo(AOrderNo: string);
var
  vOrderItem: TOrderItem;
  I: Integer;
begin
  EnterCriticalSection(FCS);
  try
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.isBusy then Continue;
      if vOrderItem.orderNo = AOrderNo then
      begin
        for I := Low(vOrderItem.roles) to High(vOrderItem.roles) do
        begin
          vOrderItem.roles[I].taskState := Integer(tsFail);
          vOrderItem.roles[I].logMsg := '人为终止任务';
          uCommand.PostState(vOrderItem, I, '', GConsoleSet.StateInterface);
        end;
        SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(vOrderItem.key));
        FItems.Remove(vOrderItem.key);
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TTaskManager.DelByKey(AKey: string);
var
  vOrderItem: TOrderItem;
  I: Integer;
begin
  EnterCriticalSection(FCS);
  try
    if Count = 0 then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.key = AKey then
      begin
        for I := Low(vOrderItem.roles) to High(vOrderItem.roles) do
        begin
          vOrderItem.roles[I].taskState := Integer(tsFail);
          vOrderItem.roles[I].logMsg := '人为终止任务';
          uCommand.PostState(vOrderItem, I, '', GConsoleSet.StateInterface);
        end;
        SendMessage(GSharedInfo.MainFormHandle, WM_DEL_ORDER, 0, LPARAM(vOrderItem.key));
        FItems.Remove(vOrderItem.key);
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetCanSendTask(ATaskType: TTaskType): TOrderItem;
var
  sKey: string;
  vOrderItem: TOrderItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.isBusy then Continue;
      if ATaskType = tt分仓 then
      begin
        //--并且已经有两个子号在线上， 则不能上号
        if GetSameTaskCount(vOrderItem.orderNo, 1) >= 2 then Continue;

        if (not vOrderItem.roles[0].isMain) then
        begin
          //--如果主号还没上号，则不能上号
          if ConnManager.GetMasterConnItem(vOrderItem.orderNo) = nil then Continue;
        end else
        begin
          if ConnManager.GetFreeCount < 2 then Continue;
        end;
      end;
      Result := vOrderItem;
      Break;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetCount: Integer;
begin
  Result := 0;
  EnterCriticalSection(FCS);
  try
    Result := FItems.Count;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetItem(AKey: string): TOrderItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AKey) then Exit;
    Result := FItems.Items[AKey];
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetMasterOrderItem(AOrderNo, AMasterRoleName: string): TOrderItem;
var
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
begin
  EnterCriticalSection(FCS);
  Result := nil;
  try
    if FItems.Count = 0 then Exit;
    if AOrderNo = '' then Exit;
    if AMasterRoleName = '' then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = '' then Continue;
      if vOrderItem.orderNo <> AOrderNo then Continue;
      for vRoleItem in vOrderItem.roles do
      begin
        if not vRoleItem.isMain then Continue;
        if (vRoleItem.role = AMasterRoleName) then
        begin
          Result := vOrderItem;
          Exit;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetMasterOrderItem(AOrderItem: TOrderItem): TOrderItem;
var
  vOrderItem: TOrderItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    if FItems.Count = 0 then Exit;
    if AOrderItem = nil then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = '' then Continue;
      if (vOrderItem.orderNo = AOrderItem.orderNo) and (vOrderItem.roles[0].isMain) then
      begin
        Result := vOrderItem;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.GetSameTaskCount(AOrderNo: string; AIsBusy: Integer): Integer;
var
  vOrderItem: TOrderItem;
begin
  Result := 0;
  EnterCriticalSection(FCS);
  try
    if FItems.Count = 0 then Exit;
    if AOrderNo = '' then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = '' then Continue;
      if (vOrderItem.OrderNo = AOrderNo) and (not vOrderItem.roles[0].isMain) then
      begin
        if (AIsBusy = 0) then
        begin
          Result := Result + 1;
        end else if AIsBusy = 1 then
        begin
          if vOrderItem.isBusy then
          begin
            Result := Result + 1;
          end;
        end else if AIsBusy = 2 then
        begin
          if not vOrderItem.isBusy then
          begin
            Result := Result + 1;
          end;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.SetRoleStep(AChildInfo: string; AConnID: DWORD): Boolean;
var
  vLst: TStrings;
  sGroupName, sRoleName: string;
  vRoleStep: TRoleStep;
  vConnItem, vMasterConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  vLst := TStringList.Create;
  try
    vLst.Delimiter := ',';
    vLst.DelimitedText := AChildInfo;
    if vLst.Count = 0 then Exit;
    sGroupName := vLst.Values['GroupName'];
    sRoleName := vLst.Values['RoleName'];
    vRoleStep := TRoleStep(StrToIntDef(vLst.Values['RoleStep'], 0));

    vConnItem := ConnManager.Items[sGroupName];

    if (vConnItem = nil) then Exit;
    vConnItem.RoleStep := vRoleStep;
    Result := True;
  finally
    //--通知子号， 修改完成了
    ConsoleSvr.RetCmdOk(AConnID);
    FreeAndNil(vLst);
    LeaveCriticalSection(FCS);
  end;
end;

procedure TTaskManager.SetItem(AKey: string; const Value: TOrderItem);
begin
  EnterCriticalSection(FCS);
  try
    FItems.AddOrSetValue(AKey, Value);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.SetMasterRecRoleName(ACmd: string; AConnID: DWORD): Boolean;
var
  vLst: TStrings;
  sGroupName, sOrderNo, sRoleName, sMasterRoleName: string;
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
  vIsMain: Boolean;
  vRoleItem: TRoleItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  vLst := TStringList.Create;
  try
    vLst.Delimiter := ',';
    vLst.DelimitedText := ACmd;
    if vLst.Count = 0 then Exit;
    sGroupName := vLst.Values['GroupName'];
    sOrderNo := vLst.Values['OrderNo'];
    sRoleName := vLst.Values['RecvRoleName'];
    sMasterRoleName := vLst.Values['MasterRoleName'];

    if sOrderNo = '' then Exit;
    if sRoleName = '' then Exit;
    if sMasterRoleName = '' then Exit;
    if FItems.Count = 0 then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = '' then Continue;
      if vOrderItem.orderNo <> sOrderNo then Continue;
      for vRoleItem in vOrderItem.roles do
      begin
        if not vRoleItem.isMain then Continue;
        if vRoleItem.role <> sMasterRoleName then Continue;

        if vRoleItem.receiptRole = '' then
        begin
          AddLogMsg('设置对方加色完成MasterRole[%s]RecvRole[%s]', [sMasterRoleName, sRoleName], True);
          vRoleItem.receiptRole := sRoleName;
        end;

        Result := True;
        Exit;
      end;
    end;
  finally
    //--通知子号， 修改完成了
    ConsoleSvr.RetCmdOk(AConnID);
    FreeAndNil(vLst);
    LeaveCriticalSection(FCS);
  end;
end;

function TTaskManager.ClearRecvRoleName(ACmd: string; AConnID: DWORD): Boolean;
var
  vLst: TStrings;
  sGroupName, sOrderNo, sRoleName: string;
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
  vIsMain: Boolean;
  vRoleItem: TRoleItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  vLst := TStringList.Create;
  try
    vLst.Delimiter := ',';
    vLst.DelimitedText := ACmd;
    if vLst.Count = 0 then Exit;
    sGroupName := vLst.Values['GroupName'];
    sOrderNo := vLst.Values['OrderNo'];
    sRoleName := vLst.Values['RoleName'];

    if sOrderNo = '' then Exit;
    if sRoleName = '' then Exit;
    if FItems.Count = 0 then Exit;
    for vOrderItem in FItems.Values do
    begin
      if vOrderItem.orderNo = '' then Continue;
      if vOrderItem.orderNo <> sOrderNo then Continue;
      for vRoleItem in vOrderItem.roles do
      begin
        //if not vRoleItem.isMain then Continue;
        if vRoleItem.role <> sRoleName then Continue;
        vRoleItem.receiptRole := '';
        Result := True;
        Exit;
      end;
    end;
  finally
    //--通知子号， 修改完成了
    ConsoleSvr.RetCmdOk(AConnID);
    FreeAndNil(vLst);
    LeaveCriticalSection(FCS);
  end;
end;

{ TConnItem }

constructor TConnItem.Create;
begin
  FConnID := 0;
  FGroupName := '';
  FOrderItem := nil;
  FState := sms空闲;
  FInterval := 0;
  Suspend := False;
  FLogMsgs := TStringList.Create;
end;

destructor TConnItem.Destroy;
begin
  FreeAndNil(FLogMsgs);
  inherited;
end;

{ TConnManager }
constructor TConnManager.Create;
begin
  InitializeCriticalSection(FCS);
  FItems := TObjectDictionary<string,TConnItem>.Create([doOwnsValues]);
end;

destructor TConnManager.Destroy;
begin
  FItems.Free;
  DeleteCriticalSection(FCS);
  inherited;
end;

procedure TConnManager.Add(AConnItem: TConnItem);
begin
  SetItem(AConnItem.GroupName, AConnItem);
end;

procedure TConnManager.Del(AKey: string);
var
  sKey: string;
begin
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AKey) then Exit;
    FItems.Remove(AKey);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetConnOrderInfo(AGroupName: string): string;
var
  vConnitem: TConnItem;
begin
  EnterCriticalSection(FCS);
  try
    vConnItem := ConnManager.Items[AGroupName];
    if vConnItem = nil then Exit;
    if vConnItem.OrderItem = nil then Exit;
    Result := TSerizalizes.AsJSON<TOrderItem>(vConnItem.OrderItem);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetConnItem(AOrderNo: string; ARoleName: string): TConnItem;
var
  sKey: string;
  vConnItem: TConnItem;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      vOrderItem := vConnItem.OrderItem;
      if vOrderItem = nil then Continue;
      if vOrderItem.orderNo <> AOrderNo then Continue;
      for vRoleItem in vOrderItem.roles do
      begin
        if vRoleItem.role <> ARoleName then Continue;
        Result := vConnItem;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetCount: Integer;
begin
  EnterCriticalSection(FCS);
  try
    Result := FItems.Count;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetFreeCount: Integer;
var
  sKey: string;
  vConnItem: TConnItem;
begin
  Result := 0;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State = sms空闲 then
      begin
        Result := Result + 1;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetFreeMachine: TConnItem;
var
  sKey: string;
  vConnItem: TConnItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State = sms空闲 then
      begin
        Result := vConnItem;
        Break;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetGroupName(AConnID: DWORD): string;
var
  vConnItem: TConnItem;
begin
  Result := '';
  EnterCriticalSection(FCS);
  try
    if FItems.Count = 0 then Exit;
    for vConnItem in FItems.Values do
    begin
      if AConnID = vConnItem.ConnID then
      begin
        Result := vConnItem.GroupName;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetMasterConnItem(AConnItem: TConnItem): TConnItem;
var
  vConnItem: TConnItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    if FItems.Count = 0 then Exit;
    if AConnItem = nil then Exit;
    if AConnItem.OrderItem = nil then Exit;
    for vConnItem in FItems.Values do
    begin
      if vConnItem.OrderItem = nil then Continue;
      if (vConnItem.OrderItem.orderNo = AConnItem.OrderItem.orderNo) and (vConnItem.OrderItem.roles[0].isMain) then
      begin
        Result := vConnItem;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetMasterConnItem(AOrderNo: string): TConnItem;
var
  vConnItem: TConnItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    if FItems.Count = 0 then Exit;
    if AOrderNo = '' then Exit;
    for vConnItem in FItems.Values do
    begin
      if vConnItem.OrderItem = nil then Continue;
      if (vConnItem.OrderItem.orderNo = AOrderNo) and (vConnItem.OrderItem.roles[0].isMain) then
      begin
        Result := vConnItem;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetTargerConnItem(ATargetRoleName:string; AOrderNo:string): TConnItem;
var
  vConnItem: TConnItem;
  vRoleItem: TRoleItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    AddLogMsg('RoleName:%s AOrderNo:%s', [ATargetRoleName, AOrderNo], True);
    if FItems.Count = 0 then Exit;
    if ATargetRoleName = '' then Exit;
    if AOrderNo = '' then Exit;
    for vConnItem in FItems.Values do
    begin
      if vConnItem.OrderItem = nil then Continue;
      if vConnItem.OrderItem.orderNo <> AOrderNo then Continue;
      for vRoleItem in vConnItem.OrderItem.roles do
      begin
        if (vRoleItem.role = ATargetRoleName) then
        begin
          AddLogMsg('已找到的对方连接[%s]', [vConnItem.GroupName], True);
          Result := vConnItem;
          Exit;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.GetItem(AKey: string): TConnItem;
begin
  Result := nil;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AKey) then Exit;
    Result := FItems.Items[AKey];
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TConnManager.SetItem(AKey: string; const Value: TConnItem);
begin
  EnterCriticalSection(FCS);
  try
    FItems.AddOrSetValue(AKey, Value);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ReSetRoleStep(AConnID: DWORD; AGroupName: string; ARoleName: string; ATargetRoleName: string; ARoleStep: TRoleStep): Boolean;
var
  vConnItem, vTargetConnItem: TConnItem;
  vRoleItem, vTargetRoleItem: TRoleItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    vConnItem := FItems[AGroupName];
    if vConnItem = nil then
    begin
      //--没有找到对应的连接
      AddLogMsg('没有找到发货机[%s]', [AGroupName], True);
      Exit;
    end;

    for vTargetConnItem in FItems.Values do
    begin
      if vTargetConnItem.State <> sms繁忙 then Continue;
      if vTargetConnItem.OrderItem = nil then Continue;
      for vRoleItem in vConnItem.OrderItem.roles do
      begin
        if vRoleItem.role <> ARoleName then Continue;

        for vTargetRoleItem in vTargetConnItem.OrderItem.roles do
        begin
          if vTargetRoleItem.role <> ATargetRoleName then Continue;
          vTargetConnItem.RoleStep := ARoleStep;
          vConnItem.RoleStep := ARoleStep;
          ConsoleSvr.RetCmdOk(AConnID);
          Result := True;
          AddLogMsg('重置步骤成功[%d]', [Integer(ARoleStep)], True);
          Exit;
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.RetRoleStep(AConnID: DWORD; AGroupName: string): Boolean;
var
  vConnItem, vTargetConnItem: TConnItem;
  vRoleItem, vTargetRoleItem: TRoleItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    vConnItem := FItems[AGroupName];
    if vConnItem = nil then
    begin
      ConsoleSvr.RetRoleStep(AConnID, rsNormal);
      Exit;
    end;
    ConsoleSvr.RetRoleStep(AConnID, vConnItem.RoleStep);
    Result := True;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.RetTargetRoleStep(AConnID: DWORD; AGroupName: string; ARoleName: string; ATargetRoleName: string): Boolean;
var
  vConnItem, vTargetConnItem: TConnItem;
  vRoleItem, vTargetRoleItem: TRoleItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    AddLogMsg('GroupName:%s RoleName:%s TargetRoleName:%s', [AGroupName, ARoleName, ATargetRoleName]);
    vConnItem := FItems[AGroupName];
    if vConnItem = nil then
    begin
      ConsoleSvr.RetRoleStep(AConnID, rsNormal);
      Exit;
    end;

    if ATargetRoleName = '' then
    begin
      ConsoleSvr.RetRoleStep(AConnID, rsNormal);
      Exit;
    end;

    for vRoleItem in vConnItem.OrderItem.roles do
    begin
      if vRoleItem.role <> ARoleName then Continue;
      //if vRoleItem.receiptRole <> ATargetRoleName then Continue;
      vTargetConnItem := GetTargerConnItem(vRoleItem.receiptRole, vConnItem.OrderItem.orderNo);
      if (vTargetConnItem = nil) or (vTargetConnItem.OrderItem = nil) then
      begin
        AddLogMsg('1--GroupName:%s RoleName:%s TargetRoleName:%s', [AGroupName, ARoleName, ATargetRoleName]);
        ConsoleSvr.RetRoleStep(AConnID, rs对方任务失败);

        if vRoleItem.isMain then vRoleItem.receiptRole := '';
        Exit;
      end;

      for vTargetRoleItem in vTargetConnItem.OrderItem.roles do
      begin
        if (vTargetRoleItem.role = ATargetRoleName) and (vTargetRoleItem.receiptRole = ARoleName) then
        begin
          ConsoleSvr.RetRoleStep(AConnID, vTargetConnItem.RoleStep);
          Result := True;
          Exit;
        end;

        if (vTargetRoleItem.role = ATargetRoleName) then
        begin
          ConsoleSvr.RetRoleStep(AConnID, rsNormal);
          Result := True;
          Exit;
        end;
      end;
    end;

  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.RetRecvRoleName(AConnId: DWORD; AGroupName: string; AMasterRoleName: string): Boolean;
var
  vConnItem: TConnItem;
  vRoleItem: TRoleItem;
  sRecRoleName: string;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    sRecRoleName := '___Error___';
    if not FItems.ContainsKey(AGroupName) then
    begin
      ConsoleSvr.RetRecvRoleName(AConnID, sRecRoleName);
      Exit;
    end;
    vConnItem := FItems[AGroupName];
    if vConnItem = nil then
    begin
      ConsoleSvr.RetRoleStep(AConnID, rsNormal);
      Exit;
    end;

    if vConnItem.State <> sms繁忙 then
    begin
      ConsoleSvr.RetRecvRoleName(AConnID, sRecRoleName);
      Exit;
    end;

    if vConnItem.OrderItem = nil then
    begin
      ConsoleSvr.RetRecvRoleName(AConnID, sRecRoleName);
      Exit;
    end;

    for vRoleItem in vConnItem.OrderItem.roles do
    begin
      if not vRoleItem.isMain then Continue;
      if vRoleItem.role = AMasterRoleName then
      begin
        sRecRoleName := vRoleItem.receiptRole;
        Break;
      end;
    end;
    ConsoleSvr.RetRecvRoleName(AConnID, sRecRoleName);
    Result := True;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.SuspendTask(AGroupName: string): Boolean;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    if FItems[AGroupName].State <> sms繁忙 then Exit;
    Result := ConsoleSvr.SuspendTask(FItems[AGroupName].ConnID, AGroupName);
    FItems[AGroupName].Suspend := True;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ReStartTask(AGroupName: string): Boolean;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    if FItems[AGroupName].State <> sms繁忙 then Exit;
    Result := ConsoleSvr.ResumeTask(FItems[AGroupName].ConnID, AGroupName);
    FItems[AGroupName].Suspend := False;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.StopTask(AGroupName: string): Boolean;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    if FItems[AGroupName].State <> sms繁忙 then Exit;
    Result := ConsoleSvr.StopTask(FItems[AGroupName].ConnID, AGroupName);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.SuspendAllTask: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State <> sms繁忙 then Continue;
      Result := ConsoleSvr.SuspendTask(vConnItem.ConnID, vConnItem.GroupName);
      vConnItem.Suspend := True;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ReStartAllTask: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      Result := ConsoleSvr.ResumeTask(vConnItem.ConnID, vConnItem.GroupName);
      vConnItem.Suspend := False;
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.StopAllTask(AOrderNo: string): Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State <> sms繁忙 then Continue;
      if vConnItem.OrderItem = nil then Continue;
      if vConnItem.OrderItem.orderNo <> AOrderNo then Continue;
      Result := ConsoleSvr.StopTask(vConnItem.ConnID, vConnItem.GroupName);
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ClearLog(AGroupName: string): Boolean;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    if not FItems.ContainsKey(AGroupName) then Exit;
    FItems[AGroupName].LogMsgs.Clear;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ClearAllLog: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
      vConnItem.LogMsgs.Clear;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.LogoutAll: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State = sms繁忙 then Continue;
      Result := ConsoleSvr.LogOff(vConnItem.ConnID, vConnItem.GroupName);
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ReBootAll: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State = sms繁忙 then Continue;
      Result := ConsoleSvr.ReBoot(vConnItem.ConnID, vConnItem.GroupName);
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

function TConnManager.ShutdownAll: Boolean;
var
  vConnItem: TConnItem;
begin
  Result := False;
  EnterCriticalSection(FCS);
  try
    for vConnItem in FItems.Values do
    begin
      if vConnItem.State = sms繁忙 then Continue;
      Result := ConsoleSvr.Shutdown(vConnItem.ConnID, vConnItem.GroupName);
    end;
  finally
    LeaveCriticalSection(FCS);
  end;
end;

initialization
  TaskManager := TTaskManager.Create();
  ConnManager := TConnManager.Create();
finalization
  TaskManager.Free;
  ConnManager.Free;
end.
