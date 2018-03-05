unit uFrmParamSet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxPCdxBarPopupMenu, cxPC, Vcl.ExtCtrls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxSpinEdit
  , ManSoy.MsgBox
  , uGlobal
  , uJsonClass, cxDropDownEdit
  ;

type
  TFrmParamSet = class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    btnSave: TButton;
    btnCancel: TButton;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    edtMaxTaskTimes: TcxSpinEdit;
    edtCurMaxTaskCount: TcxSpinEdit;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    chk自动分批: TCheckBox;
    chk缺料则暂停: TCheckBox;
    edt分仓附加: TcxSpinEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    edtTaskLink: TcxTextEdit;
    edtStateLink: TcxTextEdit;
    Label6: TLabel;
    edtLogLink: TcxTextEdit;
    Label7: TLabel;
    edt仓库浮动: TcxSpinEdit;
    Label8: TLabel;
    edtImgLink: TcxTextEdit;
    cbConsoleID: TcxComboBox;
    Label9: TLabel;
    Label10: TLabel;
    edtSetExceptionLink: TcxTextEdit;
    Label11: TLabel;
    edtGetOrder: TcxTextEdit;
    Label12: TLabel;
    edtCarryLink: TcxTextEdit;
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FShowAll: Boolean;
    { Private declarations }
    procedure Data2UI;
    procedure UI2Data;
  public
    { Public declarations }
    function SaveParam: Boolean;
  end;

var
  FrmParamSet: TFrmParamSet;

  function OpenParamSet(AOwner: TComponent): Boolean;

implementation

{$R *.dfm}

function OpenParamSet(AOwner: TComponent): Boolean;
var
  F: TFrmParamSet;
begin
  F := TFrmParamSet.Create(AOwner);
  try
    Result := F.ShowModal = mrOk;
  finally
    FreeAndNil(F);
  end;
end;

procedure TFrmParamSet.FormCreate(Sender: TObject);
begin
  Data2UI;
end;

function TFrmParamSet.SaveParam: Boolean;
var
  sCfg: string;
  vLst: TStrings;
begin
  sCfg := ExtractFilePath(ParamStr(0)) + 'Config\SvrSysCfg.cfg';
  vLst := TStringList.Create;
  try
    vLst.Text := TSerizalizes.AsJson<TConsoleSet>(GConsoleSet);
    vLst.SaveToFile(sCfg);
  finally
    FreeAndNil(vLst);
  end;
end;

procedure TFrmParamSet.btnSaveClick(Sender: TObject);
begin
  UI2Data;
  //----------------------------------------------------
  SaveParam;
  Self.ModalResult := mrOk;
end;

procedure TFrmParamSet.Data2UI;
begin
  //--任务分配
  cbConsoleID.Text          := GConsoleSet.ConsoleID;
  chk缺料则暂停.Checked     := GConsoleSet.LackMaterialPause;
  chk自动分批.Checked       := GConsoleSet.AutoBatch;
  edt分仓附加.Value         := GConsoleSet.StockAdditional;
  edt仓库浮动.Value         := GConsoleSet.StockFloating;
  //--连接设置
  edtTaskLink.Text          := GConsoleSet.TaskInterface;
  edtStateLink.Text         := GConsoleSet.StateInterface;
  edtLogLink.Text           := GConsoleSet.LogInterface;
  edtImgLink.Text           := GConsoleSet.ImgInterface;
  edtCarryLink.Text         := GConsoleSet.CarryInterface;
  edtSetExceptionLink.Text  := GConsoleSet.SetExceptionInterface;
  edtGetOrder.Text          := GConsoleSet.GetOrderInterfac;
  //--其他设置
  edtMaxTaskTimes.Value     := GConsoleSet.TaskTimes;
  edtCurMaxTaskCount.Value  := GConsoleSet.MaxTaskNum;
end;

procedure TFrmParamSet.UI2Data;
begin
  //--任务分配
  GConsoleSet.ConsoleID         := cbConsoleID.Text;
  GConsoleSet.LackMaterialPause := chk缺料则暂停.Checked;
  GConsoleSet.AutoBatch         := chk自动分批.Checked;
  GConsoleSet.StockAdditional   := edt分仓附加.Value;
  GConsoleSet.StockFloating     := edt仓库浮动.Value;
  //--连接设置
  GConsoleSet.TaskInterface     := edtTaskLink.Text;
  GConsoleSet.StateInterface    := edtStateLink.Text;
  GConsoleSet.LogInterface      := edtLogLink.Text;
  GConsoleSet.ImgInterface      := edtImgLink.Text;
  GConsoleSet.CarryInterface    := edtCarryLink.Text;
  GConsoleSet.SetExceptionInterface := edtSetExceptionLink.Text;
  GConsoleSet.GetOrderInterfac  := edtGetOrder.Text;
  //--其他设置
  GConsoleSet.TaskTimes         := edtMaxTaskTimes.Value;
  GConsoleSet.MaxTaskNum        := edtCurMaxTaskCount.Value;
end;

end.
