unit main;
{$IFDEF FPC} {$mode delphi}{$H+}  {$ENDIF}
interface

uses

  Classes, SysUtils,   Forms, Controls, Graphics, Dialogs,  StrUtils,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Buttons, utils, prefs,Messages,
  {$IFDEF FPC}
  LCLType,lclintf, LResources, ToolWin, FileUtil
  {$ELSE}
  Windows,o_FormEvents, jpeg, ShellAPI,PNGIMage //, ToolWin
  {$ENDIF} ;
type

  { TForm1 }

  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    CommentEdit: TEdit;
    FileSepMenu: TMenuItem;
    CheckLeft1: TMenuItem;
    CheckRight1: TMenuItem;
    MRU10: TMenuItem;
    MRU9: TMenuItem;
    MRU8: TMenuItem;
    MRU7: TMenuItem;
    MRU3: TMenuItem;
    MRU4: TMenuItem;
    MRU5: TMenuItem;
    MRU6: TMenuItem;
    MRU2: TMenuItem;
    MRU1: TMenuItem;
    OpenDialog2: TOpenDialog;
    TaskLabel: TLabel;
    PerseverateCheck: TCheckBox;
    Edit1: TMenuItem;
    Image1: TImage;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    FileMenu: TMenuItem;
    Exit1: TMenuItem;
    Checkall1: TMenuItem;
    Boxsize1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    EditPositions1: TMenuItem;
    Copy1: TMenuItem;
    CheckedColor1: TMenuItem;
    UncheckedColor1: TMenuItem;
    ShowComment1: TMenuItem;
    NewTest1: TMenuItem;
    Showimage1: TMenuItem;
    Showcaptions1: TMenuItem;
    Reversechecks1: TMenuItem;
    RestoreTimer: TTimer;
    Uncheckall1: TMenuItem;
    Savedata1: TMenuItem;
    Opendata1: TMenuItem;
    Statistics1: TMenuItem;
    OpenDialog1: TOpenDialog;
    BmpOpenDialog: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    ToolBar1: TToolBar;
    View1: TMenuItem;
    Edit2: TMenuItem;
    DefectCheck: TCheckBox;
    procedure CheckedColor1Click(Sender: TObject);
    procedure ChangeColor (lCheckColor: boolean);
    procedure CheckLeft1Click(Sender: TObject);
    procedure CheckRight1Click(Sender: TObject);
    procedure DefectCheckChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MouseDownX(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure About1Click(Sender: TObject);
    procedure Boxsize1Click(Sender: TObject);
    procedure Checkall1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseMoveX (Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MRUclick(Sender: TObject);
    procedure Newtest1Click(Sender: TObject);
    procedure Opendata1Click(Sender: TObject);
    procedure CopyStats1Click(Sender: TObject);
    procedure PerseverateCheckChange(Sender: TObject);
    procedure RestoreTimerTimer(Sender: TObject);
    procedure OnRestoreX(Sender: TObject);
    procedure Reversechecks1Click(Sender: TObject);
    procedure Savedata1Click(Sender: TObject);
    procedure Showcaptions1Click(Sender: TObject);
    procedure Showcomment1Click(Sender: TObject);
    procedure Showimage1Click(Sender: TObject);
    procedure ColorBtn(i: integer);
    procedure ColorBtnPaint(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure Statistics1Click(Sender: TObject);
    procedure Uncheckall1Click(Sender: TObject);
    procedure Recount(Sender: TObject);
    procedure SaveTest(lIniName: string);
    procedure OpenTest(lIniName: string);
    procedure Editpositions1Click(Sender: TObject);
    procedure UncheckedColor1Click(Sender: TObject);
  private
    {$IFNDEF FPC}    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES; {$ENDIF}
  public
    procedure ShowMatrix (lReloadImage: boolean);
  end;

var
  Form1: TForm1;
  {$IFNDEF FPC}   FFormEvents: TgtFormEvents; {$ENDIF}
implementation
{$IFNDEF FPC} {$R *.dfm}   {$ENDIF}
var
  gPrefs: TPrefs;

  gCheckArray : array [1..kMaxCheck] of  TPanel;

{$IFNDEF FPC}
procedure TForm1.WMDropFiles(var Msg: TWMDropFiles);  //implement drag and drop
var  CFileName: array[0..MAX_PATH] of Char;
begin
  try
   if DragQueryFile(Msg.Drop, 0, CFileName, MAX_PATH) > 0 then begin
      OpenTest(CFilename);
      Msg.Result := 0;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;//WMDropFiles
{$ENDIF}

procedure TForm1.Recount(Sender: TObject);
var lCoC: double;
begin
  if gPrefs.nCheck < 1 then
    exit;
  caption := StatString(gPrefs, true,lCoC);
end; //Recount

procedure TForm1.Reversechecks1Click(Sender: TObject);
var
  i: integer;
begin
  if gPrefs.nCheck < 1 then
    exit;
  if (IncludesMultiModes(gPrefs)) then begin
     if (DefectCheck.Checked) then begin
        for i := 1 to gPrefs.nCheck do
            if  gPrefs.CheckPos[i].targettype <> kNormalTargetType then
                gPrefs.CheckPos[i].checkedDefectMode := not gPrefs.CheckPos[i].checkedDefectMode;

     end else begin
         for i := 1 to gPrefs.nCheck do
             if  gPrefs.CheckPos[i].targettype = kNormalTargetType then
                 gPrefs.CheckPos[i].checked := not gPrefs.CheckPos[i].checked;
     end;
   end else begin
       for i := 1 to gPrefs.nCheck do
           gPrefs.CheckPos[i].checked := not gPrefs.CheckPos[i].checked;
   end;
  Form1.ShowMatrix(false);
end;  //Reversechecks1Click

procedure TForm1.SaveTest(lIniName: string);
begin
  gPrefs.Comment := CommentEdit.Text;
  IniFile(false, lIniName, gPrefs);
end; //SaveTest

procedure ImageXYtoScreenXY (liX,liY, lSz: integer; var lX,lY: integer);
begin
  lX := round(liX/gPrefs.MaxX * Form1.Image1.Width)- (lSz div 2);
  lY := round(liY/gPrefs.MaxY * Form1.Image1.Height)- (lSz div 2);
end; //ImageXYtoScreenXY

function imgPngOrJpg(S: string): string;
//if ini file specifies "ota.jpg" allow "ota.png"
begin
     result := S;
     if fileexists(result) then exit;
     result := changefileext(S,'.png');
     if fileexists(result) then exit;
     result := changefileext(S,'.jpg');
     if fileexists(result) then exit;
     result := changefileext(S,'.jpeg');
     if fileexists(result) then exit;
     result := S;
end;

function ImageFullPath(S: string): string;
begin
  result := S;
  if not (fileexists(result)) then
     result  := AppDirVisible(gAppPrefs.ImageFolder) +extractfilename(S);
  result := imgPngOrJpg(result);
  if not (fileexists(result)) then
     result  :=  gPrefs.inipath +pathdelim+extractfilename(S);
  //Form1.Copy1.caption := GetCurrentDir;
  result := imgPngOrJpg(result);
  if not (fileexists(result)) then begin
     Showmessage('Unable to find '+S+'. Please find this image' );
     Form1.BmpOpenDialog.InitialDir := GetCurrentDir;
     if not Form1.BmpOpenDialog.Execute then
        exit;
     gAppPrefs.ImageFolder := extractfilepath( Form1.BmpOpenDialog.Filename);
     result :=  Form1.BmpOpenDialog.Filename;
  end;
end;

procedure TForm1.ShowMatrix (lReloadImage: boolean);
var
  i,lx,ly: integer;
  lImgName,str : string;
begin
  if gAppPrefs.CommentVisible then
    CommentEdit.Width := Toolbar1.width - 4;
  if (gPrefs.ImageName = '') then
    Image1.Picture := nil
  else begin
    if lReloadImage then begin
     CommentEdit.Text := gPrefs.Comment;
     lImgName := ImageFullPath(gPrefs.ImageName);
     if (fileexists(lImgName)) then
        Image1.Picture.LoadFromFile(lImgName)
     else
         Image1.Picture := nil;
    end;
  end;
  Image1.visible := gPrefs.ImageVisible;
  Toolbar1.Visible := gAppPrefs.CommentVisible;
  PerseverateCheck.checked := gPrefs.Perseverate;
  if gPrefs.nCheck < kMaxCheck then begin
    for i := (gPrefs.nCheck+1) to kMaxCheck do begin
      with gCheckArray[i] do
        Visible := false;
      end;
  end;
  if (gPrefs.nCheck < 1)  then
    exit;
  if (not gPrefs.CopyTask) and (IncludesMultiModes(gPrefs)) then begin
    DefectCheck.visible := true;
    DefectCheck.Checked := gPrefs.MarkDefectMode;
    if gPrefs.MarkDefectMode then
       TaskLabel.Caption := 'Mark defective items (e.g. circles with gaps)'
    else
        TaskLabel.Caption := 'Mark complete items (e.g. whole circles)';
    TaskLabel.Visible := true;
  end else begin
      DefectCheck.visible := false;
      gPrefs.MarkDefectMode  :=false;
      TaskLabel.Visible := false;
  end;
  for i := 1 to gPrefs.nCheck do begin
    with gCheckArray[i] do begin
      str := inttostr(i);
      if gPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
         str := 'L'+str;
      if gPrefs.CheckPos[i].targettype = kDefectRightTargetType then
         str := 'R'+str;
      if gPrefs.CaptionVisible then
        Caption := str
      else
        Caption := '';
      if gPrefs.CopyTask then begin
         Height := gPrefs.Size;
         Width := gPrefs.Size;
      end else if(gPrefs.MarkDefectMode) then begin
       if ( gPrefs.CheckPos[i].targettype = kNormalTargetType) then begin
          Height := round(gPrefs.Size*0.55);
          Width := round(gPrefs.Size*0.55);
       end else begin
           Height := gPrefs.Size;
           Width := gPrefs.Size;
       end;
      end else begin
          if ( gPrefs.CheckPos[i].targettype <> kNormalTargetType) then begin
             Height := round(gPrefs.Size*0.55);
             Width := round(gPrefs.Size*0.55);
          end else begin
              Height := gPrefs.Size;
              Width := gPrefs.Size;
          end;
      end;
      Visible := true;
      ImageXYtoScreenXY( gPrefs.CheckPos[i].X,gPrefs.CheckPos[i].Y, Height, lx,ly);
      Top := ly;
      Left :=lx;
      Font.Size := 10;
      Font.Style:= [fsBold];
      Font.Color := clOlive;
    end;
    {$IFDEF FPC}
    //gCheckArray[i].Repaint;
    ColorBtn(i);
    {$ELSE}
     ColorBtn(i);
     {$ENDIF}
  end;
  Recount(nil);
end; //ShowMatrix

function DefaultTestFilename : string;
var
  searchResult : TSearchRec;
begin
  result :='';
  if FindFirst(AppDirVisible(gAppPrefs.ImageFolder)+'*.ini', faAnyFile, searchResult) = 0 then
    result := AppDirVisible(gAppPrefs.ImageFolder)+searchResult.Name;
  SysUtils.FindClose(searchResult);
end; //DefaultTestFilename

procedure TForm1.OpenTest(lIniName: string);
var
  lStr: string;
begin
  if fileexists (lIniName) then begin
    IniFile(true, lIniName, gPrefs);
    //gAppPrefs.AppFolderVisible := ExtractFilePath(lIniName);
  end else begin
    lStr := DefaultTestFilename;
    if lStr <> '' then
      IniFile(true, lStr, gPrefs)
    else begin
         Showmessage('Unable to find any tests, please select a test' );
         OpenDialog1.Title:= 'Select test to load';
         if OpenDialog1.Execute then begin
           gAppPrefs.ImageFolder := extractfilepath(OpenDialog1.FileName);
           gAppPrefs.MRUFolder := gAppPrefs.ImageFolder;
           IniFile(true, OpenDialog1.FileName, gPrefs);
         end;
    end;
  end;
  ShowCaptions1.checked := gPrefs.CaptionVisible;
  ShowImage1.Checked := gPrefs.ImageVisible;
  ShowComment1.checked := gAppPrefs.CommentVisible;
  ShowMatrix (true);
end; //OpenTest

procedure TForm1.Savedata1Click(Sender: TObject);
begin
     if not SaveDialog1.Execute then
        exit;
     SaveTest (SaveDialog1.Filename);
     Recount (nil);//show new filename in titlebar
end; //Savedata1Click

procedure TForm1.Showcaptions1Click(Sender: TObject);
begin
     gPrefs.CaptionVisible :=ShowCaptions1.checked;
     ShowMatrix (false);
end; //Showcaptions1Click

procedure TForm1.Showcomment1Click(Sender: TObject);
begin
     gAppPrefs.CommentVisible :=ShowComment1.checked;
   ShowMatrix (false);
   {$IFNDEF FPC}
   RestoreTimer.Enabled := true;
   {$ENDIF}
end; //Showcomment1Click

procedure TForm1.Showimage1Click(Sender: TObject);
begin
     gPrefs.ImageVisible :=ShowImage1.checked;
     ShowMatrix (false);
end; //Showimage1Click

procedure StatsHeader;
var
  lAlloStr: string;
begin
 Form1.Memo1.lines.Clear;
 if (IncludesMultiModes(gPrefs)) then
    lAlloStr :=kStatSep + 'Allocentric_A_Index'+kStatSep+'Allocentric_Chi^2_pValue'+kStatSep+'Perseveration'
 else
     lAlloStr := '';
 Form1.Memo1.lines.Add('CoC[Horizontal Pixels]'+kStatSep+'CoC[Horizontal Calibrated]'+kStatSep+'NumCancelled'+kStatSep+'NumTargets'+kStatSep+'CoC[A-P Calibrated]'+kStatSep+'ImageName'+kStatSep+'FileName'
 +kStatSep+'nLeftFound'+kStatSep+'nLeftNotFound'+kStatSep+'nRightFound'+kStatSep+'nRightNotFound'+kStatSep+'Chi^2_pValue_LeftFound/Not_v_RightFound/Not_Negative_Means_More_Right_Ommisions'+lAlloStr+kStatSep+'CoC[includeDistractors]' );
end; //StatsHeader

procedure TForm1.CopyStats1Click(Sender: TObject);
var
  lCoC: double;
begin
 StatsHeader;
 Memo1.Lines.Add(StatString(gPrefs,false,lCoC));
 Memo1.SelectAll;
 Memo1.CopyToClipboard;
 //Showmessage('Data has been copied to the clipboard.');
end; //CopyStats1Click

procedure TForm1.PerseverateCheckChange(Sender: TObject);
begin
 gPrefs.Perseverate :=PerseverateCheck.checked;
end;

function DualStat2  (lFilename: string): string;
//if 'filename-Circle' has pair 'filename_S', returns 'filename_S' else returns ''
begin
     result := '';
     if not fileexists (lFileName) then exit;
     if not AnsiContainsText(lFilename, '-Circle') then exit;
     result := AnsiReplaceStr(lFilename, '-Circle', '-Triangle');
     if not fileexists (result) then result := '';


end;
function DualStat (lFilename: string): string;
//if 'filename_B' has pair 'filename_S', returns 'filename_S' else returns ''
var
  dup: string;
begin
     result := '';
     if not fileexists (lFileName) then exit;
     if AnsiContainsText(lFilename, '_S.ini') then begin
        dup := AnsiReplaceStr(lFilename, '_S.ini', '_B.ini');
        if fileexists (lFileName) then
           result := '-';
        exit;
     end;
     if (not AnsiContainsText(lFilename, '_B.ini')) then begin
        result := DualStat2(lFilename);
        exit;
     end;
     result := AnsiReplaceStr(lFilename, '_B.ini', '_S.ini');
     if not fileexists (result) then result := '';
end;

{$DEFINE DOPAIR}
{$IFDEF DOPAIR}
procedure StatsHeaderPair;
var
  lAlloStr: string;
begin
 Form1.Memo1.lines.Clear;
 Form1.Memo1.Lines.Add('File1'+kStatSep+'File2'+kStatSep+'CoC1'+kStatSep+'CoC2'+kStatSep+'CoCmean'+   kStatSep
      +'FoundWholeEgoLeft'+ kStatSep+'MissedWholeEgoLeft'+kStatSep+ 'FoundWholeEgoRight'+ kStatSep+'MissedWholeEgoRight'+kStatSep+'EgoChiProb'+kStatSep+'EgoChiSig'+kStatSep
 +'AlloA'+kStatSep+'AlloChiProb'+kStatSep+'AlloChiSig'+kStatSep+'Perseveration'+kStatSep+'Image');
end;
{$ENDIF}

procedure TForm1.Statistics1Click(Sender: TObject);
var
  lPrefs: TPrefs;
  lCoC,lCoCpair: double;
  I: integer;
  lPerseverate: boolean;
  lFilename,lFilenamePair, lImg1: string;
  lA: TStats4A;
begin
  OpenDialog1.Title := 'Select test[s] to analyze';
    OpenDialog1.Options := [ofAllowMultiSelect];
    if not OpenDialog1.Execute then  begin
        OpenDialog1.Options := [];
        CopyStats1Click(Sender);
        exit;
    end;
    {$IFDEF DOPAIR}
    StatsHeaderPair;
    {$ELSE}
     StatsHeader;
    {$ENDIF}
    for I:=0 to OpenDialog1.Files.Count-1 do begin
      lFileName := OpenDialog1.Files[i];
      {$IFDEF DOPAIR}
      lFilenamePair :=  DualStat (lFilename) ;
      {$ELSE}
       lFilenamePair :=  '' ;
      {$ENDIF}
      if lFilenamePair = '-' then begin
         //ignore 2nd image of pair
      end else if lFilenamePair <> '' then begin
         ClearStats4A (lA);
         IniFile(true, lFileName, lPrefs);
         lImg1 := lPrefs.ImageName;
         lPerseverate := lPrefs.Perseverate;
         StatString(lPrefs,false,lCoC );
         AddStats4A (lPrefs, lA);
         IniFile(true, lFilenamePair, lPrefs);
         StatString(lPrefs,false,lCoCpair ) ;
         AddStats4A (lPrefs, lA);
         if lPerseverate then
            lPrefs.Perseverate := true;
        Memo1.Lines.Add(extractfilename(lFileName)+kStatSep+extractfilename(lFilenamePair)+kStatSep+RealToStr(lCoC,3 )+kStatSep+RealToStr(lCoCpair,3 )+kStatSep+RealToStr((lCoC+lCoCpair)/2,3)
            +kStatSep+Compute4Ego(lA)+kStatSep+Compute4A(lA)+kStatSep+peseverateString(lPrefs)+ kStatSep+ lImg1+ kStatSep+ lPrefs.ImageName);

      end else if fileexists (lFileName) then begin
       {$IFDEF DOPAIR}
       ClearStats4A (lA);
       IniFile(true, lFileName, lPrefs);
       lPerseverate := lPrefs.Perseverate;
       StatString(lPrefs,false,lCoC );
       AddStats4A (lPrefs, lA);
       Memo1.Lines.Add(extractfilename(lFileName)+kStatSep+''+kStatSep+RealToStr(lCoC,3 )+kStatSep+''+kStatSep+''
            +kStatSep+Compute4Ego(lA)+kStatSep+Compute4A(lA)+kStatSep+peseverateString(lPrefs)+ kStatSep+ lPrefs.ImageName);

      {$ELSE}

      IniFile(true, lFileName, lPrefs);
      Memo1.Lines.Add(StatString(lPrefs,false,lCoC ));
      {$ENDIF}

      end;

    end;
     OpenDialog1.Options := [];
     Memo1.SelectAll;
     Memo1.CopyToClipboard;
     Showmessage('Data has been copied '+inttostr(OpenDialog1.Files.Count)+ ' tests to the clipboard.');
     OpenTest(lFileName);
end; //Statistics1Click

(*procedure TForm1.Statistics1Click(Sender: TObject);
var
  lPrefs: TPrefs;
  I: integer;
  lFilename: string;
begin
  OpenDialog1.Title := 'Select test[s] to analyze';
    OpenDialog1.Options := [ofAllowMultiSelect];
    if not OpenDialog1.Execute then  begin
        OpenDialog1.Options := [];
        CopyStats1Click(Sender);
        exit;
    end;
    StatsHeader;
    for I:=0 to OpenDialog1.Files.Count-1 do begin
      lFileName := OpenDialog1.Files[i];
      if fileexists (lFileName) then begin
        IniFile(true, lFileName, lPrefs);
        Memo1.Lines.Add(StatString(lPrefs,false ));
      end;

    end;
     OpenDialog1.Options := [];
     Memo1.SelectAll;
     Memo1.CopyToClipboard;
     Showmessage('Data has been copied to the clipboard.');
     OpenTest(lFileName);
end; //Statistics1Click   *)

(*function CreateTabFile (lOutname: string): boolean;
var
  i: integer;
begin
    result := false;
    if gPrefs.nCheck < 1 then
      exit;
    if fileexists(lOutname) then begin
      showmessage('Unable to export: File exists named '+lOutname);
    end;
    Form1.Memo1.lines.Clear;
    Form1.Memo1.lines.Add('X'+kStatSep+'Y'+kStatSep+'Detected');
    for i := 1 to gPrefs.nCheck do
       Form1.Memo1.Lines.Add(inttostr(gPrefs.CheckPos[i].x)+ kStatSep+inttostr(gPrefs.CheckPos[i].y)+kStatSep+bool2char(gPrefs.CheckPos[i].checked))  ;
    Form1.Memo1.Lines.SaveToFile(lOutname);
    result := true;
end; //CreateTabFile

procedure TForm1.Statisticsexport1Click(Sender: TObject);
  var
  I: integer;
  lFilename: string;
begin
  OpenDialog1.Title := 'Select test[s] to export';
    OpenDialog1.Options := [ofAllowMultiSelect];
    if not OpenDialog1.Execute then  begin
        OpenDialog1.Options := [];
        exit;
    end;
    for I:=0 to OpenDialog1.Files.Count-1 do begin
      lFileName := OpenDialog1.Files[i];
      OpenTest(lFileName);
      CreateTabFile(changefileext(lFilename,'.tab') );
    end;
     OpenDialog1.Options := [];
     Memo1.SelectAll;
     Memo1.CopyToClipboard;
     Showmessage('Data has been exported.');
end; //Statisticsexport1Click
  *)
procedure ChangeCheckAll (lCheck: boolean);
var
  i: integer;
begin
  if gPrefs.nCheck < 1 then
    exit;
  if gPrefs.CopyTask then begin
     for i := 1 to gPrefs.nCheck do
         gPrefs.CheckPos[i].checked := lCheck;
     Form1.ShowMatrix (false);
     exit;
  end;

  if gPrefs.MarkDefectMode then begin
     for i := 1 to gPrefs.nCheck do
        if  gPrefs.CheckPos[i].targettype <> kNormalTargetType then
         gPrefs.CheckPos[i].checkedDefectMode := lCheck
        else
            gPrefs.CheckPos[i].checkedDefectMode := false;
  end else begin
      for i := 1 to gPrefs.nCheck do
         if  gPrefs.CheckPos[i].targettype = kNormalTargetType then
          gPrefs.CheckPos[i].checked := lCheck
         else
             gPrefs.CheckPos[i].checked := not lCheck;
  end;
  Form1.ShowMatrix (false);
end; //ChangeCheckAll

procedure TForm1.Uncheckall1Click(Sender: TObject);
begin
     ChangeCheckAll(false);
end; //ChangeCheckAll

procedure TForm1.About1Click(Sender: TObject);
var
  str: string;
begin
 {$IFDEF CPU64}
 str := '64-bit';
 {$ELSE}
 str := '32-bit';
 {$ENDIF}
 {$IFDEF Windows}str := str + ' Windows '; {$ENDIF}
 {$IFDEF LINUX}str := str + ' Linux '; {$ENDIF}
 {$IFDEF Darwin}str := str + ' OSX '; {$ENDIF}
 {$IFDEF LCLQT}str := str + ' (QT) '; {$ENDIF}
 {$IFDEF LCLGTK2}str := str + ' (GTK2) '; {$ENDIF}
 {$IFDEF LCLCocoa}str := str + ' (Cocoa) ';{$ENDIF}
 {$IFDEF LCLCarbon}str := str + ' (Carbon) '; {$ENDIF}

  Showmessage(str+kVersion)
end; //About1Click

procedure TForm1.Boxsize1Click(Sender: TObject);
var
  lS: string;
  lI: integer;
begin
  lS := inttostr(gPrefs.Size);
  if not InputQuery('Size of items', 'Pixel size', lS) then
   exit;
 lI := strtoint(lS);
 if lI < 2 then
  exit;
 gPrefs.Size := lI;
 ShowMatrix (false);
end; //Boxsize1Click

procedure TForm1.Checkall1Click(Sender: TObject);
begin
      ChangeCheckAll(true);
end; //Checkall1Click

procedure TForm1.Exit1Click(Sender: TObject);
begin
    close;
end; //Exit1Click

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  AppIniFile(false, AppIniFilename, gAppPrefs); //save application settings
  SaveTest(StartupIniName);   //save default test
end; //FormClose

function DecByte(lByte,lAmount: byte): byte;
begin
     if lByte > lAmount then
        result := lByte-lAmount
     else
         result := 0;
end; //DecByte

function IncByte(lByte,lAmount: byte): byte;
begin
     if lByte < (255-lAmount) then
        result := lByte+lAmount
     else
         result := 255;
end; //IncByte

(*function DarkerColor(lIn: tColor): TColor;
const
 kDarker = 64;
var
   lR,lG,lB: byte;
begin
  lR := Red(lIn);
  lG := Green(lIn);
  lB := Blue(lIn);
  result := RGBToColor(decByte(lR,kDarker), decByte(lG,kDarker),decByte(lB,kDarker));
end; //DarkerColor

function BrighterColor(lIn: tColor): TColor;
const
 kBrighter = 72;
var
   lR,lG,lB: byte;
begin
  lR := Red(lIn);
  lG := Green(lIn);
  lB := Blue(lIn);
  result := RGBToColor(incByte(lR,kBrighter), incByte(lG,kBrighter),incByte(lB,kBrighter));
end; //BrighterColor
*)

(*function ChangeHue(lIn: tColor; lRGBint: integer): TColor;
//if 1, make more reddish, if 2 make more green, if 3 make more blue
const
 kBrighter = 12;
var
   lRGB: array[1..3] of byte;
   i: integer;
begin

  {$IFDEF FPC}
  lRGB[1] := Red(lIn);
  lRGB[2] := Green(lIn);
  lRGB[3] := Blue(lIn);
  {$ELSE}
  lRGB[1] := GetRValue(lIn);
  lRGB[2] := GetGValue(lIn);
  lRGB[3] := GetBValue(lIn);
  {$ENDIF}
  if (lRGB[lRGBint] > (255-kBrighter)) then begin
     for i := 1 to 3 do
         if (i = lRGBint) then
            lRGB[i] := 255
         else if (lRGB[i] = 255) then
            lRGB[i] := 192
         else
             lRGB[i] := decByte(lRGB[i],kBrighter);
  end else  //make target color brighter
       lRGB[lRGBint] := lRGB[lRGBint] + kBrighter;
       {$IFDEF FPC}
  result := RGBToColor(lRGB[1],lRGB[2],lRGB[3]);
  {$ELSE}
 result := RGB(lRGB[1],lRGB[2],lRGB[3]) ;
  {$ENDIF}
end; //ChangeHue*)

function UnitRange (lIn: single): single;
begin
     if lIn < 0 then
        result := 0
     else if lIn > 1 then
          result := 1
     else
         result := lIn;
end;

 function ChangeHue(lIn: tColor; lRGBint: integer): TColor;
//if 1, make more reddish, if 2 make more green, if 3 make more blue
const
 //kBrighter = 12;
 kShift = 0.3;
var
   lRGB: array[1..3] of byte;
   lRGBs: array[1..3] of single;
   lY,lU,lV: single;
   i: integer;
begin

  {$IFDEF FPC}
  lRGB[1] := Red(lIn);
  lRGB[2] := Green(lIn);
  lRGB[3] := Blue(lIn);
  {$ELSE}
  lRGB[1] := GetRValue(lIn);
  lRGB[2] := GetGValue(lIn);
  lRGB[3] := GetBValue(lIn);
  {$ENDIF}
  for i := 1 to 3 do
      lRGBs[i] := lRGB[i]/255;
   lY:=((lRGBs[1]+2*lRGBs[2]+lRGBs[3])/4);
   lU:=lRGBs[1]-lRGBs[2];
   lV:=lRGBs[3]-lRGBs[2];
   if lRGBint = 1 then begin
      lU:=lU+ (lU * kShift);
      lV:=lV- (lV * kShift);
   end else begin
       lU:=lU- (lU * kShift);
       lV:=lV+ (lV * kShift);
   end;
   lRGBs[1]:=((lY-(lU+lV)/4));
   lRGBs[2]:=lU+lRGBs[1];
   lRGBs[3]:=lV+lRGBs[1];
   for i := 1 to 3 do
      lRGB[i] := round(UnitRange(lRGBs[i])*255);
   {$IFDEF FPC}
     result := RGBToColor(lRGB[1],lRGB[2],lRGB[3]);
     {$ELSE}
    result := RGB(lRGB[1],lRGB[2],lRGB[3]) ;
     {$ENDIF}
end; //ChangeHue
procedure TForm1.ColorBtn(i: integer);
var
  Clr: TColor;
begin
  if gPrefs.MarkDefectMode then begin
    if gPrefs.CheckPos[i].checkedDefectMode then
       Clr := gAppPrefs.CheckColor
    else
        Clr := gAppPrefs.UncheckColor;
  end else begin
      if gPrefs.CheckPos[i].checked then
         Clr := gAppPrefs.CheckColor
      else
          Clr := gAppPrefs.UncheckColor;
  end;
  if (gAppPrefs.EditableTargetPositions) then begin

     if gPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
        Clr := ChangeHue(Clr,1) //DarkerColor (Clr)
     else if gPrefs.CheckPos[i].targettype = kDefectRightTargetType then
          Clr := ChangeHue(Clr,2);//Clr := BrighterColor (Clr);
  end;
  gCheckArray[i].Color := clr;
end;

procedure TForm1.ColorBtnPaint(Sender: TObject);
var
  i: integer;
begin

  i := (Sender as TPanel).tag;
  ColorBtn(i);
  (*if gPrefs.MarkDefectMode then begin
    if gPrefs.CheckPos[i].checkedDefectMode then
       Clr := gAppPrefs.CheckColor
    else
        Clr := gAppPrefs.UncheckColor;
  end else begin
      if gPrefs.CheckPos[i].checked then
         Clr := gAppPrefs.CheckColor
      else
          Clr := gAppPrefs.UncheckColor;
  end;
  if (gAppPrefs.EditableTargetPositions) then begin
     if gPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
        Clr := ChangeHue(Clr,1) //DarkerColor (Clr)
     else if gPrefs.CheckPos[i].targettype = kDefectRightTargetType then
          Clr := ChangeHue(Clr,2);//Clr := BrighterColor (Clr);
  end;
  (Sender as TPanel).Color := clr;*)
end; //ColorBtnPaint

procedure SetCheckColor;
var
  i: integer;
begin
for i := 1 to kMaxCheck do
    gCheckArray[i].Refresh;
end; //SetCheckColor

function ResetIniDefaults : boolean;
const
     kKey = 'Shift or control key ';
var
   lKey: boolean;
begin
  result := false;
  if (paramcount > 0) then exit;
  lKey := ((GetKeyState(VK_CONTROL) AND 128)=128) or (ssShift in KeyDataToShiftState(vk_Shift)) or ((GetKeyState(VK_RBUTTON) And $80)<>0) or ((GetKeyState(VK_SHIFT) And $80)<>0);
  if not lKey then
    exit;
  case MessageDlg(kKey+' down during launch: do you want to reset the default preferences?', mtConfirmation,
		        [mbYes, mbNo], 0) of	{ produce the message dialog box }
		        idYes: result := true;
  end; //case
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
     {$IFDEF Darwin}
     OpenData1.ShortCut := ShortCut(Word('O'),[ssMeta]);
     SaveData1.ShortCut := ShortCut(Word('S'),[ssMeta]);
     Checkall1.ShortCut := ShortCut(Word('A'),[ssMeta]);
     CheckLeft1.ShortCut := ShortCut(Word('L'),[ssMeta]);
     CheckRight1.ShortCut := ShortCut(Word('R'),[ssMeta]);


     Uncheckall1.ShortCut := ShortCut(Word('U'),[ssMeta]);
     Exit1.visible := false;
     {$ENDIF}
     SetDefaultAppPrefs(gAppPrefs);
     AppIniFile(true, AppIniFilename, gAppPrefs);
     {$IFNDEF FPC}
     FFormEvents := TgtFormEvents.Create(Self);
     FFormEvents.Form         := Form1;
     FFormEvents.OnRestore    := OnRestoreX;
     DragAcceptFiles(Handle, True);
     {$ELSE}
     Application.ShowButtonGlyphs := sbgNever;
     {$ENDIF}//drag&drop
     SetDefaultPrefs(gPrefs);
     for i := 1 to kMaxCheck do begin
         gCheckArray[i] :=  TPanel.Create(form1);
         with gCheckArray[i] do begin
              Parent := Panel1;
              Tag := i;
              BevelOuter := bvNone;
              BevelInner := bvNone;
              {$IFDEF FPC}
              OnPaint := ColorBtnPaint;
              {$ENDIF}
              OnMouseDown := MouseDownX;
              OnMouseMove := MouseMoveX;
              Visible := true;
         end; //with
     end; //for
     SetCheckColor;
     if ResetIniDefaults then
        Opentest('')
     else
         Opentest(StartupIniName);
     Application.OnDropFiles:= FormDropFiles;
end; //FormCreate

procedure ScreenXYtoImageXY ( lX,lY: integer; var liX,liY: integer);
begin

 liX := round(lX/Form1.Image1.Width * gPrefs.MaxX);
 liY := round(lY/Form1.Image1.Height *gPrefs.MaxY);
 BoundInt(liX,1,gPrefs.MaxX);
 BoundInt(liY,1,gPrefs.MaxY);
end; //ScreenXYtoImageXY

function DX (lX1,lY1, lX2,lY2: integer): single;
//pythagorean distance between two points
begin
  result := sqrt( sqr(lX1-lX2)+sqr(lY1-lY2) );
end; //DX

function ClosestIndex (lXi,lYi: integer): integer;
//given X,Y in image coordinates, report index of nearest checkbox
var
  lDX, lMinDX: single;
  i : integer;
begin
  result := 1;
  if gPrefs.nCheck < 2 then
    exit;
  lMinDX := DX (lXi,lYi,gPrefs.CheckPos[1].X,gPrefs.CheckPos[1].Y);
  for i := 2 to gPrefs.nCheck do begin
    lDX := DX (lXi,lYi,gPrefs.CheckPos[i].X,gPrefs.CheckPos[i].Y);
    if lDX < lMinDX then begin
      result := i;
      lMinDX := lDX;
    end;
  end;
end; //ClosestIndex

procedure MoveToXY (lXs,lYs: integer);
var
  lPt, lXi,lYi: integer;
begin
  if (gPrefs.nCheck < 1)  then
    exit;
  ScreenXYtoImageXY ( lXs,lYs,lXi,lYi);
  lPt := ClosestIndex(lXi,lYi);
  gPrefs.CheckPos[lPt].Y := lYi;
  gPrefs.CheckPos[lPt].X := lXi;
  gPrefs.CheckPos[lPt].checked := true;
  ImageXYtoScreenXY( gPrefs.CheckPos[lPt].X,gPrefs.CheckPos[lPt].Y, gCheckArray[lPt].Height, lXi,lYi);
  Form1.ShowMatrix (false);
  //following than ShowMatrix...
  (*gCheckArray[lPt].Top := lyi;
  gCheckArray[lPt].Left :=lxi;
  gCheckArray[lPt].Repaint; *)
end;//MoveToXY

procedure TForm1.FormResize(Sender: TObject);
begin
 Form1.ShowMatrix (false);
end; //FormResize

procedure ChangeTargetTypeXY (lXs,lYs: integer);
var
  lPt, lXi,lYi: integer;
begin
  if (gPrefs.nCheck < 1)  then
    exit;
  ScreenXYtoImageXY ( lXs,lYs,lXi,lYi);
  lPt := ClosestIndex(lXi,lYi);
  gPrefs.CheckPos[lPt].targettype := gPrefs.CheckPos[lPt].targettype + 1;
  if (gPrefs.CheckPos[lPt].targettype > kDefectRightTargetType) then
     gPrefs.CheckPos[lPt].targettype := kNormalTargetType;

end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (gAppPrefs.EditableTargetPositions) and (mbLeft = Button) and (ssAlt in Shift) then begin
     ChangeTargetTypeXY(X,Y);
     exit;
  end;
  if (not gAppPrefs.EditableTargetPositions) or (not (ssCtrl in Shift)) or (mbLeft <> Button)  then begin
    exit;
  end;
   MoveToXY(X,Y);
end; //Image1MouseDown

procedure TForm1.MouseMoveX (Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  Image1MouseMove(Sender, Shift,(Sender as TPanel).Left + X,(Sender as TPanel).Top +Y);
end; //MouseMoveX

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    if  (not gAppPrefs.EditableTargetPositions) or (not (ssCtrl in Shift)) then
      exit;
   {$IFDEF FPC}
   if  not (ssLeft in Shift) then
     exit;
   {$ELSE}
  if  0 = HiWord(GetKeyState(VK_LBUTTON)) then
    exit;
   {$ENDIF}
   MoveToXY(X,Y);
end; //Image1MouseMove

procedure TForm1.Newtest1Click(Sender: TObject);
var
  lS,lS2: string;
  i,lT,lnCol,lRow,lCol: integer;
  lXi,lYi: single;
begin
 //Select Image
 BmpOpenDialog.InitialDir := AppDirVisible(gAppPrefs.ImageFolder);
 if not BmpOpenDialog.Execute then
    exit;
 lS := extractfilename(BmpOpenDialog.FileName);
 lS := ImageFullPath(lS);
 if not fileexists(lS) then begin
  Showmessage('Unable to find '+lS+'. Please put this picture into the folder '+gAppPrefs.ImageFolder );
  exit;
 end;
 //Select num targets
 lS2 := '60';
 if not InputQuery('Number of targets', 'Targets in test', lS2) then
  exit;
 lT := strtoint(lS2);
 if lT < 1 then
  exit;
 if lT > kMaxCheck then begin
     showmessage('Maximum targets = '+inttostr(kMaxCheck));
     exit;
 end;
 //load image
 Image1.Picture.LoadFromFile(lS);
 if (Image1.Picture.Height < lT) or (Image1.Picture.Width < lT) then begin
  showmessage('Image appears to small to contain this many targets HxW = '+inttostr(Image1.Picture.Height)+'x'+inttostr(Image1.Picture.Width));
  exit;
 end;
 SetDefaultPrefs(gPrefs);
 gPrefs.MaxX := Image1.Picture.Width;
 gPrefs.MaxY := Image1.Picture.Height;
 gPrefs.ImageVisible := true;
 gPrefs.ImageName := lS;
 gPrefs.nCheck := lT;
 lnCol := 1;
 while sqr(lnCol) < lT do
  inc(lnCol);
 lRow := 1;
 lCol := 1;
 lXi := gPrefs.MaxX/(lnCol+1) ;
 lYi := gPrefs.MaxY/(lnCol+1);
 for i := 1 to gPrefs.nCheck do begin
      gPrefs.CheckPos[i].x := round(lCol * lXi);
      gPrefs.CheckPos[i].y := round(lRow * lYi);
      gPrefs.CheckPos[i].checked := false;
      inc(lCol);
      if (lCol > lnCol) then begin
        lCol := 1;
        inc(lRow);
      end;
    end;
 Editpositions1.checked := true;
 Editpositions1Click(nil);
 ShowMatrix (false);
end; //Newtest1Click

procedure TForm1.Opendata1Click(Sender: TObject);
begin
     OpenDialog1.Title:= 'Select test to load';
     if not OpenDialog1.Execute then
        exit;
     SaveDialog1.Filename := '';
     OpenTest(OpenDialog1.FileName);
end; //Opendata1Click

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of String);
begin
     OpenTest(Filenames[0]);
end;

procedure TForm1.OnRestoreX(Sender: TObject);
begin
    RestoreTimer.Enabled := true;
end; //OnRestoreX

procedure TForm1.RestoreTimerTimer(Sender: TObject);
begin
 RestoreTimer.Enabled := false;
 image1.Width := panel1.ClientWidth;
 image1.Height := panel1.ClientHeight;
end; //RestoreTimerTimer

(*procedure TForm1.ChangeColor (lCheckColor: boolean);
begin
  Colordialog1.CustomColors.Clear;
  Colordialog1.CustomColors.Add('ColorA='+inttohex(gAppPrefs.CheckColor,6));
  Colordialog1.CustomColors.Add('ColorB='+inttohex(gAppPrefs.UNcheckColor,6));
  {$IFDEF FPC} //Not in Delphi 7 an earlier...
  if lCheckColor then
    ColorDialog1.Title := 'Detected color'
  else
    ColorDialog1.Title := 'Undetected color';
  {$ENDIF}
  if lCheckColor then
    ColorDialog1.Color := gAppPrefs.CheckColor
  else
    ColorDialog1.Color := gAppPrefs.UncheckColor;
  if not ColorDialog1.execute then
    exit;
  if lCheckColor then
    gAppPrefs.CheckColor := ColorDialog1.Color
  else
    gAppPrefs.UncheckColor := ColorDialog1.Color;
  SetCheckColor;
 ShowMatrix (false);
end; //ChangeColor *)

procedure ChangeAltXY (lPt: integer);
begin
  if gPrefs.CheckPos[lPt].targettype = kNormalTargetType then
    gPrefs.CheckPos[lPt].targettype := kDefectLeftTargetType
  else if gPrefs.CheckPos[lPt].targettype = kDefectLeftTargetType then
       gPrefs.CheckPos[lPt].targettype := kDefectRightTargetType
  else
    gPrefs.CheckPos[lPt].targettype := kNormalTargetType;
  //gCheckArray[lPt].Repaint; //<-faster than ShowMatrix, but does not change size
  Form1.ShowMatrix  (false);
  case  gPrefs.CheckPos[lPt].targettype of
        kDefectLeftTargetType: Form1.Caption := 'Updated type: Left Defect';
        kDefectRightTargetType : Form1.Caption := 'Updated type: Right Defect';
        else  Form1.Caption := 'Updated type: Normal';
  end;
end; //ChangeAltXY

procedure TForm1.MouseDownX(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
 i := (sender as TPanel).tag;
 if (Editpositions1.checked) and  (ssAlt in Shift) then begin
   ChangeAltXY(i);
   exit;
 end;
 if gPrefs.MarkDefectMode then
  gPrefs.CheckPos[i].checkedDefectMode := not gPrefs.CheckPos[i].checkedDefectMode
 else begin
     //PerseverateCheck.caption := BoolToStr(gPrefs.CheckPos[i].checked,'T','F')+' '+inttostr(i)+'z'+ inttostr(random(888));
     gPrefs.CheckPos[i].checked := not gPrefs.CheckPos[i].checked;
 end;


 {$IFDEF FPC}
 //gCheckArray[i].Repaint;
 ColorBtn(i);
 //ShowMatrix(false);
 {$ELSE}
 ColorBtn(i);
 {$ENDIF}
  Recount(Sender);
end;//MouseDownX

procedure TForm1.DefectCheckChange(Sender: TObject);
begin
  gPrefs.MarkDefectMode := DefectCheck.Checked;
  ShowMatrix(false);
end; //DefectCheckChange

procedure TForm1.FormShow(Sender: TObject);
//create menu of recently used items.
const
     kMaxMRU = 10;
var
   lCount, lnMRU : integer;
   lSearchRec: TSearchRec;
begin
 if (length(gAppPrefs.ImageFolder) < 1) or  (not DirectoryExists(gAppPrefs.ImageFolder)) then
    exit;
 gAppPrefs.MRUFolder:= gAppPrefs.ImageFolder ;
 lnMRU := 0;
 lCount := FileMenu.IndexOf(FileSepMenu)+1;
 if FindFirst(gAppPrefs.MRUFolder+'*.ini', faAnyFile, lSearchRec) = 0 then repeat
   FileMenu.Items[lCount + lnMRU].Visible:= true;
   FileMenu.Items[lCount + lnMRU].Caption:= changefileext(lSearchRec.Name,'');
   lnMRU := lnMRU + 1;;
 until (lnMRU >= kMaxMRU) or (FindNext(lSearchRec) <> 0);
 FindClose(lSearchRec);
end;


procedure TForm1.MRUclick(Sender: TObject);
begin
 OpenTest(gAppPrefs.MRUFolder+(Sender as TMenuItem).caption+'.ini');
 //OpenTest(gAppPrefs.MRUFolder+PathSeparator+(Sender as TMenuItem).caption+'.ini');
end;


procedure TForm1.ChangeColor (lCheckColor: boolean);
begin
  Colordialog1.CustomColors.Clear;
  Colordialog1.CustomColors.Add('ColorA='+inttohex(gAppPrefs.CheckColor,6));
  Colordialog1.CustomColors.Add('ColorB='+inttohex(gAppPrefs.UNcheckColor,6));
  {$IFDEF FPC} //Not in Delphi 7 an earlier...
  if lCheckColor then
    ColorDialog1.Title := 'Detected color'
  else
    ColorDialog1.Title := 'Undetected color';
  {$ENDIF}
  if lCheckColor then
    ColorDialog1.Color := gAppPrefs.CheckColor
  else
    ColorDialog1.Color := gAppPrefs.UncheckColor;
  if not ColorDialog1.execute then
    exit;
  if lCheckColor then
    gAppPrefs.CheckColor := ColorDialog1.Color
  else
    gAppPrefs.UncheckColor := ColorDialog1.Color;
  SetCheckColor;
 ShowMatrix (false);
end;

procedure TForm1.CheckLeft1Click(Sender: TObject);
 var
   i: integer;
 begin
   if gPrefs.nCheck < 1 then
     exit;
   //if (DefectCheck.Checked) then begin
   for i := 1 to gPrefs.nCheck do
      //.targettype := kNormalTargetType
         if  gPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
          gPrefs.CheckPos[i].checkedDefectMode := true
         else
             gPrefs.CheckPos[i].checkedDefectMode := false;
   for i := 1 to gPrefs.nCheck do
      //.targettype := kNormalTargetType
         if  gPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
          gPrefs.CheckPos[i].checked := true
         else
             gPrefs.CheckPos[i].checked := false;
   Form1.ShowMatrix (false);
end;

procedure TForm1.CheckRight1Click(Sender: TObject);
 var
   i: integer;
 begin
   if gPrefs.nCheck < 1 then
     exit;
   for i := 1 to gPrefs.nCheck do
      //.targettype := kNormalTargetType
         if  gPrefs.CheckPos[i].targettype = kDefectRightTargetType then
          gPrefs.CheckPos[i].checkedDefectMode := true
         else
             gPrefs.CheckPos[i].checkedDefectMode := false;

   for i := 1 to gPrefs.nCheck do
         if  gPrefs.CheckPos[i].targettype = kDefectRightTargetType then
          gPrefs.CheckPos[i].checked := true
         else
             gPrefs.CheckPos[i].checked := false;
     Form1.ShowMatrix (false);
end;

procedure TForm1.CheckedColor1Click(Sender: TObject);
begin
 ChangeColor(true);
end;

procedure TForm1.UncheckedColor1Click(Sender: TObject);
begin
     ChangeColor(false);
end;

procedure TForm1.Editpositions1Click(Sender: TObject);
begin
 gAppPrefs.EditableTargetPositions := Editpositions1.checked;
  if gAppPrefs.EditableTargetPositions then
  {$IFDEF Darwin}
    Showmessage('You can now move the target locations by command+clicking on the test. Option-click to change target type.');
  {$ELSE}
    Showmessage('You can now move the target locations by control+clicking on the test. Option-click to change target type.');
  {$ENDIF}
end; //Editpositions1Click



initialization
{$IFDEF FPC}
  {$I main.lrs}
{$ENDIF}end.

