object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #30331#38470
  ClientHeight = 163
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 257
    Height = 147
    TabOrder = 0
    DesignSize = (
      257
      147)
    object Label1: TLabel
      Left = 30
      Top = 19
      Width = 24
      Height = 13
      Caption = #36134#21495
    end
    object Label2: TLabel
      Left = 30
      Top = 43
      Width = 24
      Height = 13
      Caption = #23494#30721
    end
    object Bevel1: TBevel
      Left = 13
      Top = 100
      Width = 232
      Height = 2
      Anchors = [akLeft, akTop, akRight]
    end
    object edtUserName: TEdit
      Left = 60
      Top = 16
      Width = 177
      Height = 21
      TabOrder = 0
    end
    object edtPassWord: TEdit
      Left = 60
      Top = 40
      Width = 177
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
      OnKeyPress = edtPassWordKeyPress
    end
    object btnLogin: TButton
      Left = 123
      Top = 109
      Width = 57
      Height = 25
      Caption = #30331'  '#38470
      TabOrder = 2
      OnClick = btnLoginClick
    end
    object btnExit: TButton
      Left = 186
      Top = 109
      Width = 57
      Height = 25
      Caption = #36864'  '#20986
      ModalResult = 2
      TabOrder = 3
    end
    object btnDBConnSet: TButton
      Left = 10
      Top = 109
      Width = 98
      Height = 25
      Caption = #25968#25454#24211#36830#25509#35774#32622
      TabOrder = 4
      OnClick = btnDBConnSetClick
    end
    object chkRemPwd: TCheckBox
      Left = 59
      Top = 70
      Width = 97
      Height = 17
      Caption = #35760#20303#23494#30721
      TabOrder = 5
    end
    object chkAutoLogin: TCheckBox
      Left = 134
      Top = 70
      Width = 97
      Height = 17
      Caption = #33258#21160#30331#24405
      TabOrder = 6
      OnClick = chkAutoLoginClick
    end
  end
end
