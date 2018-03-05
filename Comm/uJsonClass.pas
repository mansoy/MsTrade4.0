unit uJsonClass;

interface

uses
  Winapi.Windows, System.SysUtils;

type
  TStatusItem = class
  private
    FGroupName: string;
    FRowId: Integer;
    FOrderNo: string;
    FTaskType: Integer;
    FRoleId: Integer;
    FState: Integer;
    FReason: string;
    FStock: Integer;
    FIsMain: Boolean;
  public
    /// <summary>
    /// 发货机标示
    /// </summary>
    property groupName: string read FGroupName write FGroupName;
    /// <summary>
    /// RowId, 子单ID
    /// </summary>
    property rowId: Integer read FRowId write FRowId;
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    /// <remarks>
    /// 是否主号
    /// </remarks>
    property isMain: Boolean read FIsMain write FIsMain;
    /// <summary>
    /// 订单编号
    /// </summary>
    property taskType: Integer read FTaskType write FTaskType;
    /// <summary>
    /// 角色ID
    /// </summary>
    property roleId: Integer read FRoleId write FRoleId;
    /// <summary>
    /// 订单状态码
    /// </summary>
    property state: Integer read FState write FState;
    /// <summary>
    /// 异常原因
    /// </summary>
    property reason: string read FReason write FReason;
    /// <summary>
    /// 当前角色的实际剩余库存
    /// </summary>
    property stock: Integer read FStock write FStock;
  end;

  TLogItem = class
  private
    FLogType: string;
    FLogLevel: string;
    FOrderNo: string;
    FDetailNo: Integer;
    FAccFlag: string;
    FIP: string;
    FContent: string;
    FGroupName: string;
  public
    /// <summary>
    /// 发货机标示
    /// </summary>
    property groupName: string read FGroupName write FGroupName;
    /// <summary>
    /// 日志类型 （任务类型 + 1 * 10）
    /// </summary>
    property logType: string read FLogType write FLogType;
    /// <summary>
    /// 日志等级 暂时没用，默认给个0
    /// </summary>
    property logLevel: string read FLogLevel write FLogLevel;
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    /// <summary>
    /// 明细号
    /// </summary>
    property detailNo: Integer read FDetailNo write FDetailNo;
    /// <summary>
    /// 账号类型， 分仓时主号为10，副号为20
    /// </summary>
    property accFlag: string read FAccFlag write FAccFlag;
    /// <summary>
    /// 发货机IP
    /// </summary>
    property ip: string read FIP write FIP;
    /// <summary>
    /// 日志内容
    /// </summary>
    property content: string read FContent write FContent;
  end;

  TRoleItem = class
  private
    FStock: Integer;
    FRowId: Integer;
    FEachNum: Integer;
    FRole: string;
    FIsMain: Boolean;
    FSendNum: Integer;
    FRoleId: Integer;
    FreStock: Integer;
    FTaskState: Integer;
    FPassWord: string;
    FAccount: string;
    FCheckLevel: Boolean;
    FReceiptRole: string;
    FReceiptGameSvr: string;
    FSafetyWay: Integer;
    FReceiptLevel: Integer;
    FLogMsg: string;
  public
    /// <summary>
    /// RowId, 子单ID
    /// </summary>
    property rowId: Integer read FRowId write FRowId;
    /// <summary>
    /// 是否分仓主号
    /// </summary>
    property isMain: Boolean read FIsMain write FIsMain;
    /// <summary>
    /// 游戏账号
    /// </summary>
    property account: string read FAccount write FAccount;
    /// <summary>
    /// 账号密码
    /// </summary>
    property passWord: string read FPassWord write FPassWord;
    /// <summary>
    /// 角色ID
    /// </summary>
    property roleID: Integer read FRoleId write FRoleId;
    /// <summary>
    /// 角色名
    /// </summary>
    property role: string read FRole write FRole;
    /// <summary>
    /// 收货角色名
    /// </summary>
    property receiptRole: string read FReceiptRole write FReceiptRole;
    /// <summary>
    /// 收货角色名区服
    /// </summary>
    property receiptGameSvr: string read FReceiptGameSvr write FReceiptGameSvr;
    /// <summary>
    /// 收货角色等级
    /// </summary>
    property receiptLevel: Integer read FReceiptLevel write FReceiptLevel;
    /// <summary>
    /// 是否校验角色等级
    /// </summary>
    property checkLevel: Boolean read FCheckLevel write FCheckLevel;
    /// <summary>
    /// 安全方式
    /// </summary>
    property safetyWay: Integer read FSafetyWay write FSafetyWay;
    /// <summary>
    /// 当前角色发货数量
    /// </summary>
    property sendNum: Integer read FSendNum write FSendNum;
    /// <summary>
    /// 分批数量
    /// </summary>
    property eachNum: Integer read FEachNum write FEachNum;
    /// <summary>
    /// 当前角色库存
    /// </summary>
    property stock: Integer read FStock write FStock;
    /// <summary>
    /// 当前角色实际库存
    /// </summary>
    property reStock: Integer read FreStock write FreStock;
    /// <summary>
    /// 任务的状态
    /// </summary>
    property taskState: Integer read FTaskState write FTaskState;
    /// <summary>
    /// 任务日志信息
    /// </summary>
    property logMsg: string read FLogMsg write FLogMsg;
  end;

  TOrderItem = class
  private
    FGameArea: string;
    FConsoleId: string;
    FGameSvr: string;
    FOrderNo: string;
    FTaskType: Integer;
    FSaleNum: Integer;
    FRoles: TArray<TRoleItem>;
    FisBusy: Boolean;
    Fkey: string;
  public
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    /// <summary>
    /// 订单编号
    /// </summary>
    property taskType: Integer read FTaskType write FTaskType;
    /// <summary>
    /// 游戏大区
    /// </summary>
    property gameArea: string read FGameArea write FGameArea;
    /// <summary>
    /// 游戏区服
    /// </summary>
    property gameSvr: string read FGameSvr write FGameSvr;
    /// <summary>
    /// 唯一值
    /// </summary>
    property key: string read Fkey write Fkey;
    /// <summary>
    /// 控制台编号
    /// </summary>
    property consoleId: string read FConsoleId write FConsoleId;
    /// <summary>
    /// 当前账号的总发货量
    /// </summary>
    property saleNum: Integer read FSaleNum write FSaleNum;
    /// <summary>
    /// 标示订单是否在处理中
    /// </summary>
    property isBusy: Boolean read FisBusy write FisBusy;
    /// <summary>
    /// 发货角色列表
    /// </summary>
    property roles: TArray<TRoleItem> read FRoles write FRoles;
  end;


  //---分仓信息-----------------------------
  TFcRoleItem = class
  private
    FStock: Integer;
    FRowId: Integer;
    FEachNum: Integer;
    FRole: string;
    FIsMain: Boolean;
    FSendNum: Integer;
    FRoleId: Integer;
    FPassWord: string;
    FAccount: string;
    FReceiptRole: string;
    FSafetyWay: Integer;
  public
    /// <summary>
    /// RowId, 子单ID
    /// </summary>
    property rowId: Integer read FRowId write FRowId;
    /// <summary>
    /// 角色ID
    /// </summary>
    property roleId: Integer read FRoleId write FRoleId;
    /// <summary>
    /// 角色名
    /// </summary>
    property role: string read FRole write FRole;
    /// <summary>
    /// 收货角色名
    /// </summary>
    property receiptRole: string read FReceiptRole write FReceiptRole;
    /// <summary>
    /// 安全方式
    /// </summary>
    property safetyWay: Integer read FSafetyWay write FSafetyWay;
    /// <summary>
    /// 当前角色发货数量
    /// </summary>
    property sendNum: Integer read FSendNum write FSendNum;
    /// <summary>
    /// 分批数量
    /// </summary>
    property eachNum: Integer read FEachNum write FEachNum;
    /// <summary>
    /// 当前角色库存
    /// </summary>
    property stock: Integer read FStock write FStock;
  end;

  TAccountItem = class
  private
    FIsMain: Boolean;
    FAccount: string;
    FPassWord: string;
    FRoles: TArray<TFcRoleItem>;
    FOrderNo: string;
    FGroupNo: string;
  public
    property isMain: Boolean read FIsMain write FIsMain default False;
    property account: string read FAccount write FAccount;
    property passWord: string read FPassWord write FPassWord;
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    property groupNo: string read FGroupNo write FGroupNo;
    property roles: TArray<TFcRoleItem> read FRoles write FRoles;
  end;

  TFcOrderItem = class
  private
    FTaskType: Integer;
    FGameArea: string;
    FGameSvr: string;
    FConsoleId: string;
    FAccounts: TArray<TAccountItem>;
  public
    /// <remarks>
    /// 任务类型
    /// </remarks>
    property taskType: Integer read FTaskType write FTaskType;
    /// <remarks>
    /// 游戏大区
    /// </remarks>
    property gameArea: string read FGameArea write FGameArea;
    /// <remarks>
    /// 游戏服务
    /// </remarks>
    property gameSvr: string read FGameSvr write FGameSvr;
    /// <remarks>
    /// 控制台标示
    /// </remarks>
    property consoleId: string read FConsoleId write FConsoleId;
    /// <remarks>
    /// 账号列表
    /// </remarks>
    property accounts: TArray<TAccountItem> read FAccounts write FAccounts;
  end;


  //---设置
  TConsoleSet = class
  private
    FLackMaterialPause: Boolean;
    FAutoBatch: Boolean;
    FMaxTaskNum: Integer;
    FTaskTimes: Integer;
    FStockFloating: Integer;
    FStockAdditional: Integer;
    FConsoleID: string;
    FLogInterface: string;
    FTaskInterface: string;
    FStateInterface: string;
    FImgInterface: string;
    FSetExceptionInterface: string;
    FGetOrderInterfac: string;
    FCarryInterface: string;
  public
    /// <summary>
    /// 控制台标示
    /// </summary>
    property ConsoleID: string read FConsoleID write FConsoleID;
    /// <summary>
    /// tp缺材料暂停
    /// </summary>
    property LackMaterialPause: Boolean read FLackMaterialPause write FLackMaterialPause;
    /// <summary>
    /// tp自动分批
    /// </summary>
    property AutoBatch: Boolean read FAutoBatch write FAutoBatch;
    /// <summary>
    /// tp分仓附加
    /// </summary>
    property StockAdditional: Integer read FStockAdditional write FStockAdditional;
    /// <summary>
    /// tp仓库浮动
    /// </summary>
    property StockFloating: Integer read FStockFloating write FStockFloating;
    /// <summary>
    /// tp任务失败尝试次数
    /// </summary>
    property TaskTimes: Integer read FTaskTimes write FTaskTimes;
    /// <summary>
    /// tp当前任务最大数
    /// </summary>
    property MaxTaskNum: Integer read FMaxTaskNum write FMaxTaskNum;
    /// <summary>
    /// 任务接口地址
    /// </summary>
    property TaskInterface: string read FTaskInterface write FTaskInterface;
    /// <summary>
    /// 任务接口地址
    /// </summary>
    property StateInterface: string read FStateInterface write FStateInterface;
    /// <summary>
    /// 任务接口地址
    /// </summary>
    property LogInterface: string read FLogInterface write FLogInterface;
    /// <summary>
    /// 图片接口地址
    /// </summary>
    property ImgInterface: string read FImgInterface write FImgInterface;
    /// <summary>
    /// 携带量接口地址
    /// </summary>
    property CarryInterface: string read FCarryInterface write FCarryInterface;
    /// <summary>
    /// 置异常接口地址
    /// </summary>
    property SetExceptionInterface: string read FSetExceptionInterface write FSetExceptionInterface;
    /// <summary>
    /// 置异常接口地址
    /// </summary>
    property GetOrderInterfac: string read FGetOrderInterfac write FGetOrderInterfac;
  end;

  TDBItem = class
  private
    FCatchReason: string;
    FKcNum: Integer;
    FRoleName: string;
    FSyNum: Integer;
    FOrderNo: string;
    FSaleNum: Integer;
    FAccount: string;
    FSaleState: Integer;
    FRoleId: Integer;
    FRowId: Integer;
  public
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    /// <summary>
    /// 订单ID
    /// </summary>
    property rowId: Integer read FRowId write FRowId;
    /// <summary>
    /// 游戏账号
    /// </summary>
    property account: string read FAccount write FAccount;
    /// <summary>
    /// 角色名称
    /// </summary>
    property roleName: string read FRoleName write FRoleName;
    /// <summary>
    /// 角色ID
    /// </summary>
    property roleId: Integer read FRoleId write FRoleId;
    /// <summary>
    /// 发货数量
    /// </summary>
    property saleNum: Integer read FSaleNum write FSaleNum;
    /// <summary>
    /// 库存数量
    /// </summary>
    property kcNum: Integer read FKcNum write FKcNum;
    /// <summary>
    /// 剩余数量
    /// </summary>
    property syNum: Integer read FSyNum write FSyNum;
    /// <summary>
    /// 订单状态
    /// </summary>
    property saleState: Integer read FSaleState write FSaleState;
    /// <summary>
    /// 异常原因
    /// </summary>
    property catchReason: string read FCatchReason write FCatchReason;
  end;

  TFcDBItem = class
  private
    FCatchReason: string;
    FOrderNo: string;
    FSaleNum: Integer;
    FSaleState: Integer;
    FRowId: Integer;
    FGroupNo: string;
    FOutAccount: string;
    FOutRoleName: string;
    FOutRoleId: Integer;
    FInAccount: string;
    FInRoleId: Integer;
    FInRoleName: string;
    FOutSyNum: Integer;
    FOutRoleKc: Integer;
    FOrderState: Integer;
    FOutNum: Integer;
    FInSyNum: Integer;
    FInRoleKc: Integer;
  public
    /// <summary>
    /// 订单编号
    /// </summary>
    property orderNo: string read FOrderNo write FOrderNo;
    /// <summary>
    /// 组编号
    /// </summary>
    property groupNo: string read FGroupNo write FGroupNo;
    /// <summary>
    /// 订单ID
    /// </summary>
    property rowId: Integer read FRowId write FRowId;
    /// <summary>
    /// 主号游戏账号
    /// </summary>
    property outAccount: string read FOutAccount write FOutAccount;
    /// <summary>
    /// 主号角色名称
    /// </summary>
    property outRoleName: string read FOutRoleName write FOutRoleName;
    /// <summary>
    /// 主号角色ID
    /// </summary>
    property outRoleId: Integer read FOutRoleId write FOutRoleId;
    /// <summary>
    /// 主号库存数量
    /// </summary>
    property outRoleKc: Integer read FOutRoleKc write FOutRoleKc;
    /// <summary>
    /// 主号剩余数量
    /// </summary>
    property outSyNum: Integer read FOutSyNum write FOutSyNum;
    /// <summary>
    /// 子号游戏账号
    /// </summary>
    property inAccount: string read FInAccount write FInAccount;
    /// <summary>
    /// 子号角色名称
    /// </summary>
    property inRoleName: string read FInRoleName write FInRoleName;
    /// <summary>
    /// 子号角色ID
    /// </summary>
    property inRoleId: Integer read FInRoleId write FInRoleId;
    /// <summary>
    /// 主号库存数量
    /// </summary>
    property inRoleKc: Integer read FInRoleKc write FInRoleKc;
    /// <summary>
    /// 主号剩余数量
    /// </summary>
    property inSyNum: Integer read FInSyNum write FInSyNum;
    /// <summary>
    /// 发货数量
    /// </summary>
    property outNum: Integer read FOutNum write FOutNum;
    /// <summary>
    /// 订单状态
    /// </summary>
    property orderState: Integer read FOrderState write FOrderState;
    /// <summary>
    /// 异常原因
    /// </summary>
    property catchReason: string read FCatchReason write FCatchReason;
  end;

  TSerizalizes = class
  public
    class function AsJSON<T>(AObject: T; Indent: Boolean = False): string;
    class function AsType<T>(AJsonText: string; var tRet: T): Boolean;
  end;


var
  GOrders: TArray<TOrderItem>;



implementation

uses SuperObject;

{ TSerizalizes }

class function TSerizalizes.AsJSON<T>(AObject: T; Indent: Boolean): string;
var
  Ctx: TSuperRttiContext;
begin
  Ctx := TSuperRttiContext.Create;
  try
    try
      Result := Ctx.AsJson<T>(AObject).AsJSon(Indent, False);
    except
      on E: Exception do
        OutputDebugString(PWideChar(Format('MS - AsJson fail, Err: %s', [E.Message])));
    end;
  finally
    Ctx.Free;
  end;
end;

class function TSerizalizes.AsType<T>(AJsonText: string; var tRet: T): Boolean;
var
  Ctx: TSuperRttiContext;
begin
  Result := False;
  Ctx := TSuperRttiContext.Create;
  try
    try
      tRet := Ctx.AsType<T>(SO(AJsonText));
      Result := True;
    except
      on E: Exception do
      begin
        OutputDebugString(PWideChar(Format('MS - AsType fail, Err: %s', [E.Message])));
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

end.
