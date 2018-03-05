unit uPublic;

interface

uses Windows, Messages;

type

  TMsgContent = string[100];
  TGroupName = string[50];
  TComName = string[20];
  TQQNum = string[20];
  TPhoneNum = string[20];

  TCommType = (
    ctNone,             //--无类型
    ctResult,           //--返回结果
    ctGroupName,        //--设备端告诉中间服自己的组标识
    ctSendMsg,          //--发送短信
    ctRecvMsg,          //--接收短信，设备端收到短信后返回给服务端
    ctUnSafe            //--解安全
    );

  //--处理结果
  TResultState = (
    rsSuccess,          //--成功
    rsFail              //--失败
  );

  PResultInfo = ^TResultInfo;
  TResultInfo = packed record
    CommType      : TCommType;        //--标识是结果结构体
    PriorCommType : TCommType;        //--标识是那个命令的返回结果
    ResultState   : TResultState;     //--标识结果成功还是失败
    ClientConnID  : DWORD;            //--客户端的链接ID
    ResuleMsg     : string[200];      //--结果描述
  end;

  //--记录设备链接信息
  PDeviceInfo = ^TDeviceInfo;
  TDeviceInfo = record
    IsDevice: Boolean;      //--标识是设备端， 还是客户端，
    ConnectID: DWORD;       //--Socket
    GroupName: TGroupName;
    IP: string[20];
    Port: Word;
  end;

  //--发送、接收短信的结构体
  PSmsData = ^TSmsData;
  TSmsData = packed record
    CommType    : TCommType;
    ClientConnID: DWORD;
    MsgContent  : TMsgContent;
    SendPhoneNum: TPhoneNum;
    RecvPhoneNum: TPhoneNum;
    ComName     : TComName;
    GroupName   : TGroupName;
  end;

  //--设置分组标识
  PGroupData = ^TGroupData;
  TGroupData = packed record
    CommType : TCommType;
    GroupName: TGroupName;
  end;

  //解安全内容
  PSafeData = ^TSafeData;
  TSafeData = packed record
    CommType  : TCommType;
    QQ        : TQQNum;
    PhoneNum  : TPhoneNum;
    MsgContent: TMsgContent;
  end;


var
  GFrmMainHwnd: HWND;

const
  WM_ADD_LOG    = WM_USER + 1001;
  WM_ADD_DEVICE = WM_USER + 1002;

implementation

end.
