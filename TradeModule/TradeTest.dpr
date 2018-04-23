program TradeTest;

uses
  Vcl.Forms,
  uFrmTest in 'uFrmTest.pas' {FrmTest},
  uAutoSend in 'uAutoSend.pas',
  uFrmLogs in 'uFrmLogs.pas' {FrmLogs},
  uTradeClient in 'uTradeClient.pas',
  VerySimple.Lua.Lib in '..\Lua\VerySimple.Lua.Lib.pas',
  VerySimple.Lua in '..\Lua\VerySimple.Lua.pas',
  Dm_TLB in '..\Comm\Dm_TLB.pas',
  HideModuleUnit in '..\Comm\HideModuleUnit.pas',
  HPSocketSDKUnit in '..\Comm\HPSocketSDKUnit.pas',
  SuperObject in '..\Comm\SuperObject.pas',
  uCommand in '..\Comm\uCommand.pas',
  uCommFuns in '..\Comm\uCommFuns.pas',
  uGlobal in '..\Comm\uGlobal.pas',
  uJsonClass in '..\Comm\uJsonClass.pas',
  uLogger in '..\Comm\uLogger.pas',
  uLuaFuns in '..\Comm\uLuaFuns.pas',
  uOrderInfo in '..\Comm\uOrderInfo.pas',
  uPublic in '..\Comm\uPublic.pas',
  ManSoy.Encode in '..\Global\ManSoy.Encode.pas',
  ManSoy.Global in '..\Global\ManSoy.Global.pas',
  ManSoy.IniFiles in '..\Global\ManSoy.IniFiles.pas',
  ManSoy.MsgBox in '..\Global\ManSoy.MsgBox.pas',
  ManSoy.StrSub in '..\Global\ManSoy.StrSub.pas',
  uMsVpn in '..\Comm\uMsVpn.pas',
  uWinIO in '..\Comm\uWinIO.pas',
  VMProtectSDK in '..\Comm\VMProtectSDK.pas',
  RKUtils in '..\RKDaMa\RKUtils.pas',
  RKAPI in '..\RKDaMa\RKAPI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmTest, FrmTest);
  Application.Run;
end.
