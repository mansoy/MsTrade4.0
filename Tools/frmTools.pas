unit frmTools;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs
  , Winapi.GDIPAPI, Winapi.GDIPOBJ;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  sContent, sFile: string;
  iR, iG, iB: Integer;
begin
  Self.Visible := False;
  sContent := ParamStr(1);
  iR := StrToIntDef(ParamStr(2), 0);
  iG := StrToIntDef(ParamStr(3), 0);
  iB := StrToIntDef(ParamStr(4), 0);
  sFile := ParamStr(5);
  //sFile := ExtractFilePath(ParamStr(0)) + 'Bmp(W7)\' + sFile;
  CreateBmp(sContent, iR, iG, iB, sFile);
  Application.Terminate;
end;

end.
