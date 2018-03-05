program DToolServer;

//{$R '..\Shared\ResString.res' '..\Shared\ResString.rc'}

uses
//  EMemLeaks,
//  EResLeaks,
//  ESendMailSMTP,
//  EDialogWinAPIMSClassic,
//  EDialogWinAPIEurekaLogDetailed,
//  EDialogWinAPIStepsToReproduce,
//  EDebugExports,
//  EFixSafeCallException,
//  EMapWin32,
//  EAppVCL,
//  ExceptionLog7,
  WinApi.Windows,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Controls,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uFrmParamSet in 'uFrmParamSet.pas' {FrmParamSet},
  uDToolServer in 'uDToolServer.pas',
  uFrmSplash in 'uFrmSplash.pas' {FrmSplash},
  uFrmOrderItem in 'uFrmOrderItem.pas' {FrmOrderItem},
  ManSoy.Encode in '..\Global\ManSoy.Encode.pas',
  ManSoy.MsgBox in '..\Global\ManSoy.MsgBox.pas',
  ManSoy.Global in '..\Global\ManSoy.Global.pas',
  HPSocketSDKUnit in '..\Comm\HPSocketSDKUnit.pas',
  uGlobal in '..\Comm\uGlobal.pas',
  uJsonClass in '..\Comm\uJsonClass.pas',
  SuperObject in '..\Comm\SuperObject.pas',
  uCommand in '..\Comm\uCommand.pas',
  uTaskManager in 'uTaskManager.pas',
  uFrmUpdateDataBase in 'uFrmUpdateDataBase.pas' {FrmUpdateDataBase},
  uLogger in '..\Comm\uLogger.pas';

{$R *.res}

var
  hTmp: THandle;

const
  AppID = '{429AECEE-7451-42A2-B022-A48F112061D9}';

begin
(*
  {$IFNDEF _MS_DEBUG}
  //--登陆窗口
  with TFrmLogin.Create(nil) do
  try
    if ShowModal <> mrOk then begin
      Application.Terminate;
      Exit;
    end;
  finally
    Free;
  end;
  {$ENDIF}
*)
  hTmp := FindWindow(nil, AppID);
  if IsWindow(hTmp) then
  begin
    ManSoy.MsgBox.WarnMsg(0, '控制台只能打开一份', []);
    Application.Terminate;
    Exit;
  end;
  //--判断数据库连接是否正常
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'DNF自动交易--控制台';
  FrmSplash := TFrmSplash.Create(Application);
  FrmSplash.Show;
  FrmSplash.Update;
  //--加载配置信息
  FrmSplash.fnShowHint('加载配置信息...');
  //InitParamSet;
  //---
  FrmSplash.fnShowHint('正在初始化数据模块...');
  //--
  FrmSplash.fnShowHint('检测数据库服务配置...');
//  if not DM.fn测试连接 then
//  begin
//    with TFrmDBConnSet.Create(nil) do
//    try
//      //FrmSplash.FormStyle := fsNormal;
//      FrmSplash.Visible := False;
//      if ShowModal <> mrOk then
//      begin
//        Application.Terminate;
//        Exit;
//      end;
//    finally
//      //FrmSplash.FormStyle := fsStayOnTop;
//      FrmSplash.Visible := True;
//      Free;
//    end;
//  end;
//  FrmSplash.fnShowHint('正在设置数据库服务参数...');
//  DM.fn设置连接参数;

//  FrmSplash.fnShowHint('正在处理异常数据...');
//  DM.fn更新任务状态;
//  FrmSplash.fnShowHint('正在初始化主模块...');
  Application.CreateForm(TFrmMain, FrmMain);
  //  Sleep(1000);
  FrmSplash.Hide;
//  FrmSplash.Close;
//  Application.MainFormOnTaskbar := True;
  Application.Run;

end.
