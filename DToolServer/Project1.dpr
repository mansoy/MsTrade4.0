program Project1;

uses
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  Vcl.Forms,
  uDToolServer in 'uDToolServer.pas',
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uFrmOrderItem in 'uFrmOrderItem.pas' {FrmOrderItem},
  uFrmParamSet in 'uFrmParamSet.pas' {FrmParamSet},
  uFrmSplash in 'uFrmSplash.pas' {FrmSplash},
  uFrmUpdateDataBase in 'uFrmUpdateDataBase.pas' {FrmUpdateDataBase},
  uTaskManager in 'uTaskManager.pas',
  Unit1 in 'Unit1.pas' {Form1},
  HPSocketSDKUnit in '..\Comm\HPSocketSDKUnit.pas',
  SuperObject in '..\Comm\SuperObject.pas',
  uCommand in '..\Comm\uCommand.pas',
  uGlobal in '..\Comm\uGlobal.pas',
  uJsonClass in '..\Comm\uJsonClass.pas',
  ManSoy.Encode in '..\Global\ManSoy.Encode.pas',
  ManSoy.Global in '..\Global\ManSoy.Global.pas',
  ManSoy.MsgBox in '..\Global\ManSoy.MsgBox.pas',
  uLogger in '..\Comm\uLogger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmParamSet, FrmParamSet);
  Application.Run;
end.
