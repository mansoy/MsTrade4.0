object FrmParamSet: TFrmParamSet
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #21442#25968#35774#32622
  ClientHeight = 474
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    387
    474)
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 433
    Width = 387
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 412
    DesignSize = (
      387
      41)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 387
      Height = 2
      Align = alTop
      ExplicitLeft = 32
      ExplicitTop = 8
      ExplicitWidth = 50
    end
    object btnSave: TButton
      Left = 213
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #20445#23384
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnCancel: TButton
      Left = 290
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 343
    Width = 365
    Height = 87
    Anchors = [akLeft, akTop, akRight]
    Caption = #20854#20182#35774#32622
    TabOrder = 1
    object Label4: TLabel
      Left = 38
      Top = 42
      Width = 96
      Height = 13
      Caption = #20219#21153#22833#36133#23581#35797#27425#25968
    end
    object Label5: TLabel
      Left = 50
      Top = 66
      Width = 84
      Height = 13
      Caption = #24403#21069#20219#21153#26368#22823#25968
    end
    object Label9: TLabel
      Left = 74
      Top = 18
      Width = 60
      Height = 13
      Caption = #25511#21046#21488#26631#31034
    end
    object edtMaxTaskTimes: TcxSpinEdit
      Left = 138
      Top = 39
      Properties.MaxValue = 10.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 0
      Value = 3
      Width = 53
    end
    object edtCurMaxTaskCount: TcxSpinEdit
      Left = 138
      Top = 63
      Properties.MaxValue = 200.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 1
      Value = 50
      Width = 53
    end
    object cbConsoleID: TcxComboBox
      Left = 138
      Top = 14
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'C01'
        'C02'
        'C03'
        'C04'
        'C05'
        'C06'
        'C07'
        'C08'
        'C09'
        'C10')
      TabOrder = 2
      Text = 'C01'
      Width = 53
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 10
    Width = 365
    Height = 108
    Anchors = [akLeft, akTop, akRight]
    Caption = #21457#36135#26426#35268#21017
    TabOrder = 2
    object Label2: TLabel
      Left = 37
      Top = 78
      Width = 135
      Height = 13
      Caption = #20998#24211#38468#21152'                     '#19975#37329
    end
    object Label7: TLabel
      Left = 189
      Top = 78
      Width = 135
      Height = 13
      Caption = #20179#24211#28014#21160'                     '#19975#37329
    end
    object chk自动分批: TCheckBox
      Left = 37
      Top = 50
      Width = 228
      Height = 17
      Caption = #25910#36135#35282#33394#31561#32423#36229#36807#25658#24102#38480#21046#26102#33258#21160#20998#25209
      Enabled = False
      TabOrder = 0
    end
    object chk缺料则暂停: TCheckBox
      Left = 36
      Top = 24
      Width = 135
      Height = 17
      Caption = #20998#20179#21457#29616#32570#26009#21017#26242#20572
      TabOrder = 1
    end
    object edt分仓附加: TcxSpinEdit
      Left = 89
      Top = 75
      Enabled = False
      TabOrder = 2
      Width = 57
    end
    object edt仓库浮动: TcxSpinEdit
      Left = 241
      Top = 75
      Properties.AssignedValues.MinValue = True
      TabOrder = 3
      Value = 1
      Width = 57
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 120
    Width = 365
    Height = 217
    Anchors = [akLeft, akTop, akRight]
    Caption = 'OA'#25509#21475
    TabOrder = 3
    DesignSize = (
      365
      217)
    object Label1: TLabel
      Left = 37
      Top = 26
      Width = 24
      Height = 13
      Caption = #20219#21153
    end
    object Label3: TLabel
      Left = 37
      Top = 53
      Width = 24
      Height = 13
      Caption = #29366#24577
    end
    object Label6: TLabel
      Left = 37
      Top = 80
      Width = 24
      Height = 13
      Caption = #26085#24535
    end
    object Label8: TLabel
      Left = 37
      Top = 107
      Width = 24
      Height = 13
      Caption = #22270#29255
    end
    object Label10: TLabel
      Left = 37
      Top = 161
      Width = 24
      Height = 13
      Caption = #24322#24120
    end
    object Label11: TLabel
      Left = 13
      Top = 188
      Width = 48
      Height = 13
      Caption = #33719#21462#35746#21333
    end
    object Label12: TLabel
      Left = 25
      Top = 134
      Width = 36
      Height = 13
      Caption = #25658#24102#37327
    end
    object edtTaskLink: TcxTextEdit
      Left = 67
      Top = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'http://192.168.192.184:8080/saleOrder'
      Width = 280
    end
    object edtStateLink: TcxTextEdit
      Left = 67
      Top = 50
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
    object edtLogLink: TcxTextEdit
      Left = 67
      Top = 77
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
    object edtImgLink: TcxTextEdit
      Left = 67
      Top = 104
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
    object edtSetExceptionLink: TcxTextEdit
      Left = 67
      Top = 158
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
    object edtGetOrder: TcxTextEdit
      Left = 67
      Top = 185
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
    object edtCarryLink: TcxTextEdit
      Left = 67
      Top = 131
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
      Text = 'http://192.168.192.184:8080/shiftOrder'
      Width = 280
    end
  end
end
