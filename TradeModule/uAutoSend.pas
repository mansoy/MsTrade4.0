unit uAutoSend;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils,
  VerySimple.Lua.Lib,
  VerySimple.Lua,
  uOrderInfo,
  uLuaFuns,
  uJsonClass,
  uGlobal;

type
  TMsLua = class(TVerySimpleLua)
  private
    OrderInfo: TOrderInfo;
    GlobalFuns: TLuaFuns;
  public
    constructor Create; override;
    destructor Destroy; override;
    //---加载Lua文件
    function GetLuaScript(ATaskType: TTaskType = tt发货): string;
    procedure Open; override;
  end;

  TAutoSend = class(TThread)
  private
    FUseTimes: Integer;
    sCapturesFilePath: string;
    FOrderItem: TOrderItem;
    procedure OnPrint(Msg: String);
    function ExecLua(): Boolean;

    function InitRoleImgs: Boolean;
    function UnInitRoleImgs: Boolean;
    function EndTask(): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOrderItem: TOrderItem);
    destructor Destroy; override;
    property OrderItem: TOrderItem read FOrderItem write FOrderItem;
  end;

  //function GetLuaString(AType: Integer): PWideChar; stdcall; external 'MsRes.dll' name 'GetLuaString';

implementation

{$R SendMail.res}

uses
  uTradeClient,
  uCommand,
  uCommFuns;

{ TAutoSend }

constructor TAutoSend.Create(AOrderItem: TOrderItem);
begin
  //--启动发货机
  GSharedInfo.bWork := True;
  GSharedInfo.bReStart := True;
  GSharedInfo.bSuspendTask := False;
  GSharedInfo.bStopTask := False;
  FreeOnTerminate := True;
  FOrderItem := AOrderItem;
  inherited Create(False);
end;

destructor TAutoSend.Destroy;
begin
  FreeAndNil(GSharedInfo.OrderItem);
  GSharedInfo.bReStart := True;
  GSharedInfo.RoleIndex := 0;
  GSharedInfo.bSuspendTask := False;
  GSharedInfo.bStopTask := False;
  GSharedInfo.bWork := False;
  //AddLogMsg('AutoSend finshed', []);
end;

function TAutoSend.EndTask: Boolean;
begin
  GSharedInfo.bCmdOk := False;
  while True do
  begin
    TradeClient.EndTask(GSharedInfo.ClientSet.GroupName, GSharedInfo.OrderItem.key);
    Sleep(200);
    if GSharedInfo.bCmdOk then Break;
  end;
end;

function TAutoSend.ExecLua(): Boolean;
var
  MsLua: TMsLua;
  I: Integer;
  sFileName, sCapturePath, sLua: string;
begin
  //--发货的逻辑在这里实现
  try
    for I := 0 to GConsoleSet.TaskTimes - 1 do
    try
      FUseTimes := I + 1;
      MsLua := TMsLua.Create;
      try
        MsLua.OnPrint := OnPrint;
        AddLogMsg('启动脚本...', [], True);
        {$IFDEF _MS_DEBUG}
        MsLua.DoFile(GSharedInfo.AppPath + 'Script\SendMail.lua');
        {$ELSE}
        MsLua.DoString(MsLua.GetLuaScript(tt发货));
        {$ENDIF}
        //--如果发货成功，则不需要启动
        if GSharedInfo.TaskStatus = tsSuccess then Break;

        if GSharedInfo.TaskStatus in [tsFail, tsTargetFail] then
        begin
          //--失败的时候截一张图
          if GSharedInfo.OrderItem.taskType = 1 then
          begin
            sFileName := Format('%s%s_%d_Error.bmp', [MsLua.OrderInfo.CapturePath, GSharedInfo.OrderItem.key, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].roleID]);
          end else
          begin
            sFileName := Format('%s%s_%d_Error.bmp', [MsLua.OrderInfo.CapturePath, GSharedInfo.OrderItem.orderNo, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].roleID]);
          end;
          GCommFuns.fn截取屏幕(sFileName);
        end;

        if GSharedInfo.TaskStatus in [tsFail, tsTargetFail, tsKillTask] then
        begin
          {$IFNDEF DEBUG}
          GCommFuns.CloseGame(GCommFuns.GetDealy('完成后关闭游戏等待'));
          {$ENDIF}
        end;
        if not GSharedInfo.bReStart then Break;
      finally
        sCapturePath := MsLua.OrderInfo.CapturePath;
        FreeAndNil(MsLua);
      end;
    except on E: Exception do
      AddLogMsg('执行脚本时发生错误:%s', [E.Message]);
    end;
  finally
    GCommFuns.PostCapture(sCapturePath);
  end;

end;

procedure TAutoSend.Execute;
var
  I, iCloseGameCalc: Integer;
  sRoleBmp, sReceiptRoleBmp: string;
  bIsMain: Boolean;
begin
  GSharedInfo.OrderItem := FOrderItem;
  if GSharedInfo.OrderItem = nil then Exit;
  //AddLogMsg('开始任务[%s]...', [GSharedInfo.OrderItem.roles[I].role]);
  GCommFuns.WriteGameRegionSvr(GSharedInfo.ClientSet.GamePath, GSharedInfo.OrderItem.gameSvr, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].account);
  {$IFNDEF DEBUG}
  GCommFuns.CloseGame(GCommFuns.GetDealy('完成后关闭游戏等待'));
  {$ENDIF}
  try
    iCloseGameCalc := 1;
    PostLogFile('======OrderNo:%s=======================================================', [GSharedInfo.OrderItem.orderNo]);
    for I := Low(GSharedInfo.OrderItem.roles) to High(GSharedInfo.OrderItem.roles) do
    try
      AddLogMsg('角色[%s]开始任务...', [GSharedInfo.OrderItem.roles[I].role]);
      GSharedInfo.OrderItem.roles[I].taskState := Integer(tsDoing);
      uCommand.PostState(GSharedInfo.OrderItem, GSharedInfo.RoleIndex, GSharedInfo.ClientSet.GroupName, GConsoleSet.StateInterface);
      TradeClient.SendStatus(GSharedInfo.OrderItem, GSharedInfo.RoleIndex, GSharedInfo.ClientSet.GroupName);
      GSharedInfo.RoleIndex := I;
      InitRoleImgs;
      try
      	GSharedInfo.bReStart := True;
        ExecLua();
        //--提交当前角色的状态
        uCommand.PostState(GSharedInfo.OrderItem, GSharedInfo.RoleIndex, GSharedInfo.ClientSet.GroupName, GConsoleSet.StateInterface);
        TradeClient.SendStatus(GSharedInfo.OrderItem, GSharedInfo.RoleIndex, GSharedInfo.ClientSet.GroupName);
      finally
        UnInitRoleImgs;
      end;
      //--判断，上一个角色， 发货启动了几次脚本（启动第二次时， 说明重新打开过游戏客户端）
      if (FUseTimes <= 1) then
      begin
        Inc(iCloseGameCalc);
      end;
      //--如果连续两次都没有重启过游戏客户端， 则重启一下游戏客户端
      //--前提是，不是最后一次角色， 要不然， 要执行两次CloseGame函数， 浪费时间
      if (iCloseGameCalc > 2) and (I < High(GSharedInfo.OrderItem.roles)) then
      begin
        AddLogMsg('完成了两个角色，后重启游戏', [], True);
        iCloseGameCalc := 1;
        //GCommFuns.CloseGame(GCommFuns.GetDealy('完成后关闭游戏等待'));
      end;
    except
      AddLogMsg('执行脚本异常...', [], True);
    end;
    if GSharedInfo.ClientSet.UseVpn then GCommFuns.VpnConnect(GSharedInfo.ClientSet.VpnServerName, GSharedInfo.ClientSet.VpnUserName, GSharedInfo.ClientSet.VpnPassword);

  finally
    EndTask();
    {$IFNDEF DEBUG}
    GCommFuns.CloseGame(GCommFuns.GetDealy('完成后关闭游戏等待'));
    {$ENDIF}
  end;
end;

function TAutoSend.InitRoleImgs: Boolean;
var
  sRoleBmp, sRoleName: string;
  vRoleItem: TRoleItem;
begin
  Result := False;
  try
    vRoleItem := GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex];
    if vRoleItem = nil then Exit;
    sRoleBmp :=  Format('%sBmp(W7)\%d.bmp', [GSharedInfo.AppPath, vRoleItem.roleID]);
    //MessageBox(0, PWideChar(sRoleBmp), 0, 0);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      if not DeleteFile(sRoleBmp) then
      Sleep(200);
    end;
    //GCommFuns.CreateRoleBmp(vRoleItem.role, sRoleBmp);
    GCommFuns.CreateBmp(vRoleItem.role, 209, 185, 148, sRoleBmp);
    //-----------------------------------------------------
    sRoleBmp :=  Format('%sBmp(W7)\%d.bmp', [GSharedInfo.AppPath, vRoleItem.rowId]);
    //MessageBox(0, PWideChar(sRoleBmp), 0, 0);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      DeleteFile(sRoleBmp);
      Sleep(200);
    end;
    GCommFuns.CreateBmp(vRoleItem.receiptRole, $FF, $FF, $FF, sRoleBmp);

    sRoleBmp :=  Format('%sBmp(W7)\RecGameSvr_1.bmp', [GSharedInfo.AppPath]);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      DeleteFile(sRoleBmp);
      Sleep(200);
    end;
    GCommFuns.CreateBmp(vRoleItem.receiptGameSvr, $DD, $C5, $93, sRoleBmp);
    sRoleBmp :=  Format('%sBmp(W7)\RecGameSvr_2.bmp', [GSharedInfo.AppPath]);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      DeleteFile(sRoleBmp);
      Sleep(200);
    end;
    GCommFuns.CreateBmp(vRoleItem.receiptGameSvr, $E6, $E6, $E6, sRoleBmp);
    //GCommFuns.FreePic(sRoleBmp);
  except on E: Exception do
    AddLogMsg('InitRoleImgs fail ErrCode[%d] [%s] ', [GetLastError, E.Message]);
  end;
end;

procedure TAutoSend.OnPrint(Msg: String);
begin
  AddLogMsg(Msg, [], True);
end;

function TAutoSend.UnInitRoleImgs: Boolean;
var
  sRoleBmp, sRoleName: string;
  vRoleItem: TRoleItem;
begin
  Result := False;
  try
    vRoleItem := GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex];
    if vRoleItem = nil then Exit;
    sRoleBmp :=  Format('%sBmp(W7)\%d.bmp', [GSharedInfo.AppPath, vRoleItem.roleID]);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      DeleteFile(sRoleBmp);
    end;
    //-----------------------------------------------------
    sRoleBmp :=  Format('%sBmp(W7)\%d.bmp', [GSharedInfo.AppPath, vRoleItem.rowId]);
    if FileExists(sRoleBmp) then
    begin
      GCommFuns.FreePic(sRoleBmp);
      DeleteFile(sRoleBmp);
    end;
  except

  end;
end;

{ TMyLua }

constructor TMsLua.Create;
var
  sPath: string;
begin
  inherited;
  LibraryPath := GSharedInfo.AppPath + LUA_LIBRARY;
  AddLogMsg(LibraryPath, [], True);
  OrderInfo := TOrderInfo.Create;
  GlobalFuns := TLuaFuns.Create;

  sPath := GSharedInfo.ClientSet.Capture;
  if not DirectoryExists(sPath) then
  begin
    if not ForceDirectories(sPath) then
    begin
      sPath := GSharedInfo.AppPath + 'Capture';
      ForceDirectories(sPath);
    end;
  end;
  sPath := Format('%s\%s\%d\',
    [
      sPath,
      GSharedInfo.OrderItem.orderNo,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].roleID
    ]);
  OrderInfo.CapturePath := sPath;
end;

destructor TMsLua.Destroy;
begin
  FreeAndNil(OrderInfo);
  FreeAndNil(GlobalFuns);
  inherited;
end;

function TMsLua.GetLuaScript(ATaskType: TTaskType): string;
var
  MyList: TStrings;
  Res   : TResourceStream;
  ResName: string;
begin
  Result := '';
  try
    try
      case ATaskType of
        tt发货: ResName := 'SENDMAIL';
      end;
      MyList := TStringList.Create;
      Res    := TResourceStream.Create(HInstance, ResName, 'TEXT');
      MyList.LoadFromStream(Res);
      Result := MyList.Text;
    except
    end;
  finally
    FreeAndNil(MyList);
    FreeAndNil(Res);
  end;
end;

procedure TMsLua.Open;
begin
  try
    inherited;
    OrderInfo.PackageReg(LuaState);
    GlobalFuns.PackageReg(LuaState);
  except on E: Exception do
    AddLogMsg('TMsLua.Open fail[%s]..', [E.Message]);
  end;
end;

end.
