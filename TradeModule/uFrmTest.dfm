object FrmTest: TFrmTest
  Left = 0
  Top = 0
  Caption = 'FrmTest'
  ClientHeight = 355
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 306
    Align = alClient
    BevelInner = bvLowered
    Caption = 'Panel1'
    TabOrder = 0
    object LstLog: TMemo
      Left = 2
      Top = 2
      Width = 443
      Height = 302
      Align = alClient
      BevelInner = bvNone
      BorderStyle = bsNone
      Lines.Strings = (
        'LstLog')
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 306
    Width = 447
    Height = 49
    Align = alBottom
    BevelInner = bvLowered
    TabOrder = 1
    object btnStart: TButton
      Left = 336
      Top = 13
      Width = 97
      Height = 25
      Caption = #24320#22987#25191#34892
      TabOrder = 0
      OnClick = btnStartClick
    end
    object Button1: TButton
      Left = 24
      Top = 16
      Width = 75
      Height = 25
      Caption = 'close'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
end
