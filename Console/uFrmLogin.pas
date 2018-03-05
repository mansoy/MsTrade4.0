unit uFrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFrmLogin = class(TForm)
    GroupBox1: TGroupBox;
    edtUserName: TEdit;
    edtPassWord: TEdit;
    btnLogin: TButton;
    btnExit: TButton;
    Label1: TLabel;
    Label2: TLabel;
    btnDBConnSet: TButton;
    chkRemPwd: TCheckBox;
    chkAutoLogin: TCheckBox;
    Bevel1: TBevel;
    procedure btnLoginClick(Sender: TObject);
    procedure edtPassWordKeyPress(Sender: TObject; var Key: Char);
    procedure btnDBConnSetClick(Sender: TObject);
    procedure chkAutoLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Data2UI;
    procedure UI2Data;
    function SaveParam: Boolean;
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

procedure TFrmLogin.btnDBConnSetClick(Sender: TObject);
begin
//  if uFrmDBConnSet.OpenDBConnSet(Self) then
//  begin
//
//  end;
end;

procedure TFrmLogin.btnLoginClick(Sender: TObject);
begin
  UI2Data;
  if not SaveParam then Exit;
  Self.ModalResult := mrOk;
end;

procedure TFrmLogin.chkAutoLoginClick(Sender: TObject);
begin
  if chkAutoLogin.Checked then chkRemPwd.Checked := True;
end;

procedure TFrmLogin.Data2UI;
begin
//  edtUserName.Text := ParamSet.UserInfo.uiUserName;
//  if ParamSet.UserInfo.uiRemPwd then begin
//    edtPassWord.Text := ParamSet.UserInfo.uiPassWord;
//  end;
//  chkRemPwd.Checked     := ParamSet.UserInfo.uiRemPwd;
//  chkAutoLogin.Checked  := ParamSet.UserInfo.uiAutoLogin;
//
//  ParamSet.UserInfo.uiUserID := 1001;
//  ParamSet.UserInfo.uiUserName := '≤‚ ‘”√ªß';
end;

procedure TFrmLogin.UI2Data;
begin
//  ParamSet.UserInfo.uiUserName  := Trim(edtUserName.Text);
//  ParamSet.UserInfo.uiPassWord  := Trim(edtPassWord.Text);
//  ParamSet.UserInfo.uiRemPwd    := chkRemPwd.Checked;
//  ParamSet.UserInfo.uiAutoLogin := chkAutoLogin.Checked;
end;

procedure TFrmLogin.edtPassWordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then btnLogin.Click;  
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  Data2UI;
end;

function TFrmLogin.SaveParam: Boolean;
//var
//  iniFile: TMSIniFile;
begin
//  Result := False;
//  iniFile := TMSIniFile.Create(uSharedInfo.SysCfg);
//  try
//    iniFile.WriteStruct('’À∫≈', '’À∫≈', @ParamSet.UserInfo, SizeOf(ParamSet.UserInfo));
//    Result := True;
//  finally
//    FreeAndNil(iniFile);
//  end;
end;

end.
