unit main;
{$IFDEF FPC} {$mode delphi}{$H+}  {$ENDIF}
interface

uses
  Classes, SysUtils,   Forms, Controls, Graphics, Dialogs,  StrUtils,
  Menus, StdCtrls, ExtCtrls, ComCtrls, Buttons, utils, prefs,Messages,
  {$IFDEF FPC}
  LResources, ToolWin
  {$ELSE}
  Windows,o_FormEvents, jpeg, ShellAPI,PNGIMage //, ToolWin
  {$ENDIF} ;

type

  { TForm1 }

  TForm1 = class(TForm)
    //DefectCheck: TCheckBox;
    ColorDialog1: TColorDialog;
    CommentEdit: TEdit;
    Image1: TImage;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    File1: TMenuItem;
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
    procedure DefectCheckChange(Sender: TObject);
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
    procedure Newtest1Click(Sender: TObject);
    procedure Opendata1Click(Sender: TObject);
    procedure CopyStats1Click(Sender: TObject);
    procedure RestoreTimerTimer(Sender: TObject);
    procedure OnRestoreX(Sender: TObject);
    procedure Reversechecks1Click(Sender: TObject);
    procedure Savedata1Click(Sender: TObject);
    procedure Showcaptions1Click(Sender: TObject);
    procedure Showcomment1Click(Sender: TObject);
    procedure Showimage1Click(Sender: TObject);
    procedure ColorBtn(i: integer);
    procedure ColorBtnPaint(Sender: TObject); 
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
  gAppPrefs: TAppPrefs;
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

function ImageFullPath(S: string): string;
begin
  result := S;
  if not (fileexists(result)) then
     result  := AppDir +extractfilename(S);
  if not (fileexists(result)) then
     result  :=  gPrefs.inipath +pathdelim+extractfilename(S);
  if not (fileexists(result)) then
     Showmessage('Unable to find '+S+'. Please put this picture into the folder '+AppDir );
end;

procedure TForm1.ShowMatrix (lReloadImage: boolean);
var
  i,lx,ly: integer;
  lImgName : string;
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
  if gPrefs.nCheck < kMaxCheck then begin
    for i := (gPrefs.nCheck+1) to kMaxCheck do begin
      with gCheckArray[i] do
        Visible := false;
      end;
  end;
  if (gPrefs.nCheck < 1) {or (lw < 1) or (lh < 1) or (gPrefs.MaxY < 1) or (gPrefs.MaxX < 1)} then
    exit;
  if (IncludesMultiModes(gPrefs)) then begin
    DefectCheck.visible := true;
    DefectCheck.Checked := gPrefs.MarkDefectMode;
  end else begin
      DefectCheck.visible := false;
      gPrefs.MarkDefectMode  :=false;
  end;
  for i := 1 to gPrefs.nCheck do begin
    with gCheckArray[i] do begin
      if gPrefs.CaptionVisible then
        Caption := inttostr(i)
      else
        Caption := '';
        //OnClick := DoChange;
      if (gPrefs.MarkDefectMode) then begin
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
    gCheckArray[i].Repaint;
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
  if FindFirst(AppDir+'*.ini', faAnyFile, searchResult) = 0 then
    result := AppDir+searchResult.Name;
  SysUtils.FindClose(searchResult);
end; //DefaultTestFilename

procedure TForm1.OpenTest(lIniName: string);
var
  lStr: string;
begin
  if fileexists (lIniName) then
    IniFile(true, lIniName, gPrefs)
  else begin
    lStr := DefaultTestFilename;
    if lStr <> '' then
      IniFile(true, lStr, gPrefs)
    else
      showmessage(extractfiledir(paramstr(0))+' is unable to find any tests: please choose File/Open');
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
    lAlloStr :=kStatSep + 'Allocentric_A_Index'+kStatSep+'Allocentric_Chi^2_pValue'
 else
     lAlloStr := '';
 Form1.Memo1.lines.Add('CoC[Horizontal Pixels]'+kStatSep+'CoC[Horizontal Calibrated]'+kStatSep+'NumCancelled'+kStatSep+'NumTargets'+kStatSep+'CoC[A-P Calibrated]'+kStatSep+'ImageName'+kStatSep+'FileName'
 +kStatSep+'nLeftFound'+kStatSep+'nLeftNotFound'+kStatSep+'nRightFound'+kStatSep+'nRightNotFound'+kStatSep+'Chi^2_pValue_LeftFound/Not_v_RightFound/Not_Negative_Means_More_Right_Ommisions'+lAlloStr );
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
begin
     result := '';
     if not fileexists (lFileName) then exit;
     if not AnsiContainsText(lFilename, '_B') then begin
        result := DualStat2(lFilename);
        exit;
     end;
     result := AnsiReplaceStr(lFilename, '_B', '_S');
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
 +'AlloA'+kStatSep+'AlloChiProb'+kStatSep+'AlloChiSig');
end;
{$ENDIF}

procedure TForm1.Statistics1Click(Sender: TObject);
var
  lPrefs: TPrefs;
  lCoC,lCoCpair: double;
  I: integer;
  lFilename,lFilenamePair: string;
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
      if lFilenamePair <> '' then begin
         ClearStats4A (lA);
         IniFile(true, lFileName, lPrefs);
         StatString(lPrefs,false,lCoC );
         AddStats4A (lPrefs, lA);
         IniFile(true, lFilenamePair, lPrefs);
         StatString(lPrefs,false,lCoCpair ) ;
         AddStats4A (lPrefs, lA);


        Memo1.Lines.Add(extractfilename(lFileName)+kStatSep+extractfilename(lFilenamePair)+kStatSep+RealToStr(lCoC,3 )+kStatSep+RealToStr(lCoCpair,3 )+kStatSep+RealToStr((lCoC+lCoCpair)/2,3)
            +kStatSep+Compute4Ego(lA)+kStatSep+Compute4A(lA));

      end else if fileexists (lFileName) then begin
       {$IFDEF DOPAIR}
      //do nothing
      {$ELSE}
      IniFile(true, lFileName, lPrefs);
      Memo1.Lines.Add(StatString(lPrefs,false,lCoC ));
      {$ENDIF}

      end;

    end;
     OpenDialog1.Options := [];
     Memo1.SelectAll;
     Memo1.CopyToClipboard;
     Showmessage('Data has been copied to the clipboard.');
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
             gPrefs.CheckPos[i].checked := false;
  end;
  Form1.ShowMatrix (false);
end; //ChangeCheckAll

procedure TForm1.Uncheckall1Click(Sender: TObject);
begin
     ChangeCheckAll(false);
end; //ChangeCheckAll

procedure TForm1.About1Click(Sender: TObject);
begin
  Showmessage(kVersion)
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

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
     {$IFDEF Darwin}
     OpenData1.ShortCut := ShortCut(Word('O'),[ssMeta]);
     SaveData1.ShortCut := ShortCut(Word('S'),[ssMeta]);
     Checkall1.ShortCut := ShortCut(Word('A'),[ssMeta]);
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
     Opentest(StartupIniName);
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

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
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
 BmpOpenDialog.InitialDir := AppDir {extractfiledir(paramstr(0))};
 if not BmpOpenDialog.Execute then
    exit;
 lS := extractfilename(BmpOpenDialog.FileName);
 lS := ImageFullPath(lS);
 if not fileexists(lS) then begin
  Showmessage('Unable to find '+lS+'. Please put this picture into the folder '+extractfiledir(paramstr(0)) );
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
 else
     gPrefs.CheckPos[i].checked := not gPrefs.CheckPos[i].checked;
 {$IFDEF FPC}
 gCheckArray[i].Repaint;
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
    Showmessage('You can now move the target locations by command+clicking on the test.');
  {$ELSE}
    Showmessage('You can now move the target locations by control+clicking on the test.');
  {$ENDIF}
end; //Editpositions1Click



initialization
{$IFDEF FPC}
  {$I main.lrs}
{$ENDIF}end.
