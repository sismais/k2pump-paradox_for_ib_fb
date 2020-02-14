object frmPreview: TfrmPreview
  Left = 428
  Top = 269
  Width = 999
  Height = 554
  Caption = 'Preview Table Data'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 35
    Width = 983
    Height = 481
    Align = alClient
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 983
    Height = 35
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 86
      Height = 13
      Caption = 'Preview of Table: '
    end
    object lblTableName: TLabel
      Left = 96
      Top = 12
      Width = 71
      Height = 13
      Caption = 'TABLE_NAME'
    end
  end
end
