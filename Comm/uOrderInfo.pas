unit uOrderInfo;

interface

{$M+}
uses
  VerySimple.Lua, VerySimple.Lua.Lib,
  uGlobal,
  uTradeClient
  ;

type
  TOrderInfo = class(TObject)
  public
    CapturePath: string;
    function LoadPackage(L: lua_State): Integer;
    procedure PackageReg(L: lua_State);
  published
    function GetRoleImgName(L: lua_State): Integer;
    function GetReceiptRoleImgName(L: lua_State): Integer;
    function GetCapturePath(L: lua_State): Integer;
    //-------------------------------------------------------------
    function GetOrderNo(L: lua_State): Integer;
    function GetTaskType(L: lua_State): Integer;
    function GetAreaName(L: lua_State): Integer;
    function GetAccount(L: lua_State): Integer;
    function GetPassWord(L: lua_State): Integer;

    function GetReceiptRole(L: lua_State): Integer;
    function GetReceiptGameSvr(L: lua_State): Integer;
    function GetReceiptLevel(L: lua_State): Integer;
    function GetCheckLevel(L: lua_State): Integer;
    function GetSaleNum(L: lua_State): Integer;
    function GetSafetyWay(L: lua_State): Integer;
    //----------------------------------------------
    function GetIsMain(L: lua_State): Integer;
    function GetRowID(L: lua_State): Integer;
    function GetRoleID(L: lua_State): Integer;
    function GetRole(L: lua_State): Integer;
    function GetSendNum(L: lua_State): Integer;
    function GetEachNum(L: lua_State): Integer;
    function GetStock(L: lua_State): Integer;
    function SetReStock(L: lua_State): Integer;
    function SetRoleStep(L: lua_State): Integer;
    function ClearRecvRoleName(L: lua_State): Integer;

    //---启动信息
    function GetStockFloat(L: lua_State): Integer;
    function GetTaskStop(L: lua_State): Integer;
  end;

implementation

{ TMyPackage }

uses
  System.SysUtils,
  ManSoy.Encode
  ;

function TOrderInfo.GetRoleImgName(L: lua_State): Integer;
var
  sImgName: string;
begin
  sImgName := Format('%d.bmp', [GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].roleID]);
  Lua_PushString(L, PAnsiChar(AnsiString(sImgName)));
  Result := 1;
end;

function TOrderInfo.GetReceiptRoleImgName(L: lua_State): Integer;
var
  sImgName: string;
begin
  sImgName := Format('%d.bmp', [GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].rowId]);
  Lua_PushString(L, PAnsiChar(AnsiString(sImgName)));
  Result := 1;
end;

function TOrderInfo.GetCapturePath(L: lua_State): Integer;
begin
  Result := 1;
  Lua_PushString(L, PAnsiChar(AnsiString(CapturePath)));
end;
//---------------------------------------------------------------
function TOrderInfo.GetOrderNo(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.orderNo)));
  Result := 1;
end;

function TOrderInfo.GetAreaName(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.gameSvr)));
  Result := 1;
end;

function TOrderInfo.GetSaleNum(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.saleNum);
  Result := 1;
end;

function TOrderInfo.GetTaskType(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.taskType);
  Result := 1;
end;

{$REGION '角色信息'}
function TOrderInfo.GetAccount(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].Account)));
  Result := 1;
end;

function TOrderInfo.GetIsMain(L: lua_State): Integer;
var
  iTmp: Integer;
begin
  iTmp := 0;
  if GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].IsMain then iTmp := 1;
  Lua_PushInteger(L, iTmp);
  Result := 1;
end;

function TOrderInfo.GetRowID(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].RowID);
  Result := 1;
end;

function TOrderInfo.GetPassWord(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(ManSoy.Encode.Base64ToStr(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].passWord))));
  //Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].passWord)));
  Result := 1;
end;

function TOrderInfo.GetRoleID(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].RoleID);
  Result := 1;
end;

function TOrderInfo.GetRole(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].Role)));
  Result := 1;
end;

function TOrderInfo.GetReceiptLevel(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptLevel);
  Result := 1;
end;

function TOrderInfo.GetReceiptRole(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptRole)));
  Result := 1;
end;

function TOrderInfo.GetReceiptGameSvr(L: lua_State): Integer;
begin
  Lua_PushString(L, PAnsiChar(AnsiString(GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptGameSvr)));
  Result := 1;
end;

function TOrderInfo.GetCheckLevel(L: lua_State): Integer;
var
  iCheckLevel: Integer;
begin
  iCheckLevel := 0;
  if GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].CheckLevel then iCheckLevel := 1;
  Lua_PushInteger(L, iCheckLevel);
  Result := 1;
end;

function TOrderInfo.GetSafetyWay(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].safetyWay);
  Result := 1;
end;

function TOrderInfo.GetSendNum(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].SendNum);
  Result := 1;
end;

function TOrderInfo.GetEachNum(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].EachNum);
  Result := 1;
end;

function TOrderInfo.GetStock(L: lua_State): Integer;
begin
  Lua_PushInteger(L, GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].stock);
  Result := 1;
end;

function TOrderInfo.SetReStock(L: lua_State): Integer;
var
  ArgCount: Integer;
  iReStock: Integer;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    iReStock := lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then Exit;
    GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].ReStock := iReStock;
  except
  end;
end;

function TOrderInfo.SetRoleStep(L: lua_State): Integer;
var
  ArgCount: Integer;
  iReStock: Integer;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    iReStock := lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then Exit;
    GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].ReStock := iReStock;
  except
  end;
end;

function TOrderInfo.ClearRecvRoleName(L: lua_State): Integer;
var
  ArgCount: Integer;
  iReStock: Integer;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    iReStock := lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then Exit;
    GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptRole := '';
  except
  end;
end;
{$ENDREGION}

function TOrderInfo.GetStockFloat(L: lua_State): Integer;
begin
  if GConsoleSet = nil then
    Lua_PushInteger(L, 0)
  else
    Lua_PushInteger(L, GConsoleSet.StockFloating);
  Result := 1;
end;

function TOrderInfo.GetTaskStop(L: lua_State): Integer;
begin
  if GSharedInfo.bStopTask then
    Lua_PushInteger(L, 1)
  else
    Lua_PushInteger(L, 0);
  Result := 1;
end;

function TOrderInfo.LoadPackage(L: lua_State): Integer;
begin
  lua_newtable(L);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetRoleImgName'), 'GetRoleImgName');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetReceiptRoleImgName'), 'GetReceiptRoleImgName');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetReceiptGameSvr'), 'GetReceiptGameSvr');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetCapturePath'), 'GetCapturePath');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetOrderNo'), 'GetOrderNo');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetTaskType'), 'GetTaskType');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetRowID'), 'GetRowID');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetActionType'), 'GetActionType');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetAreaName'), 'GetAreaName');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetAccount'), 'GetAccount');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetPassWord'), 'GetPassWord');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetReceiptLevel'), 'GetReceiptLevel');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetCheckLevel'), 'GetCheckLevel');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetReceiptRole'), 'GetReceiptRole');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetSaleNum'), 'GetSaleNum');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetSafeftWay'), 'GetSafeftWay');
  lua_rawset(L, -3);

  //--------------------------------------------------------------------------------

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetIsMain'), 'GetIsMain');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetRowID'), 'GetRowID');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetRole'), 'GetRole');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetRoleID'), 'GetRoleID');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetSendNum'), 'GetSendNum');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetEachNum'), 'GetEachNum');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetStock'), 'GetStock');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('SetReStock'), 'SetReStock');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetStockFloat'), 'GetStockFloat');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('GetTaskStop'), 'GetTaskStop');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('ClearRecvRoleName'), 'ClearRecvRoleName');
  lua_rawset(L, -3);

  Result := 1;
end;

procedure TOrderInfo.PackageReg(L: lua_State);
begin
  // Register Lua package 'MyPackage' with the TMyPackage package loader procedure
  TVerySimpleLua.RegisterPackage(L, 'TOrderInfo', Self, 'LoadPackage');
end;

end.

