unit uFrmOrderItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, cxTextEdit, cxMemo, Vcl.ExtCtrls, Vcl.StdCtrls, uJsonClass, uTaskManager, uGlobal;

type
  TFrmOrderItem = class(TForm)
    Panel1: TPanel;
    cxMemo1: TcxMemo;
    btnOk: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmOrderItem: TFrmOrderItem;

function fnShowOrderItem(AConnItem: TConnItem): Boolean;

implementation

{$R *.dfm}

function fnShowOrderItem(AConnItem: TConnItem): Boolean;
var
  F: TFrmOrderItem;
  vRoleItem: TRoleItem;
  function fnGet订单类型(ACmdType: TTaskType): string;
  begin
    Result := '';
    case ACmdType of
      tt发货: Result := '发货';
      tt分仓: Result := '分仓';
      tt检库: Result := '检库';
      tt邮件: Result := '邮件';
    end;
  end;
begin
  Result := True;
  if AConnItem.OrderItem = nil then Exit;
  F := TFrmOrderItem.Create(Application);
  try
    F.cxMemo1.Lines.Clear;
    F.cxMemo1.Lines.Add(Format('订单类型: %s', [fnGet订单类型(TTaskType(AConnItem.OrderItem.taskType))]));

    F.cxMemo1.Lines.Add(Format('组 标 识: %s', [AConnItem.GroupName]));
    F.cxMemo1.Lines.Add(Format('订单编号: %s', [AConnItem.OrderItem.orderNo]));
    F.cxMemo1.Lines.Add(Format('大    区: %s', [AConnItem.OrderItem.GameArea]));
    F.cxMemo1.Lines.Add(Format('服    务: %s', [AConnItem.OrderItem.GameSvr]));
    for vRoleItem in AConnItem.OrderItem.roles do
    begin
      if AConnItem.OrderItem.taskType = Integer(tt分仓) then
      begin
        if vRoleItem.isMain then
          F.cxMemo1.Lines.Add('转入转出: 转出')
        else
          F.cxMemo1.Lines.Add('转入转出: 转入');
      end;
      F.cxMemo1.Lines.Add(Format('订 单 ID: %d', [vRoleItem.rowId]));
      F.cxMemo1.Lines.Add(Format('游戏账号: %s', [vRoleItem.Account]));
      F.cxMemo1.Lines.Add(Format('游戏角色: %s', [vRoleItem.Role]));
      F.cxMemo1.Lines.Add(Format('库    存: %d', [vRoleItem.stock]));
      F.cxMemo1.Lines.Add(Format('对方角色: %s', [vRoleItem.receiptRole]));
      F.cxMemo1.Lines.Add(Format('对方等级: %d', [vRoleItem.receiptLevel]));
      F.cxMemo1.Lines.Add(Format('数    量: %d', [vRoleItem.sendNum]));
      F.cxMemo1.Lines.Add(Format('订单状态: %d', [Integer(vRoleItem.taskState)]));
      AddLogMsg('//-------------------------------------------------------------------', []);
    end;
    F.ShowModal;
  finally
    FreeAndNil(F);
  end;
end;

end.
