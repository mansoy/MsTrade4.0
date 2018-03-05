unit uFrmUpdateDataBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB,
  cxDBData, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxEditRepositoryItems, cxGridBandedTableView, cxSpinEdit;

type
  TFrmUpdateDataBase = class(TForm)
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    edtOrderNo: TEdit;
    Label1: TLabel;
    btnQuery: TButton;
    btnPost: TButton;
    LvFH: TcxGridLevel;
    cxGrid1: TcxGrid;
    LvFK: TcxGridLevel;
    LvPK: TcxGridLevel;
    cxEditRepository1: TcxEditRepository;
    cxEditRepository1ImageComboBoxItem1: TcxEditRepositoryImageComboBoxItem;
    TvFH: TcxGridBandedTableView;
    TvFHRowId: TcxGridBandedColumn;
    TvFHOrderNo: TcxGridBandedColumn;
    TvFHAccount: TcxGridBandedColumn;
    TvFHRoleName: TcxGridBandedColumn;
    TvFHSaleNum: TcxGridBandedColumn;
    TvFHKcNum: TcxGridBandedColumn;
    TvFHSyNum: TcxGridBandedColumn;
    TvFHState: TcxGridBandedColumn;
    TvFHCatchReason: TcxGridBandedColumn;
    TvFHDBItem: TcxGridBandedColumn;
    TvFC: TcxGridBandedTableView;
    TvFcRowId: TcxGridBandedColumn;
    TvFcOrderNo: TcxGridBandedColumn;
    TvFcGroupNo: TcxGridBandedColumn;
    TvFcOutAccount: TcxGridBandedColumn;
    TvFcOutRoleName: TcxGridBandedColumn;
    TvFcOutRoleKc: TcxGridBandedColumn;
    TvFcOutSyNum: TcxGridBandedColumn;
    TvFcInAccount: TcxGridBandedColumn;
    TvFcInRoleName: TcxGridBandedColumn;
    TvFcDBItem: TcxGridBandedColumn;
    TvFcInRoleKc: TcxGridBandedColumn;
    TvFcInSyNum: TcxGridBandedColumn;
    TvFcOutNum: TcxGridBandedColumn;
    TvFcOrderState: TcxGridBandedColumn;
    TvFcCatchReason: TcxGridBandedColumn;
    procedure btnQueryClick(Sender: TObject);
    procedure btnPostClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function fnShowData(ATaskType: Integer = 0): Boolean;
  public
    { Public declarations }
  end;

var
  FrmUpdateDataBase: TFrmUpdateDataBase;

implementation

uses
  ManSoy.MsgBox,
  ManSoy.Encode,
  uGlobal,
  uJsonClass,
  uCommand,
  IdHTTP
  ;

{$R *.dfm}

procedure TFrmUpdateDataBase.btnPostClick(Sender: TObject);
  function fnManualSetState(AGroupName: string; AOrderNo: string; ATaksType: Integer; AIsMain: Boolean; ARowId: Integer; ARoleId: Integer; AState: Integer; AStore: Integer; AReason: string): Boolean;
  var vStateItem: TStatusItem;
  begin
    Result := False;
    try
      vStateItem := TStatusItem.Create;
      vStateItem.groupName := AGroupName;
      vStateItem.rowId := ARowId;
      vStateItem.orderNo := AOrderNo;
      vStateItem.taskType := ATaksType;
      vStateItem.roleId := ARoleId;
      vStateItem.state := AState;
      vStateItem.isMain := AIsMain;
      if AReason = '' then
        vStateItem.reason := ''
      else
        vStateItem.reason := ManSoy.Encode.StrToBase64(AReason);
      vStateItem.stock := AStore;
      uCommand.PostState(vStateItem, GConsoleSet.StateInterface);
    finally
      FreeAndNil(vStateItem);
    end;
  end;

var
  I: Integer;
  iTaskType: Integer;
  vDBItem: TDBItem;
  vFcDBItem: TFcDBItem;
  iSyNum, iState: Integer;
  sReason: string;
begin
{-----------------------------
注意事项：
  1、如果订单状态已经完结， 则不能改成其他状态
  2、不能改成就绪状态（10）
-----------------------------}
  try
    iTaskType := RadioGroup1.ItemIndex;
    if iTaskType = 0 then
    begin
      if TvFH.DataController.RecordCount = 0 then Exit;
      for I := 0 to TvFH.DataController.RecordCount - 1 do
      begin
        vDBItem := TDBItem(DWORD(TvFH.DataController.Values[I, TvFHDBItem.Index]));
        if vDBItem = nil then Continue;
        if vDBItem.saleState in [55, 50, 0] then Continue;
        iSyNum := TvFH.DataController.Values[I, TvFHSyNum.Index];
        iState := TvFH.DataController.Values[I, TvFHState.Index];
        if (iSyNum = vDBItem.syNum) and (iState = vDBItem.saleState) then Continue;
        if iState = 10 then Continue;
        vDBItem.saleState := iState;
        vDBItem.syNum := iSyNum;
        sReason := TvFH.DataController.Values[I, TvFHCatchReason.Index];
        if (iState = 55) and (sReason = '') then
        begin
          vDBItem.catchReason := '人为置异常';
        end;
        fnManualSetState('', vDBItem.orderNo, RadioGroup1.ItemIndex, False, vDBItem.rowId, vDBItem.roleId, vDBItem.saleState, vDBItem.syNum, vDBItem.catchReason);
      end;
    end else if iTaskType = 1 then
    begin
      if TvFC.DataController.RecordCount = 0 then Exit;
      for I := 0 to TvFC.DataController.RecordCount - 1 do
      begin
        vFcDBItem := TFCDBItem(DWORD(TvFC.DataController.Values[I, TvFCDBItem.Index]));
        if vFcDBItem = nil then Continue;
        if vFcDBItem.orderState in [55, 50, 0] then Continue;

        iState := TvFC.DataController.Values[I, TvFcOrderState.Index];
        if iState = vFcDBItem.orderState then Continue;
        if iState = 10 then Continue;
        vFcDBItem.orderState := iState;
        sReason := TvFC.DataController.Values[I, TvFCCatchReason.Index];
        if ((iState = 55) or (iState = 50)) and (sReason = '') then
        begin
          vFcDBItem.catchReason := '人为置异常';
        end;

        iSyNum := TvFC.DataController.Values[I, TvFcInSyNum.Index];
        if (iSyNum <> vFcDBItem.inSyNum) then
        begin
          vFcDBItem.inSyNum := iSyNum;
        end;

        fnManualSetState(
          '',
          vFcDBItem.orderNo,
          iTaskType,
          False,
          vFcDBItem.rowId,
          vFcDBItem.inRoleId,
          vFcDBItem.orderState,
          vFcDBItem.inSyNum,
          vFcDBItem.catchReason
          );

        iSyNum := TvFC.DataController.Values[I, TvFcOutSyNum.Index];
        if (iSyNum <> vFcDBItem.outSyNum) then
        begin
          vFcDBItem.outSyNum := iSyNum;
          fnManualSetState(
            '',
            vFcDBItem.orderNo,
            iTaskType,
            True,
            vFcDBItem.rowId,
            vFcDBItem.outRoleId,
            vFcDBItem.orderState,
            vFcDBItem.outSyNum,
            vFcDBItem.catchReason
            );
        end;
      end;
    end;
    ManSoy.MsgBox.InfoMsg(Self.Handle, '数据保存成功', []);
    fnShowData(iTaskType);
  except on E: Exception do
    ManSoy.MsgBox.WarnMsg(Self.Handle, '提交数据失败,异常原因'#13'%s', [E.Message]);
  end;
end;

procedure TFrmUpdateDataBase.btnQueryClick(Sender: TObject);
var
  vTaskType: Integer;
  vHttp: TIdHttp;
  sRet: string;
  vOrders: TArray<TDBItem>;
  vDBItem: TDBItem;
  vFcOrders: TArray<TFcDBItem>;
  vFcDBItem: TFcDBItem;
begin
  try
    if Trim(edtOrderNo.Text) = '' then Exit;

    vTaskType := RadioGroup1.ItemIndex;
    if vTaskType = -1 then
    begin
      ManSoy.MsgBox.WarnMsg(Self.Handle, '请选择任务类型', []);
      Exit;
    end;

    vHttp := TIdHTTP.Create(nil);
    try
      if GConsoleSet.GetOrderInterfac = '' then Exit;
      sRet := vHttp.Get(Format(GConsoleSet.GetOrderInterfac, [GConsoleSet.ConsoleID, Trim(edtOrderNo.Text), vTaskType]));

      if sRet = '' then Exit;
    if sRet = '[]' then Exit;
    if sRet = '-1' then Exit;

    if vTaskType = 0 then
    begin
      TvFH.DataController.RecordCount := 0;
      if not TSerizalizes.AsType<TArray<TDBItem>>(sRet, vOrders) then Exit;
      for vDBItem in vOrders do
      begin
        TvFH.DataController.RecordCount := TvFH.DataController.RecordCount + 1;
        //ShowMessageFmt('%d', [DWORD(vDBItem)]);
        TvFH.DataController.Values[TvFH.DataController.RecordCount - 1, TvFHDBItem.Index] := DWORD(vDBItem);
      end;
      end else if vTaskType = 1 then
      begin
        TvFC.DataController.RecordCount := 0;
        if not TSerizalizes.AsType<TArray<TFcDBItem>>(sRet, vFcOrders) then Exit;
        for vFcDBItem in vFcOrders do
        begin
          TvFC.DataController.RecordCount := TvFC.DataController.RecordCount + 1;
          TvFC.DataController.Values[TvFC.DataController.RecordCount - 1, TvFcDBItem.Index] := DWORD(vFcDBItem);
        end;
      end;

    finally
      vHttp.Disconnect;
      FreeAndNil(vHttp);
    end;


    fnShowData(vTaskType);
  except on E: Exception do
    ManSoy.MsgBox.WarnMsg(Self.Handle, '查找数据失败,异常原因'#13'%s', [E.Message]);
  end;
end;

function TFrmUpdateDataBase.fnShowData(ATaskType: Integer): Boolean;
var
  vDBItem: TDBItem;
  vFcDBItem: TFcDBItem;
  I: Integer;
begin
  //--
  if ATaskType = 0 then
  begin
    if TvFH.DataController.RecordCount = 0 then Exit;
    TvFH.DataController.BeginFullUpdate;
    try
      for I := 0 to TvFH.DataController.RecordCount - 1 do
      begin
        vDBItem := TDBItem(DWORD(TvFH.DataController.Values[I, TvFHDBItem.Index]));
        if vDBItem = nil then Continue;
        TvFH.DataController.Values[I, TvFHRowId.Index] := vDBItem.rowId;
        TvFH.DataController.Values[I, TvFHOrderNo.Index] := vDBItem.orderNo;
        TvFH.DataController.Values[I, TvFHAccount.Index] := vDBItem.account;
        TvFH.DataController.Values[I, TvFHRoleName.Index] := vDBItem.roleName;
        TvFH.DataController.Values[I, TvFHSaleNum.Index] := vDBItem.saleNum;
        TvFH.DataController.Values[I, TvFHKcNum.Index] := vDBItem.kcNum;
        TvFH.DataController.Values[I, TvFHSyNum.Index] := vDBItem.syNum;
        TvFH.DataController.Values[I, TvFHState.Index] := vDBItem.saleState;
        TvFH.DataController.Values[I, TvFHCatchReason.Index] := vDBItem.catchReason;
      end;
    finally
      TvFH.DataController.EndFullUpdate;
    end;
  end else if ATaskType = 1 then
  begin
    if TvFC.DataController.RecordCount = 0 then Exit;
    TvFC.DataController.BeginFullUpdate;
    try
      for I := 0 to TvFC.DataController.RecordCount - 1 do
      begin
        vFcDBItem := TFcDBItem(DWORD(TvFC.DataController.Values[I, TvFcDBItem.Index]));
        if vFcDBItem = nil then Continue;
        TvFC.DataController.Values[I, TvFcRowId.Index] := vFcDBItem.rowId;
        TvFC.DataController.Values[I, TvFcOrderNo.Index] := vFcDBItem.orderNo;
        TvFC.DataController.Values[I, TvFcGroupNo.Index] := vFcDBItem.groupNo;
        TvFC.DataController.Values[I, TvFcOutAccount.Index] := vFcDBItem.outAccount;
        TvFC.DataController.Values[I, TvFcOutRoleName.Index] := vFcDBItem.OutRoleName;
        TvFC.DataController.Values[I, TvFcOutRoleKc.Index] := vFcDBItem.OutRoleKc;
        TvFC.DataController.Values[I, TvFcOutSyNum.Index] := vFcDBItem.OutSyNum;
        TvFC.DataController.Values[I, TvFcInAccount.Index] := vFcDBItem.inAccount;
        TvFC.DataController.Values[I, TvFcInRoleName.Index] := vFcDBItem.inRoleName;
        TvFC.DataController.Values[I, TvFcInRoleKc.Index] := vFcDBItem.InRoleKc;
        TvFC.DataController.Values[I, TvFcInSyNum.Index] := vFcDBItem.InSyNum;
        TvFC.DataController.Values[I, TvFcOutNum.Index] := vFcDBItem.OutNum;
        TvFC.DataController.Values[I, TvFcOrderState.Index] := vFcDBItem.OrderState;
        TvFC.DataController.Values[I, TvFcCatchReason.Index] := vFcDBItem.catchReason;
      end;
    finally
      TvFC.DataController.EndFullUpdate;
    end;
  end;
end;

procedure TFrmUpdateDataBase.FormCreate(Sender: TObject);
begin
  {$IFNDEF _MS_DEBUG}
  TvFHDBItem.Visible := False;
  {$ENDIF}
end;

procedure TFrmUpdateDataBase.FormShow(Sender: TObject);
begin
  cxGrid1.RootLevelOptions.DetailTabsPosition := dtpNone;
  RadioGroup1Click(nil);
end;

procedure TFrmUpdateDataBase.RadioGroup1Click(Sender: TObject);
begin
  LvFH.Visible := RadioGroup1.ItemIndex = 0;
  LvFK.Visible := RadioGroup1.ItemIndex = 1;
  LvPK.Visible := RadioGroup1.ItemIndex = 2;
end;

end.
