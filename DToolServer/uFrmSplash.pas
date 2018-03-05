unit uFrmSplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, cxLabel;

type
  TFrmSplash = class(TForm)
    lblHint: TcxLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function fnShowHint(AHint: string): Boolean;
  end;

var
  FrmSplash: TFrmSplash;

implementation

{$R *.dfm}

{ TFrmSplash }

procedure TFrmSplash.FormCreate(Sender: TObject);
begin

//  Self.Caption := CON_控制台标识;
end;

function TFrmSplash.fnShowHint(AHint: string): Boolean;
begin
  Result := False;
  lblHint.Caption := AHint;
  Self.Update;
  Sleep(200);
  Result := True;
end;

end.
