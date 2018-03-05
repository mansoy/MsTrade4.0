unit uDM;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  uJsonClass
  ;

type
  TDM = class(TDataModule)
    cdsConn: TClientDataSet;
    dsConn: TDataSource;
    cdsConnDetail: TClientDataSet;
    dsConnDetail: TDataSource;
    cdsOrder: TClientDataSet;
    dsOrder: TDataSource;
    cdsOrderDetail: TClientDataSet;
    dsOrderDetail: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function DispatchOrder: Boolean;
    function EndOrder(AConnID: DWORD; AStatusItem: TStatusItem): Boolean;
    function LogOrder(AConnID: DWORD; ALogItem: TLogItem): Boolean;
    function AddOrder(AOrderJson: string): Boolean;
    function SuspendOrder(AConnID: DWORD): Boolean;
    function GetOrder(AConnID: DWORD): string;
    function AddSendMachine(AConnID: DWORD; AGroupName: string): Boolean;
    function DelSendMachine(AConnID: DWORD): Boolean;
  end;

var
  DM: TDM;

implementation

uses
  System.Variants,

  uGlobal;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  cdsConn.Close;
  cdsConn.CreateDataSet;

  cdsOrder.Close;
  cdsOrder.CreateDataSet;

  cdsOrderDetail.Close;
  cdsOrderDetail.CreateDataSet;

  cdsConnDetail.Close;
  cdsConnDetail.CreateDataSet;
end;

function TDM.DelSendMachine(AConnID: DWORD): Boolean;
var
  dwConnID: Integer;
  bFinished: Boolean;
begin
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      if not cdsConnDetail.Locate('ConnID', VarArrayOf([AConnID]), []) then Exit;
      cdsConn.Delete;
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

function TDM.AddSendMachine(AConnID: DWORD; AGroupName: string): Boolean;
var
  dwConnID: Integer;
  bFinished: Boolean;
begin
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      cdsConn.DisableControls;
      if cdsConn.Locate('ConnID;GroupName', VarArrayOf([AConnID, AGroupName]), []) then Exit;
      cdsConn.Append;
      cdsConn['ConnID'] := AConnID;
      cdsConn['GroupName'] := AGroupName;
      cdsConn['OrderNo'] := '';
      cdsConn['GameArea'] := '';
      cdsConn['GameSvr'] := '';
      cdsConn['Account'] := '';

      cdsConn['SendMachineState'] := Integer(sms空闲);
      cdsConn['TaskState'] := tsNormal;
      cdsConn['LogText'] := '';
      cdsConn['Interval'] := 0;
      cdsConn.Post;
      cdsConn.EnableControls;
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

function TDM.AddOrder(AOrderJson: string): Boolean;
var
  iPos: Integer;
  Orders: TArray<TOrderItem>;
  vRole: TRoleItem;
  I: Integer;
  bm: TBookmark;
begin
  try
    if AOrderJson = '' then Exit;
    if not TSerizalizes.AsType<TArray<TOrderItem>>(AOrderJson, Orders) then Exit;
    if Length(Orders) = 0 then Exit;
    EnterCriticalSection(CS_OP_CDS);
    try
      DM.cdsOrder.DisableControls;
      DM.cdsOrderDetail.DisableControls;
      for I := Low(Orders) to High(Orders) do
      begin
        if Length(Orders[i].Roles) = 0 then Continue;
        bm := cdsOrder.GetBookmark;
        if DM.cdsOrder.Locate('OrderNo;Account', VarArrayOf([Orders[i].OrderNo, Orders[i].Account]), []) then Continue;
        //if DM.cdsConn.Locate('OrderNo;Account', VarArrayOf([Orders[i].OrderNo, Orders[i].Account]), []) then Continue;

        DM.cdsOrder.Append;
        DM.cdsOrder['TaskType'] := Orders[i].TaskType;
        DM.cdsOrder['OrderNo'] := Orders[i].OrderNo;
        DM.cdsOrder['GameArea'] := Orders[i].GameArea;
        DM.cdsOrder['GameSvr'] := Orders[i].GameSvr;
        DM.cdsOrder['Account'] := Orders[i].Account;
        DM.cdsOrder['PassWord'] := Orders[i].PassWord;
        DM.cdsOrder['ConsoleID'] := Orders[i].ConsoleId;
        DM.cdsOrder['ReceiptRole'] := Orders[i].ReceiptRole;
        DM.cdsOrder['ReceiptRoleLevel'] := Orders[i].receiptLevel;
        DM.cdsOrder['CheckLevel'] := Orders[i].CheckLevel;
        DM.cdsOrder['SafeWay'] := Orders[i].SafetyWay;
        DM.cdsOrder['SaleNum'] := Orders[i].SaleNum;
        DM.cdsOrder['Json'] := TSerizalizes.AsJSON<TOrderItem>(Orders[i]);
        DM.cdsOrder['IsDoing'] := False;
        DM.cdsOrder.Post;
        //---
        for vRole in Orders[i].Roles do
        begin
          DM.cdsOrderDetail.Append;
          DM.cdsOrderDetail['Account'] := Orders[i].account;
          DM.cdsOrderDetail['RowID'] := vRole.RowId;
          DM.cdsOrderDetail['IsMain'] := vRole.IsMain;
          DM.cdsOrderDetail['RoleID'] := vRole.RoleId;
          DM.cdsOrderDetail['RoleName'] := vRole.Role;
          DM.cdsOrderDetail['Stock'] := vRole.Stock;
          DM.cdsOrderDetail['SendNum'] := vRole.SendNum;
          DM.cdsOrderDetail['EachNum'] := vRole.EachNum;
          DM.cdsOrderDetail.Post;
        end;
      end;
    finally
      cdsOrder.GotoBookmark(bm);
      cdsOrder.FreeBookmark(bm);
      cdsOrder.EnableControls;
      cdsOrderDetail.EnableControls;
      LeaveCriticalSection(CS_OP_CDS);
    end;
  except
    AddLogMsg('订单数据处理错误...', [], True);
  end;
end;

function TDM.DispatchOrder: Boolean;
var
  dwConnID: Integer;
  sOrderNo, sAccount, sJson: string;
  vOrderItem: TOrderItem;
  vRoleItem: TRoleItem;
  bm: TBookmark;
begin
  if DM.cdsOrder.RecordCount = 0 then Exit;
  EnterCriticalSection(CS_OP_CDS);
  try
    cdsConn.DisableControls;
    cdsConnDetail.DisableControls;
    try
      bm := cdsConn.GetBookmark;
      if not DM.cdsConn.Locate('SendMachineState', Integer(sms空闲), []) then Exit;
      dwConnID := DM.cdsConn.FieldByName('ConnID').AsInteger;
      DM.cdsOrder.First;
      while not cdsOrder.Eof do
      begin
        if not cdsOrder['IsDoing'] then
        begin
          sJson := DM.cdsOrder.FieldByName('Json').AsString;
          if sJson = '' then Exit;
          if not TSerizalizes.AsType<TOrderItem>(sJson, vOrderItem) then Exit;
          if vOrderItem = nil then Exit;
          if Length(vOrderItem.roles) = 0 then Exit;

          DM.cdsConn.Edit;
          DM.cdsConn['OrderNo'] := vOrderItem.orderNo;
          DM.cdsConn['GameArea'] := vOrderItem.gameArea;
          DM.cdsConn['GameSvr'] := vOrderItem.gameSvr;
          DM.cdsConn['Account'] := vOrderItem.account;
          DM.cdsConn['Json']    := sJson;

          DM.cdsConn['SendMachineState'] := sms繁忙;
          DM.cdsConn['TaskState'] := tsNormal;
          DM.cdsConn['LogText'] := '';
          DM.cdsConn['Interval'] := GetTickCount;
          DM.cdsConn.Post;

          for vRoleItem in vOrderItem.roles do
          begin
            cdsConnDetail.Append;
            cdsConnDetail['ConnID'] := dwConnID;
            cdsConnDetail['RowID'] := vRoleItem.rowId;
            cdsConnDetail['Role'] := vRoleItem.role;
            cdsConnDetail['Num'] := vRoleItem.sendNum;
            cdsConnDetail['Stock'] := vRoleItem.stock;
            cdsConnDetail['LogText'] := '';
            cdsConnDetail['State'] := 0;
            cdsConnDetail.Post;
          end;
          //--分配完成后删除订单
          cdsOrder.Edit;
          cdsOrder['IsDoing'] := True;
          cdsOrder.Post;
          Break;
        end;
        cdsOrder.Next;
      end;

    except
      AddLogMsg('分配订单处理错误...', [], True);
    end;

  finally
    cdsConn.GotoBookmark(bm);
    cdsConn.FreeBookmark(bm);
    cdsConnDetail.EnableControls;
    cdsConn.EnableControls;
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

//--订单处理完成后， 更新发货机的显示
function TDM.EndOrder(AConnID: DWORD; AStatusItem: TStatusItem): Boolean;
var
  dwConnID: Integer;
  bFinished: Boolean;
  sOrderNo, sAccount: string;
begin
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      if not cdsConnDetail.Locate('RowID', AStatusItem.rowId, []) then Exit;
      cdsConnDetail['State'] := AStatusItem.state;

      cdsConnDetail.First;
      bFinished := True;
      while not cdsConnDetail.Eof do
      begin
        if cdsConnDetail['ConnID'] = AConnID then
        begin
          bFinished := cdsConnDetail['State'] >= 50;
        end;
        if not bFinished then Break;
        cdsConn.Next;
      end;

      if not bFinished then Exit;

      while True do
      begin
        if not cdsConnDetail.Locate('ConnID', AConnID, []) then
        begin
          Break;
        end;
        cdsConnDetail.Delete;
      end;

      if not cdsConn.Locate('ConnID', AConnID, []) then Exit;

      //--删除订单里边的数据
      sOrderNo := cdsConn['OrderNo'];
      sAccount := cdsConn['Account'];

      cdsOrderDetail.First;
      while True do
      begin
        if not cdsOrderDetail.Locate('Account', sAccount, []) then
        begin
          Break;
        end;
        cdsOrderDetail.Delete;
      end;
      cdsOrder.Delete;

      DM.cdsConn.Edit;
      DM.cdsConn['OrderNo'] := '';
      DM.cdsConn['GameArea'] := '';
      DM.cdsConn['GameSvr'] := '';
      DM.cdsConn['Account'] := '';

      DM.cdsConn['SendMachineState'] := sms空闲;
      DM.cdsConn['TaskState'] := tsNormal;
      DM.cdsConn['LogText'] := '';
      DM.cdsConn['Interval'] := 0;
      DM.cdsConn['Json'] := '';
      DM.cdsConn.Post;
    except
    end;

  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

function TDM.GetOrder(AConnID: DWORD): string;
var
  dwConnID: Integer;
  bFinished: Boolean;
begin
  Result := '';
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      if not cdsConn.Locate('ConnID', AConnID, []) then Exit;
      Result := cdsConn['Json'];
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

//--订单处理完成后， 更新发货机的显示
function TDM.LogOrder(AConnID: DWORD; ALogItem: TLogItem): Boolean;
var
  dwConnID: Integer;
  bFinished: Boolean;
begin
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      if not cdsConnDetail.Locate('RowID', ALogItem.DetailNo, []) then Exit;
      cdsConnDetail['LogText'] := ALogItem.content;

      if not cdsConnDetail.Locate('ConnID', AConnID, []) then Exit;
      DM.cdsConn.Edit;
      DM.cdsConn['LogText'] := ALogItem.content;
      DM.cdsConn.Post;
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

function TDM.SuspendOrder(AConnID: DWORD): Boolean;
var
  dwConnID: Integer;
  bFinished: Boolean;
begin
  EnterCriticalSection(CS_OP_CDS);
  try
    try
      if not cdsConn.Locate('ConnID', AConnID, []) then Exit;
      DM.cdsConn.Edit;
      cdsConn['ConnID'] := tsSuspend;
      DM.cdsConn.Post;
    except
    end;
  finally
    LeaveCriticalSection(CS_OP_CDS);
  end;
end;

end.
