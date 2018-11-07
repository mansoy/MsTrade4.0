unit uLuaFuns;

interface

uses
  Winapi.Windows, System.SysUtils, VerySimple.Lua, VerySimple.Lua.Lib;

type
  TLuaFuns = class
  private
  public
    function LoadPackage(L: lua_State): Integer;
    procedure PackageReg(L: lua_State);
  published

  {$REGION 'Windows API'}
    /// <summary>
    /// 暂停函数
    /// </summary>
    /// <param name="L">暂停的毫秒数</param>
    /// <returns></returns>
    function MsSleep(L: lua_State): Integer;
    function MsFindWindow(L: lua_State): Integer;
    function MsFindWindowEx(L: lua_State): Integer;
    function MsIsWindow(L: lua_State): Integer;
    function MsGetTickCount(L: lua_State): Integer;
    function MsGetClientRect(L: lua_State): Integer;
    function MsSendMessage(L: lua_State): Integer;
  {$ENDREGION}

  {$REGION '封装功能'}
    //--前置窗口
    function MsFrontWindow(L: lua_State): Integer;
    /// <summary>
    /// 输出调试信息
    /// </summary>
    /// <param name="L">调试信息文本</param>
    /// <returns></returns>
    function MsDebugInfo(L: lua_State): Integer;

    function MsStartGame(L: lua_State): Integer;

    function MsPressPassWord(L: lua_State): Integer;

    function MsCheck(L: lua_State): Integer;

    function MsCloseGame(L: lua_State): Integer;

    function MsGetTopLeft(L: lua_State): Integer;

    function MsDaMa(L: lua_State): Integer;

    function MsQuitSafe(L: lua_State): Integer;

    function MsGetCarryAmount(L: lua_State): Integer;

    function MsCreateBmp(L: lua_State): Integer;

    function MsSetGameCfg(L: lua_State): Integer;

    function MsGetPwd(L: lua_State): Integer;
  {$ENDREGION}

  {$REGION '大漠'}
    function MsClick(L: lua_State): Integer;
    function MsDbClick(L: lua_State): Integer;
    function MsRightClick(L: lua_State): Integer;
    function MsDragMouse(L: lua_State): Integer;

    function MsFindImg(L: lua_State): Integer;
    function MsFindImgEx(L: lua_State): Integer;
    function MsAreaFindImg(L: lua_State): Integer;
    function MsAreaFindImgEx(L: lua_State): Integer;

    function MsAreaFindString(L: lua_State): Integer;
    function MsFindString(L: lua_State): Integer;
    function MsFindStringEx(L: lua_State): Integer;

    /// <summary>
    /// 获取数量
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsGetNumber(L: lua_State): Integer;

    /// <summary>
    /// 连续按下删除按键
    /// </summary>
    /// <param name="L">按下多少次</param>
    /// <returns></returns>
    function MsPressDel(L: lua_State): Integer;

    /// <summary>
    /// 按下回车键
    /// </summary>
    /// <returns></returns>
    function MsPressEnter(L: lua_State): Integer;

    /// <summary>
    /// 按下返回键
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsPressEsc(L: lua_State): Integer;

    /// <summary>
    /// 截取游戏窗口
    /// </summary>
    function MsCaptureGame(L: lua_State): Integer;

    /// <summary>
    /// 区域截图
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsCaptureArea(L: lua_State): Integer;

    /// <summary>
    /// 移动窗口
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsMoveWindow(L: lua_State): Integer;

    /// <summary>
    /// 按键
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsPressKey(L: lua_State): Integer;

    /// <remarks>
    /// 按下方向键走路
    /// </remarks>
    function MsTheKeysWalk(L: lua_State): Integer;

    /// <summary>
    ///
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsPressChar(L: lua_State): Integer;

    /// <summary>
    /// 向下滑动鼠标
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsWheelDown(L: lua_State): Integer;

    /// <summary>
    /// 鼠標移動到
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsMoveTo(L: lua_State): Integer;
    /// <summary>
    /// 输入字符串
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsPressString(L: lua_State): Integer;

    /// <summary>
    /// 屏幕取字
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsOcr(L: lua_State): Integer;

    /// <summary>
    /// 屏幕取字
    /// </summary>
    /// <param name="L"></param>
    /// <returns></returns>
    function MsOcrEx(L: lua_State): Integer;
  {$ENDREGION}

  {$REGION '公共变量'}
    function MsGetGameHandle(L: lua_State): Integer;
    function MsSetGameHandle(L: lua_State): Integer;
  {$ENDREGION}

  {$REGION '公共参数'}
    function MsGetDelay(L: lua_State): Integer;
    function MsGetPianSe(L: lua_State): Integer;
  {$ENDREGION}

  {$REGION '通讯'}
  function MsPostStatus(L: lua_State): Integer;
  /// <remarks>
  /// 告诉控制台自己执行到哪一步了
  /// </remarks>
  function MsSetRoleStep(L: lua_State): Integer;
  function MsResetRoleStep(L: lua_State): Integer;
  function MsGetRoleStep(L: lua_State): Integer;
//  function MsSetTargetRoleStep(L: lua_State): Integer;
  function MsGetTargetRoleStep(L: lua_State): Integer;
  function MsSetMasterRecRoleName(L: lua_State): Integer;
  function MsClearRecvRoleName(L: lua_State): Integer;
  function MsGetMasterRecRoleName(L: lua_State): Integer;
  {$ENDREGION}
  end;

implementation

uses uCommFuns, uTradeClient, uGlobal, ManSoy.Global;

{ TTradeFunctions }

function TLuaFuns.LoadPackage(L: lua_State): Integer;
begin
  lua_newtable(L);

{$REGION 'Windows API'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSleep'), 'MsSleep');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindWindow'), 'MsFindWindow');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindWindowEx'), 'MsFindWindowEx');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsIsWindow'), 'MsIsWindow');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetTickCount'), 'MsGetTickCount');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetClientRect'), 'MsGetClientRect');
  lua_rawset(L, -3);
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSendMessage'), 'MsSendMessage');
  lua_rawset(L, -3);
{$ENDREGION}

{$REGION '封装'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFrontWindow'), 'MsFrontWindow');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsDebugInfo'), 'MsDebugInfo');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsStartGame'), 'MsStartGame');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressPassWord'), 'MsPressPassWord');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsCheck'), 'MsCheck');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsCloseGame'), 'MsCloseGame');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetTopLeft'), 'MsGetTopLeft');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsDaMa'), 'MsDaMa');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsQuitSafe'), 'MsQuitSafe');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetCarryAmount'), 'MsGetCarryAmount');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsCreateBmp'), 'MsCreateBmp');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSetGameCfg'), 'MsSetGameCfg');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetPwd'), 'MsGetPassWord');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsOcr'), 'MsOcr');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsOcrEx'), 'MsOcrEx');
  lua_rawset(L, -3);


{$ENDREGION}

{$REGION '大漠'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsClick'), 'MsClick');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsDbClick'), 'MsDbClick');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsRightClick'), 'MsRightClick');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsDragMouse'), 'MsDragMouse');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindImg'), 'MsFindImg');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindImgEx'), 'MsFindImgEx');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsAreaFindImg'), 'MsAreaFindImg');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsAreaFindImgEx'), 'MsAreaFindImgEx');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsAreaFindString'), 'MsAreaFindString');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindString'), 'MsFindString');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsFindStringEx'), 'MsFindStringEx');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetNumber'), 'MsGetNumber');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressDel'), 'MsPressDel');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressEnter'), 'MsPressEnter');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressEsc'), 'MsPressEsc');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsCaptureGame'), 'MsCaptureGame');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsCaptureArea'), 'MsCaptureArea');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsMoveWindow'), 'MsMoveWindow');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressKey'), 'MsPressKey');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsTheKeysWalk'), 'MsTheKeysWalk');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressChar'), 'MsPressChar');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsWheelDown'), 'MsWheelDown');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsMoveTo'), 'MsMoveTo');
  lua_rawset(L, -3);
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPressString'), 'MsPressString');
  lua_rawset(L, -3);
{$ENDREGION}

{$REGION '公共变量'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetGameHandle'), 'MsGetGameHandle');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSetGameHandle'), 'MsSetGameHandle');
  lua_rawset(L, -3);
{$ENDREGION}

{$REGION '公共参数'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetDelay'), 'MsGetDelay');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetPianSe'), 'MsGetPianSe');
  lua_rawset(L, -3);
{$ENDREGION}

{$REGION '通讯'}
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsPostStatus'), 'MsPostStatus');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSetRoleStep'), 'MsSetRoleStep');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsResetRoleStep'), 'MsResetRoleStep');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetRoleStep'), 'MsGetRoleStep');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetTargetRoleStep'), 'MsGetTargetRoleStep');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsSetMasterRecRoleName'), 'MsSetMasterRecRoleName');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsClearRecvRoleName'), 'MsClearRecvRoleName');
  lua_rawset(L, -3);

  TVerySimpleLua.PushFunction(L, Self, MethodAddress('MsGetMasterRecRoleName'), 'MsGetMasterRecRoleName');
  lua_rawset(L, -3);
{$ENDREGION}
  Result := 1;
end;

procedure TLuaFuns.PackageReg(L: lua_State);
begin
  TVerySimpleLua.RegisterPackage(L, 'TLuaFuns', Self, 'LoadPackage');
end;

{$REGION 'Windows API'}
function TLuaFuns.MsFindWindow(L: lua_State): Integer;
var
  ArgCount: Integer;
  sClassName, sWindowText: string;
  szClassName, szWindowText: PChar;
  hWindow: HWND;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    sClassName := string(AnsiString(Lua_ToString(L, 2)));
    sWindowText := string(AnsiString(Lua_ToString(L, 3)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 3 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;

    if sClassName = '' then
      szClassName := nil
    else
      szClassName := PChar(sClassName);

    if sWindowText = '' then
      szWindowText := nil
    else
      szWindowText := PChar(sWindowText);

    hWindow := WinApi.Windows.FindWindow(szClassName, szWindowText);
    if not WinApi.Windows.IsWindow(hWindow) then
    begin
      Lua_PushInteger(L, 0);
      Exit;
    end;
    Lua_PushInteger(L, hWindow);
  except
  end;
end;

function TLuaFuns.MsFindWindowEx(L: lua_State): Integer;
var
  ArgCount: Integer;
  sClassName, sWindowText: string;
  szClassName, szWindowText: PChar;
  hParent, hAfter, hWindow: HWND;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    hParent := Lua_ToInteger(L, 2);
    hAfter := Lua_ToInteger(L, 3);
    sClassName := string(AnsiString(Lua_ToString(L, 4)));
    sWindowText := string(AnsiString(Lua_ToString(L, 5)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 5 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;

    if sClassName = '' then
      szClassName := nil
    else
      szClassName := PChar(sClassName);

    if sWindowText = '' then
      szWindowText := nil
    else
      szWindowText := PChar(sWindowText);

    hWindow := WinApi.Windows.FindWindowEx(hParent, hAfter, szClassName, szWindowText);
    if not WinApi.Windows.IsWindow(hWindow) then
    begin
      Lua_PushInteger(L, 0);
      Exit;
    end;
    Lua_PushInteger(L, hWindow);
  except
  end;
end;

function TLuaFuns.MsIsWindow(L: lua_State): Integer;
var
  X, Y, X1, Y1: Integer;
  ArgCount: Integer;
  hWindow: HWND;
begin
  Result := RetOK;
  try
    ArgCount := Lua_GetTop(L);
    hWindow := Lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    if not Winapi.Windows.IsWindow(hWindow) then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsGetTickCount(L: lua_State): Integer;
var
  dwTickCount: DWORD;
begin
  Result := 1;
  try
    dwTickCount := WinApi.Windows.GetTickCount();
    Lua_PushInteger(L, dwTickCount);
  except
  end;
end;

function TLuaFuns.MsSleep(L: lua_State): Integer;
var
  ArgCount: Integer;
  dwInterVal, dwAdd, dwTmp: DWORD;
begin
  Result := RetOK;
  try
    dwTmp := 0;
    ArgCount := Lua_GetTop(L);
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    dwInterVal := Lua_ToInteger(L, 2);

    if ArgCount > 2 then
    begin
      dwAdd := Lua_ToInteger(L, 3);
      dwTmp := Random(dwAdd);
    end;
    Lua_Pop(L, Lua_GetTop(L));
    Winapi.Windows.Sleep(dwInterVal + dwTmp);
    Lua_PushInteger(L, RetOk);
  except
  end;
end;

function TLuaFuns.MsGetClientRect(L: lua_State): Integer;
var
  X, Y, X1, Y1: Integer;
  ArgCount: Integer;
  hWindow: HWND;
begin
  Result := 4;    //Result 表示返回的参数个数
  try
    ArgCount := Lua_GetTop(L);
    hWindow := Lua_ToInteger(L, 2);
    if ArgCount >= 2 then
    begin
      GCommFuns.fn获取客户区域(hWindow, X, Y, X1, Y1);
      Lua_Pop(L, Lua_GetTop(L));
      Lua_PushInteger(L, X);
      Lua_PushInteger(L, Y);
      Lua_PushInteger(L, X1);
      Lua_PushInteger(L, Y1);
    end else
    begin
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
    end;
  except
  end;
end;

function TLuaFuns.MsSendMessage(L: lua_State): Integer;
var
  ArgCount: Integer;
  hHandle: HWND;
  WmMsg: DWORD;
  lP: LPARAM;
  wP: WPARAM;
  lRet: LRESULT;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount < 3 then
    begin
      Lua_Pop(L, Lua_GetTop(L));
      Lua_PushInteger(L, RetErr);
      Exit;
    end;

    hHandle := Lua_ToInteger(L, 2);
    WmMsg := Lua_ToInteger(L, 3);
    lP := 0; wP := 0;
    if ArgCount > 3 then
    begin
      lP := Lua_ToInteger(L, 4);
    end;

    if ArgCount > 4 then
    begin
      wP := Lua_ToInteger(L, 5);
    end;

    lRet := SendMessage(hHandle, WmMsg, wP, lP);

    Lua_PushInteger(L, lRet);
  except
  end;
end;
{$ENDREGION}

{$REGION '封装功能'}
//--前置窗口
function TLuaFuns.MsFrontWindow(L: lua_State): Integer;
var
  ArgCount: Integer;
  hWindow: HWND;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    hWindow := lua_toInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.fn前置窗口(hWindow);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOk);
  except
  end;
end;

function TLuaFuns.MsDebugInfo(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText: string;
  bRet: Boolean;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    sText := lua_toString(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then Exit;
    ManSoy.Global.DebugInf(sText, []);
  except
  end;
end;

function TLuaFuns.MsPressPassWord(L: lua_State): Integer;
var
  ArgCount: Integer;
  vHPwd: HWND;
  vPassWord: string;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    vHPwd := HWND(Lua_ToInteger(L, 2));
    vPassWord := string(AnsiString(lua_tostring(L, 3)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 3 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.PressPassWord(vHPwd, vPassWord, 200);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOk);
  except
  end;
end;

function TLuaFuns.MsStartGame(L: lua_State): Integer;
var
  sGamePath: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  bRet: Boolean;
begin
  Result := 1;
  try
    FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_SHOW;
    sGamePath := Format('%s\start\DNFchina.exe', [GSharedInfo.ClientSet.GamePath]);
    if not FileExists(sGamePath) then
    begin
      TradeClient.PostStatus('游戏路径设置有误', [], tsFail);
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    //Sleep(1000);
    bRet := CreateProcess(PWideChar(sGamePath), nil, nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
    if not bRet then
    begin
      uGlobal.AddLogMsg('创建游戏进程失败：%d', [GetLastError]);
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
    Lua_PushInteger(L, RetOK);
  except
    on E: Exception do
      uGlobal.AddLogMsg('启动游戏异常[%s]',[E.Message]);
  end;
end;

function TLuaFuns.MsCheck(L: lua_State): Integer;
var
  ArgCount: Integer;
  bCheckWindow, bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      bCheckWindow := Lua_ToInteger(L, 2) <> 0;
    Lua_Pop(L, Lua_GetTop(L));
    bRet := GCommFuns.fn校验(bCheckWindow);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsCloseGame(L: lua_State): Integer;
var
  bRet: Boolean;
  dwDelay: Integer;
  ArgCount: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      dwDelay := Lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    bRet := GCommFuns.CloseGame(dwDelay);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsGetTopLeft(L: lua_State): Integer;
var
  ArgCount: Integer;
  hGame: HWND;
  X, Y, X1, Y1: Integer;
begin
  Result := 2;
  ArgCount := lua_gettop(L);
  if ArgCount < 2 then
  begin
    lua_pushinteger(L, -1);
    lua_pushinteger(L, -1);
  end;
  hGame := lua_tointeger(L, 2);
  if not IsWindow(hGame) then
  begin
    lua_pushinteger(L, -1);
    lua_pushinteger(L, -1);
  end;

  GCommFuns.fn获取客户区域(hGame, X, Y, X1, Y1);
  if IsWindow(hGame) then
  begin
    lua_pushinteger(L, X);
    lua_pushinteger(L, Y);
  end;
end;

function TLuaFuns.MsDaMa(L: lua_State): Integer;
var
  ArgCount: Integer;
  sRet, sAcc, sPwd, sFileName: string;
  iDelay: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 3 then
  begin
    Lua_pushString(L, '');
    Exit;
  end;
  sAcc := GSharedInfo.ClientSet.Dama2User;
  sPwd := GSharedInfo.ClientSet.Dama2Pwd;
  sFileName := string(AnsiString(lua_tostring(L,2)));
  iDelay := lua_tointeger(L, 3);
  sRet := GCommFuns.fnDaMa(sAcc, sPwd, sFileName, iDelay);
  Lua_pushString(L, PAnsiChar(AnsiString(sRet)));
end;

function TLuaFuns.MsQuitSafe(L: lua_State): Integer;
var
  sRet: string;
begin
  Result := 1;
  sRet := GCommFuns.fnQuitSate;
  Lua_pushString(L, PAnsiChar(AnsiString(sRet)));
end;

function TLuaFuns.MsGetCarryAmount(L: lua_State): Integer;
var
  ArgCount: Integer;
  iRoleLevel, iRet: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 2 then
  begin
    lua_pushinteger(L, -1);
    Exit;
  end;
  iRoleLevel := lua_tointeger(L,2);
  iRet := GCommFuns.GetCarryAmount(iRoleLevel);
  lua_pushinteger(L, iRet);
end;

function TLuaFuns.MsCreateBmp(L: lua_State): Integer;
var
  ArgCount: Integer;
  sCaption, sImg: string;
  R, G, B: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 6 then
  begin
    lua_pushinteger(L, RetErr);
    Exit;
  end;
  sCaption := string(AnsiString(lua_tostring(L, 2)));
  sImg := string(AnsiString(lua_tostring(L, 3)));
  R := lua_tointeger(L,4);
  G := lua_tointeger(L,5);
  B := lua_tointeger(L,6);

  sImg :=  Format('%sBmp(W7)\%s.bmp', [GSharedInfo.AppPath, sImg]);
  if FileExists(sImg) then
  begin
    GCommFuns.FreePic(sImg);
    DeleteFile(sImg);
    Sleep(200);
  end;

  if GCommFuns.CreateBmp(sCaption, R, G, B, sImg) then
  begin
    lua_pushinteger(L, RetOK);
  end else
  begin
    lua_pushinteger(L, RetErr);
  end;

end;

function TLuaFuns.MsSetGameCfg(L: lua_State): Integer;
var
  sGameSvr, sGameAccount: string;
  ArgCount: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 3 then
  begin
    lua_pushinteger(L, RetErr);
    Exit;
  end;
  sGameSvr := string(AnsiString(lua_tostring(L, 2)));
  sGameAccount := string(AnsiString(lua_tostring(L, 3)));
  if GCommFuns.WriteGameRegionSvr(GSharedInfo.ClientSet.GamePath, sGameSvr, sGameAccount) then
  begin
    lua_pushinteger(L, RetErr);
    Exit;
  end;
  lua_pushinteger(L, RetOK);
end;

function TLuaFuns.MsGetPwd(L: lua_State): Integer;
var
  sAccount, sPwd: string;
  ArgCount: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 2 then
  begin
    Lua_pushString(L, PAnsiChar(AnsiString('-1')));
    Exit;
  end;
  sAccount := string(AnsiString(lua_tostring(L, 2)));
  sPwd := GCommFuns.GetPassWord(sAccount);
  Lua_pushString(L, PAnsiChar(AnsiString(sPwd)));
end;

{$ENDREGION}

{$REGION '大漠'}
function TLuaFuns.MsClick(L: lua_State): Integer;
var
  X, Y, X1, Y1, ArgCount: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      X := Lua_ToInteger(L, 2);
    if ArgCount > 2 then
      Y := Lua_ToInteger(L, 3);

    if ArgCount > 3 then
      X1 := Lua_ToInteger(L, 4);
    if ArgCount > 4 then
      Y1 := Lua_ToInteger(L, 5);

    if ArgCount > 4 then
    begin
      Randomize;
      X := X + Random(X1);
      Y := Y + Random(Y1);
    end;

    Lua_Pop(L, Lua_GetTop(L));
    GCommFuns.pro点击鼠标左键(X, Y);
    lua_pushinteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsDbClick(L: lua_State): Integer;
var
  X, Y, ArgCount: Integer;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      X := Lua_ToInteger(L, 2);
    if ArgCount > 2 then
      Y := Lua_ToInteger(L, 3);
    GCommFuns.pro双击鼠标左键(X, Y);
  except
  end;
end;

function TLuaFuns.MsRightClick(L: lua_State): Integer;
var
  X, Y, ArgCount: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      X := Lua_ToInteger(L, 2);
    if ArgCount > 2 then
      Y := Lua_ToInteger(L, 3);
    Lua_Pop(L, Lua_GetTop(L));
    GCommFuns.pro点击鼠标右键(X, Y);
    lua_pushinteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsDragMouse(L: lua_State): Integer;
var
  X, Y, X2, Y2, ArgCount: Integer;
begin
  Result := 0;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      X := Lua_ToInteger(L, 2);
    if ArgCount > 2 then
      Y := Lua_ToInteger(L, 3);

    if ArgCount > 3 then
      X2 := Lua_ToInteger(L, 4);
    if ArgCount > 4 then
      Y2 := Lua_ToInteger(L, 5);

    //DebugInfo('MS - %d-%d-%d-%d', []);
    GCommFuns.pro拖动鼠标(X, Y, X2, Y2);
    Sleep(1000);
    GCommFuns.MoveTo(0, 0);
  except
  end;
end;

function TLuaFuns.MsFindImg(L: lua_State): Integer;
var
  ArgCount: Integer;
  sImgName: string;
  iRatio: Single;
  iDelay: DWORD;
  bRet: Boolean;
begin
  Result := 1;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    if ArgCount > 1 then
      sImgName := string(AnsiString(Lua_ToString(L, 2)));
    if ArgCount > 2 then
      iRatio := Lua_ToNumber(L, 3);
    if ArgCount > 3 then
      iDelay := Lua_ToInteger(L, 4);

    DebugInf('MS - FindImgParam[%s][%.2f][%d]', [sImgName, iRatio, iDelay]);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.fn查找图片(sImgName, iRatio, iDelay);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOk);
  except
  end;
end;

function TLuaFuns.MsFindImgEx(L: lua_State): Integer;
var
  ArgCount: Integer;
  sImgName: string;
  iRatio: Single;
  iDelay: DWORD;
  vPos: TFindRet;
begin
  Result := 3;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    if ArgCount > 1 then
      sImgName := string(AnsiString(Lua_ToString(L, 2)));
    if ArgCount > 2 then
      iRatio := Lua_ToNumber(L, 3);
    if ArgCount > 3 then
      iDelay := Lua_ToInteger(L, 4);

    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Exit;
    end;
    vPos := GCommFuns.fn查找图片_返回坐标(sImgName, iRatio, iDelay);
    Lua_PushInteger(L, vPos.X);
    Lua_PushInteger(L, vPos.Y);
    Lua_PushInteger(L, vPos.Ret);
  except
  end;
end;

function TLuaFuns.MsAreaFindImg(L: lua_State): Integer;
var
  ArgCount: Integer;
  sImgName: string;
  iRatio: Single;
  iDelay: DWORD;
  bRet: Boolean;
  X, Y, X1, Y1: Integer;
begin
  Result := 1;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);

    if ArgCount > 5 then
      sImgName := string(AnsiString(Lua_ToString(L, 6)));
    if ArgCount > 6 then
      iRatio := Lua_ToNumber(L, 7);
    if ArgCount > 7 then
      iDelay := Lua_ToInteger(L, 8);

    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 5 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.fn查找图片_区域(X, Y, X1, Y1, sImgName, iRatio, iDelay);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsAreaFindImgEx(L: lua_State): Integer;
var
  ArgCount: Integer;
  sImgName: string;
  iRatio: Single;
  iDelay: DWORD;
  vFindRet: TFindRet;
  X, Y, X1, Y1: Integer;
begin
  Result := 3;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);

    if ArgCount > 5 then
      sImgName := string(AnsiString(Lua_ToString(L, 6)));
    if ArgCount > 6 then
      iRatio := Lua_ToNumber(L, 7);
    if ArgCount > 7 then
      iDelay := Lua_ToInteger(L, 8);

    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 5 then
    begin
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Exit;
    end;
    vFindRet := GCommFuns.fn查找图片_返回坐标_区域(X, Y, X1, Y1, sImgName, iRatio, iDelay);
    Lua_PushInteger(L, vFindRet.X);
    Lua_PushInteger(L, vFindRet.Y);
    Lua_PushInteger(L, vFindRet.Ret);
  except
  end;
end;


function TLuaFuns.MsAreaFindString(L: lua_State): Integer;
var
  x1, y1, x2, y2, ArgCount: Integer;
  sText, sPianSe: string;
  iRatio: Single;
  iDelay: DWORD;
  fRet: TFindRet;
begin
  Result := 3;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    if ArgCount > 1 then
      x1 := Lua_ToInteger(L, 2);

    if ArgCount > 2 then
      y1 := Lua_ToInteger(L, 3);

    if ArgCount > 3 then
      x2 := Lua_ToInteger(L, 4);

    if ArgCount > 4 then
      y2 := Lua_ToInteger(L, 5);

    if ArgCount > 5 then
      sText := string(AnsiString(Lua_ToString(L, 6)));

    if ArgCount > 6 then
      sPianSe := string(AnsiString(Lua_ToString(L, 7)));

    if ArgCount > 7 then
      iRatio := Lua_ToNumber(L, 8);

    if ArgCount > 8 then
      iDelay := Lua_ToInteger(L, 9);

    Lua_Pop(L, Lua_GetTop(L));

    if ArgCount < 7 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    fRet := GCommFuns.fn区域找字(x1, y1, x2, y2, sText, sPianSe, CON_SYS_DICT, iRatio, iDelay);
//    if fRet.Ret = -1 then
//    begin
//      Lua_PushInteger(L, -1);
//      Lua_PushInteger(L, -1);
//      Lua_PushInteger(L, -1);
//      Exit;
//    end;
    Lua_PushInteger(L, fRet.X);
    Lua_PushInteger(L, fRet.Y);
    Lua_PushInteger(L, fRet.Ret);
  except
  end;
end;

function TLuaFuns.MsFindString(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText, sPianSe: string;
  iRatio: Single;
  iDelay: DWORD;
  bRet: Boolean;
  X, Y, X1, Y1: Integer;
begin
  Result := 1;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    if ArgCount > 1 then
      sText := string(AnsiString(Lua_ToString(L, 2)));

    if ArgCount > 2 then
      sPianSe := string(AnsiString(Lua_ToString(L, 3)));

    if ArgCount > 3 then
      iRatio := Lua_ToNumber(L, 4);

    if ArgCount > 4 then
      iDelay := Lua_ToInteger(L, 5);

    Lua_Pop(L, Lua_GetTop(L));

    if ArgCount < 3 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.fn全屏找字(sText, sPianSe, CON_SYS_DICT, iRatio, iDelay);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsFindStringEx(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText, sPianSe: string;
  iRatio: Single;
  iDelay: DWORD;
  vPos: TFindRet;
  X, Y, X1, Y1: Integer;
begin
  Result := 3;
  try
    iRatio := 1.0;
    iDelay := 1;
    ArgCount := Lua_GetTop(L);

    if ArgCount > 1 then
      sText := string(AnsiString(Lua_ToString(L, 2)));
    if ArgCount > 2 then
      sPianSe := string(AnsiString(Lua_ToString(L, 3)));

    if ArgCount > 3 then
      iRatio := Lua_ToNumber(L, 4);
    if ArgCount > 4 then
      iDelay := Lua_ToInteger(L, 5);

    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 3 then
    begin
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Lua_PushInteger(L, -1);
      Exit;
    end;
    vPos := GCommFuns.fn全屏找字_返回坐标(sText, sPianSe, CON_SYS_DICT, iRatio, iDelay);
    Lua_PushInteger(L, vPos.X);
    Lua_PushInteger(L, vPos.Y);
    Lua_PushInteger(L, vPos.Ret);
  except
  end;
end;

function TLuaFuns.MsGetNumber(L: lua_State): Integer;
var
  ArgCount: Integer;
  sPianSe: string;
  iRatio: Single;
  iRet: Int64;
  X, Y, X1, Y1: Integer;
begin
  Result := 1;
  try
    iRatio := 1.0;
    ArgCount := Lua_GetTop(L);

    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);

    if ArgCount > 5 then
      sPianSe := string(AnsiString(Lua_ToString(L, 6)));
    if ArgCount > 6 then
      iRatio := Lua_ToNumber(L, 7);

    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 5 then
    begin
      Lua_PushInteger(L, -1);
      Exit;
    end;
    iRet := GCommFuns.fn获取数量(X, Y, X1, Y1, sPianSe, iRatio);
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsPressDel(L: lua_State): Integer;
var
  ArgCount: Integer;
  iTimes: Integer;
  iRet: Integer;
begin
  Result := 1;
  try
    iTimes := 1;

    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      iTimes := Lua_toInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    GCommFuns.pro按下删除键(iTimes);
    Lua_PushInteger(L, RetOk);
  except
  end;
end;

function TLuaFuns.MsPressEnter(L: lua_State): Integer;
var
  iRet: Integer;
  cmd: string;
begin
  Result := 1;
  try
    iRet := GCommFuns.KeyPress(VK_RETURN);
    //if uCommFuns.MsKeyPress(VK_RETURN) then iRet := 1 else iRet := 0;
    //cmd:= Format('%sIoPress.exe 2 %d', [GSharedInfo.AppPath, VK_RETURN]);
    //if GCommFuns.StartProcess(cmd, False) then iRet := 1 else iRet := 0;
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsPressEsc(L: lua_State): Integer;
var
  iRet: Integer;
begin
  Result := 1;
  try
    iRet := GCommFuns.KeyPress(VK_ESCAPE);
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsCaptureGame(L: lua_State): Integer;
var
  ArgCount: Integer;
  sFileName: string;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    sFileName := string(AnsiString(lua_tostring(L, 2)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    bRet := GCommFuns.fn截取屏幕(sFileName);
    if not bRet then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    lua_pushinteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsCaptureArea(L: lua_State): Integer;
var
  ArgCount, X, Y, X1, Y1: Integer;
  sFileName: string;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);
    sFileName := string(AnsiString(lua_tostring(L, 6)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 6 then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    //GCommFuns.DebugInfo('MS ');
    bRet := GCommFuns.fn截取屏幕_区域(X, Y, X1, Y1, sFileName);
    if not bRet then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    lua_pushinteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsMoveWindow(L: lua_State): Integer;
var
  ArgCount, X, Y: Integer;
  hWindow: HWND;
  iRet: Integer;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    hWindow := Lua_ToInteger(L, 2);
    X := Lua_ToInteger(L, 3);
    Y := Lua_ToInteger(L, 4);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 4 then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    iRet := GCommFuns.fn移动窗口(hWindow, X, Y);
    lua_pushinteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsPressKey(L: lua_State): Integer;
var
  ArgCount: Integer;
  iKey: Integer;
  iRet: Integer;
begin
  Result := 1;
  try
    iKey := 0;

    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      iKey := Lua_toInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    iRet := GCommFuns.fn按键(iKey);
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsTheKeysWalk(L: lua_State): Integer;
var
  ArgCount: Integer;
  iKey: Integer;
  iTime: Integer;
  iRet: Integer;
begin
  Result := 1;
  try
    iKey := 0;
    iTime := 500;

    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      iKey := Lua_toInteger(L, 2);

    if ArgCount > 2 then
      iTime := Lua_toInteger(L, 3);

    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    iRet := GCommFuns.fn方向键走路(iKey, iTime);
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsPressChar(L: lua_State): Integer;
var
  ArgCount: Integer;
  sKey: string;
  iRet: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      sKey := string(AnsiString(lua_tostring(L, 2)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    iRet := GCommFuns.KeyPressChar(sKey);
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsWheelDown(L: lua_State): Integer;
var
  ArgCount: Integer;
  iRet: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    Lua_Pop(L, Lua_GetTop(L));
    iRet := GCommFuns.WheelDown();
    Lua_PushInteger(L, iRet);
  except
  end;
end;

function TLuaFuns.MsMoveTo(L: lua_State): Integer;
var
  X, Y, ArgCount: Integer;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      X := Lua_ToInteger(L, 2);
    if ArgCount > 2 then
      Y := Lua_ToInteger(L, 3);
    Lua_Pop(L, Lua_GetTop(L));
    GCommFuns.pro移动鼠标(X, Y);
    lua_pushinteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsPressString(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText: string;
  hGame: HWND;
  iRet: Integer;
begin
  Result := 1;
  ArgCount := lua_gettop(L);
  if ArgCount < 3 then
  begin
    lua_pushinteger(L, RetErr);
    Exit;
  end;
  hGame := lua_tointeger(L, 2);
  sText := string(AnsiString(lua_tostring(L, 3)));
  if not IsWindow(hGame) then
  begin
    lua_pushinteger(L, RetErr);
    Exit;
  end;
  iRet := GCommFuns.SendString(hGame, sText);
  lua_pushinteger(L, RetOk);
end;

function TLuaFuns.MsOcr(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText, sPianSe: string;
  iRatio: Single;
  bRet: Boolean;
  X, Y, X1, Y1: Integer;
begin
  Result := 1;
  try
    iRatio := 1.0;
    ArgCount := Lua_GetTop(L);
    sText := 'Error';
    if ArgCount < 5 then
    begin
      //Lua_PushInteger(L, RetErr);
      lua_pushstring(L, PAnsiChar(AnsiString(sText)));
      Exit;
    end;

    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);
    sPianSe := string(AnsiString(Lua_ToString(L, 6)));
    if ArgCount > 6 then
      iRatio := Lua_ToNumber(L, 7);

    Lua_Pop(L, Lua_GetTop(L));

    if ArgCount < 3 then
    begin
      lua_pushstring(L, PAnsiChar(AnsiString(sText)));
      Exit;
    end;
    sText := GCommFuns.Ocr(X, Y, X1, Y1, sPianSe, iRatio);
    lua_pushstring(L, PAnsiChar(AnsiString(sText)));
  except
  end;
end;

function TLuaFuns.MsOcrEx(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText, sPianSe: string;
  iRatio: Single;
  bRet: Boolean;
  X, Y, X1, Y1: Integer;
begin
  Result := 1;
  try
    iRatio := 1.0;
    ArgCount := Lua_GetTop(L);
    sText := 'Error';
    if ArgCount < 5 then
    begin
      //Lua_PushInteger(L, RetErr);
      lua_pushstring(L, PAnsiChar(AnsiString(sText)));
      Exit;
    end;

    X := Lua_ToInteger(L, 2);
    Y := Lua_ToInteger(L, 3);
    X1 := Lua_ToInteger(L, 4);
    Y1 := Lua_ToInteger(L, 5);
    sPianSe := string(AnsiString(Lua_ToString(L, 6)));
    if ArgCount > 6 then
      iRatio := Lua_ToNumber(L, 7);

    Lua_Pop(L, Lua_GetTop(L));

    if ArgCount < 3 then
    begin
      lua_pushstring(L, PAnsiChar(AnsiString(sText)));
      Exit;
    end;
    sText := GCommFuns.OcrEx(X, Y, X1, Y1, sPianSe, iRatio);
    lua_pushstring(L, PAnsiChar(AnsiString(sText)));
  except
  end;
end;

{$ENDREGION}

{$REGION '公共变量'}
function TLuaFuns.MsGetGameHandle(L: lua_State): Integer;
begin
  Result := 1;
  try
    if IsWindow(GSharedInfo.GameWindow) then
    begin
      Lua_PushInteger(L, GSharedInfo.GameWindow);
    end else
    begin
      Lua_PushInteger(L, RetErr);
    end;
  except

  end;
end;

function TLuaFuns.MsSetGameHandle(L: lua_State): Integer;
var
  ArgCount: Integer;
  hGameWindow: HWND;
begin
  Result := 1;
  try
    ArgCount := Lua_GetTop(L);
    hGameWindow := lua_ToInteger(L, 2);
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    GSharedInfo.GameWindow := hGameWindow;

    Lua_PushInteger(L, RetOk);
  except
  end;
end;
{$ENDREGION}

{$REGION '公共参数'}
function TLuaFuns.MsGetDelay(L: lua_State): Integer;
var
  sKey: string;
  ArgCount: Integer;
  iRet: Integer;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    sKey := string(AnsiString(lua_tostring(L, 2)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    iRet := GCommFuns.GetDealy(sKey);
    lua_pushinteger(L, iRet);
  except

  end;
end;

function TLuaFuns.MsGetPianSe(L: lua_State): Integer;
var
  sKey, sRet: string;
  ArgCount: Integer;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    sKey := string(AnsiString(lua_tostring(L, 2)));
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    sRet := GCommFuns.GetPianSe(sKey);
    lua_pushstring(L, PAnsiChar(AnsiString(sRet)));
  except

  end;
end;
{$ENDREGION}

{$REGION '通讯'}
function TLuaFuns.MsPostStatus(L: lua_State): Integer;
var
  ArgCount: Integer;
  sText: string;
  vStatus: TTaskState;
  bRestart, bRet: Boolean;
begin
  Result := 1;
  try
    vStatus := tsNormal;
    bRestart := True;
    ArgCount := Lua_GetTop(L);
    if ArgCount > 1 then
      sText := string(AnsiString(lua_tostring(L, 2)));
    if ArgCount > 2 then
      vStatus := TTaskState(lua_toInteger(L, 3));
    if ArgCount > 3 then
      bRestart := lua_toInteger(L, 4) <> 0;
    Lua_Pop(L, Lua_GetTop(L));
    if ArgCount < 2 then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    bRet := TradeClient.PostStatus(sText, [], vStatus, bRestart);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsResetRoleStep(L: lua_State): Integer;
var
  ArgCount: Integer;
  vRoleStep: Integer;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    if ArgCount < 2 then Exit;
    vRoleStep := lua_tointeger(L, 2);
    Lua_Pop(L, ArgCount);
    bRet := TradeClient.ReSetRoleStep(GSharedInfo.ClientSet.GroupName,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].role,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptRole,
      vRoleStep);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsGetRoleStep(L: lua_State): Integer;
var
  vRoleStep: TRoleStep;
begin
  Result := 1;
  try
    Lua_Pop(L, lua_gettop(L));
    vRoleStep := TradeClient.GetRoleStep(GSharedInfo.ClientSet.GroupName);
    Lua_PushInteger(L, Integer(vRoleStep));
  except
  end;
end;

function TLuaFuns.MsGetTargetRoleStep(L: lua_State): Integer;
var
  ArgCount: Integer;
  vRoleStep: TRoleStep;
  sRoleName, sTargetRoleName: string;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    Lua_Pop(L, ArgCount);
    vRoleStep := TradeClient.GetTargetRoleStep(GSharedInfo.ClientSet.GroupName
      , GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].role
      , GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptRole
      );
    Lua_PushInteger(L, Integer(vRoleStep));
  except
  end;
end;

function TLuaFuns.MsSetMasterRecRoleName(L: lua_State): Integer;
var
  ArgCount: Integer;
  sRecRoleName, sMasterRoleName: string;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    //if ArgCount < 3 then Exit;
    //sMasterRoleName := string(AnsiString(lua_tostring(L, 2)));
    //sRecRoleName := string(AnsiString(lua_tostring(L, 3)));
    Lua_Pop(L, ArgCount);
    bRet := TradeClient.SetMasterRecRoleName(
      GSharedInfo.ClientSet.GroupName,
      GSharedInfo.OrderItem.orderNo,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].receiptRole,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].role);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsClearRecvRoleName(L: lua_State): Integer;
var
  ArgCount: Integer;
  sRecRoleName, sMasterRoleName: string;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    Lua_Pop(L, ArgCount);
    bRet := TradeClient.ClearRecvRoleName(
      GSharedInfo.ClientSet.GroupName,
      GSharedInfo.OrderItem.orderNo,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].role);
    if not bRet then
    begin
      Lua_PushInteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except
  end;
end;

function TLuaFuns.MsGetMasterRecRoleName(L: lua_State): Integer;
var
  ArgCount: Integer;
  sTargetRoleName, sMasterRoleName: string;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    if ArgCount < 2 then Exit;
    sMasterRoleName := string(AnsiString(lua_tostring(L, 2)));
    Lua_Pop(L, ArgCount);
    sTargetRoleName := TradeClient.GetMasterRecRoleName(GSharedInfo.ClientSet.GroupName, sMasterRoleName);
    lua_pushstring(L, PAnsiChar(AnsiString(sTargetRoleName)));
    AddLogMsg('获取到的子号角色为[%s]', [sTargetRoleName], True);
  except
  end;
end;

function TLuaFuns.MsSetRoleStep(L: lua_State): Integer;
var
  ArgCount: Integer;
  vRoleStep: Integer;
  bRet: Boolean;
begin
  Result := 1;
  try
    ArgCount := lua_gettop(L);
    if ArgCount < 2 then Exit;
    vRoleStep := lua_tointeger(L, 2);
    Lua_Pop(L, ArgCount);
    bRet := TradeClient.SetRoleStep(
      GSharedInfo.ClientSet.GroupName,
      GSharedInfo.OrderItem.roles[GSharedInfo.RoleIndex].role,
      vRoleStep
    );
    if not bRet then
    begin
      lua_pushinteger(L, RetErr);
      Exit;
    end;
    Lua_PushInteger(L, RetOK);
  except on E: Exception do
    AddLogMsg('MsPostRoleInfo fail[%s]...', [E.Message]);
  end;
end;
{$ENDREGION}

end.
