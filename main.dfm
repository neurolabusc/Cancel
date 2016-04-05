object Form1: TForm1
  Left = 587
  Top = 81
  Width = 800
  Height = 558
  Caption = 'Cancellation Count'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  WindowMenu = Boxsize1
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 40
    Top = 72
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
    Visible = False
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 483
    Width = 792
    Height = 29
    Align = alBottom
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    object CommentEdit: TEdit
      Left = 0
      Top = 2
      Width = 796
      Height = 21
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 483
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 792
      Height = 483
      Cursor = crCross
      Align = alClient
      Stretch = True
      OnMouseDown = Image1MouseDown
      OnMouseMove = Image1MouseMove
    end
    object DefectCheck: TCheckBox
      Left = 8
      Top = 8
      Width = 121
      Height = 17
      Caption = 'Mark Defects Task'
      TabOrder = 0
      OnClick = DefectCheckChange
    end
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 216
    object File1: TMenuItem
      Caption = 'File'
      object Statistics1: TMenuItem
        Caption = 'Statistics'
        OnClick = Statistics1Click
      end
      object Opendata1: TMenuItem
        Caption = 'Open'
        ShortCut = 16463
        OnClick = Opendata1Click
      end
      object Savedata1: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
        OnClick = Savedata1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 16472
        OnClick = Exit1Click
      end
    end
    object Edit2: TMenuItem
      Caption = 'Edit'
      object Copy1: TMenuItem
        Caption = 'Copy statistics to clipboard'
        OnClick = CopyStats1Click
      end
      object Checkall1: TMenuItem
        Caption = 'Check all'
        ShortCut = 16449
        OnClick = Checkall1Click
      end
      object Uncheckall1: TMenuItem
        Caption = 'Uncheck all'
        ShortCut = 16469
        OnClick = Uncheckall1Click
      end
      object ReverseChecks1: TMenuItem
        Caption = 'Reverse Checks'
        OnClick = ReverseChecks1Click
      end
      object Boxsize1: TMenuItem
        Caption = 'Box size...'
        OnClick = Boxsize1Click
      end
      object Showcaptions1: TMenuItem
        AutoCheck = True
        Caption = 'Show captions'
        OnClick = Showcaptions1Click
      end
      object Showimage1: TMenuItem
        AutoCheck = True
        Caption = 'Show image'
        Visible = False
        OnClick = Showimage1Click
      end
      object Showcomment1: TMenuItem
        AutoCheck = True
        Caption = 'Show comment'
        OnClick = Showcomment1Click
      end
    end
    object View1: TMenuItem
      Caption = 'Advanced'
      object Newtest1: TMenuItem
        Caption = 'New test...'
        ShortCut = 16462
        OnClick = Newtest1Click
      end
      object Editpositions1: TMenuItem
        AutoCheck = True
        Caption = 'Edit positions'
        OnClick = Editpositions1Click
      end
      object Checkedcolor1: TMenuItem
        Caption = 'Detected color'
        OnClick = Checkedcolor1Click
      end
      object Uncheckedcolor1: TMenuItem
        Caption = 'Undetected color'
        OnClick = Uncheckedcolor1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.ini'
    Filter = 'Ini file|*.ini'
    Left = 16
    Top = 176
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.ini'
    Filter = 'Ini file|*.ini'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 16
    Top = 256
  end
  object BmpOpenDialog: TOpenDialog
    DefaultExt = '*.jpg'
    Filter = 'Bitmaps|*.jpg; *.jpeg; *.png; *.bmp'
    Left = 16
    Top = 104
  end
  object RestoreTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = RestoreTimerTimer
    Left = 16
    Top = 304
  end
  object ColorDialog1: TColorDialog
    Left = 16
    Top = 144
  end
end
