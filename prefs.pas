unit prefs;
{$H+}

interface
uses IniFiles,SysUtils,graphics,Dialogs,Classes;

const
  kMaxCheck = 256;
  kVersion ='29 June 2013 :: Chris Rorden :: www.mricro.com';
  kNormalAllType = 0;
  kNormalTargetType = 1;
  kDefectLeftTargetType = 2;
  kDefectRightTargetType = 3;
type
  TCheckPoint = record
    x,y,targettype: integer;
    checked,checkedDefectMode: boolean;
  end;
  TAppPrefs = record
         CheckColor, UncheckColor: integer;
         EditableTargetPositions,CommentVisible: boolean;
  end;
  TPrefs = record
         MaxX,MaxY,nCheck,Size: integer;
         ImageVisible,CaptionVisible,MarkDefectMode: boolean;
         Comment,ImageName,Version,INIname,INIpath: string;
        CheckPos : array [1..kMaxCheck] of TCheckPoint;
  end;
procedure SetDefaultAppPrefs (var lPrefs: TAppPrefs);
function AppIniFile(lRead: boolean; lFilename: string; var lPrefs: TAppPrefs): boolean;
function IniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;
procedure SetDefaultPrefs (var lPrefs: TPrefs);
function Bool2Char (lBool: boolean): char;

implementation

uses utils;

procedure SetDefaultPrefs (var lPrefs: TPrefs);
var
  i: integer;
begin
  with lPrefs do begin
    ImageName := '';
    ININame := 'Unsaved';
    INIpath := extractfiledir(AppDir);
    Comment := '';
    Version := kVersion;
    CaptionVisible := false;
    ImageVisible := false;
    MarkDefectMode := false;
    Size :=24;
    MaxX := 320;
    MaxY := 240;
    nCheck := 10;
    for i := 1 to kMaxCheck do begin
      CheckPos[i].x := random (320);
      CheckPos[i].y := random (240);
      CheckPos[i].targettype := kNormalTargetType;
      CheckPos[i].checked := true;
      CheckPos[i].checkedDefectMode := true;
    end;
  end;//with lPrefs
end; //SetDefaultPrefs

const
  kStrSep = '|';

procedure IniFloat(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: single);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('FLT',lIdent,FloattoStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('FLT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToFloat(lStr);
end; //IniFloat

procedure IniByte(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: byte);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('BYT',lIdent,InttoStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('BYT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToInt(lStr);
end; //IniFloat

function Bool2Char (lBool: boolean): char;
begin
     if lBool then
        result := '1'
     else
         result := '0';
end; //Bool2Char

function Char2Bool (lChar: char): boolean;
begin
	if lChar = '1' then
		result := true
	else
		result := false;
end;  //Char2Bool

procedure IniInt(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: integer);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('INT',lIdent,IntToStr(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('INT',lIdent, '');
	if length(lStr) > 0 then
		lValue := StrToInt(lStr);
end; //IniInt

procedure IniBool(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: boolean);
//read or write a boolean value to the initialization file
var
	lStr: string;
begin
        if not lRead then begin
           lIniFile.WriteString('BOOL',lIdent,Bool2Char(lValue));
           exit;
        end;
	lStr := lIniFile.ReadString('BOOL',lIdent, '');
	if length(lStr) > 0 then
	   lValue := Char2Bool(lStr[1]);
end; //IniBool

procedure IniStr(lRead: boolean; lIniFile: TIniFile; lIdent: string; var lValue: string);
//read or write a string value to the initialization file
begin
  if not lRead then begin
    lIniFile.WriteString('STR',lIdent,lValue);
    exit;
  end;
	lValue := lIniFile.ReadString('STR',lIdent, '');
end; //IniStr

function CheckPointToStr (lU: TCheckPoint; lIncludesMultiModes: boolean) : string;
//floatrect values 0..1 convert to byte 0..1
begin
  if not lIncludesMultiModes then
    result := Inttostr(lU.x)+ kStrSep+Inttostr(lU.y)+ kStrSep+Bool2Char(lU.Checked)
  else
    result := Inttostr(lU.x)+ kStrSep+Inttostr(lU.y)+ kStrSep+Bool2Char(lU.Checked)+ kStrSep+Inttostr(lU.targettype)+ kStrSep+Bool2Char(lU.checkedDefectMode);
end; //CheckPointToStr

function StrToCheckPoint(lS: string; var lU: TCheckPoint): boolean;
//each location defined by 3 parameters: X,Y,checked
var
  lV: string;
  lI,lLen,lP,lN: integer;
begin
  result := false;
  lLen := length(lS);
  if lLen < 7 then  //shortest possible: 1|1|1|1 or 0|0|0|0
    exit;
  lV := '';
  lP := 1;
  lN := 0;
  lU.targettype := kNormalTargetType;
  while (lP <= lLen) do begin
    if lS[lP] in ['0'..'9'] then
      lV := lV + lS[lP];
    if (lV <> '') and ((lP = lLen) or (not (lS[lP] in ['0'..'9']))) then begin
        inc(lN);
        lI := strtoint(lV);
        case lN of
          1: lU.X := lI;
          2: lU.Y := lI;
          3: lU.Checked := Char2Bool(lV[1]);
          4: lU.targettype := lI;
          5: lU.checkedDefectMode := Char2Bool(lV[1]);
        end;
        lV := '';
    end;
    inc(lP);
  end;
  if lN >= 5 then
    result := true;
end; //StrToCheckPoint

procedure IniCheckPoint(lRead: boolean; lIniFile: TIniFile; lIdent: string;  var lValue: TCheckPoint; lIncludesMultiModes: boolean);
//read or write an integer value to the initialization file
var
	lStr: string;
begin
  if not lRead then begin
    lIniFile.WriteString('Check',lIdent,CheckPointToStr(lValue,lIncludesMultiModes));
    exit;
  end;
	lStr := lIniFile.ReadString('Check',lIdent, '');
  StrToCheckPoint(lStr,lValue);
end; //IniCheckPoint

function IniFile(lRead: boolean; lFilename: string; var lPrefs: TPrefs): boolean;
//Read or write initialization variables to disk
var
  lIniFile: TIniFile;
  lI: integer;
  lIncludesMultiModes: boolean;
begin
  result := false;
  if lRead then
     SetDefaultPrefs(lPrefs);
  if (lRead) and (not Fileexists(lFilename)) then
        exit;
  lIniFile := TIniFile.Create(lFilename);
  if lRead then
     lIncludesMultiModes := false //value only used for writing, ignored for reads
  else
      lIncludesMultiModes := IncludesMultiModes(lPrefs);
  lPrefs.INIname := changefileext(extractfilename(lFilename),'');
  lPrefs.IniPath  := extractfiledir(lFilename);
  if not lRead then
    lPrefs.ImageName := extractfilename(lPrefs.ImageName);
  IniStr(lread,lIniFile,'ImageName',lPrefs.ImageName);
  if lRead then
    lPrefs.ImageName := extractfilename(lPrefs.ImageName);
  IniStr(lread,lIniFile,'Comment',lPrefs.Comment);
  IniBool(lRead,lIniFile,'CaptionVisible',lPrefs.CaptionVisible);
  IniBool(lRead,lIniFile,'ImageVisible',lPrefs.ImageVisible);
  IniBool(lRead,lIniFile,'MarkDefectMode',lPrefs.MarkDefectMode);
  IniInt(lRead,lIniFile, 'MaxX',lPrefs.MaxX);
  IniInt(lRead,lIniFile, 'MaxY',lPrefs.MaxY);
  IniInt(lRead,lIniFile, 'nCheck',lPrefs.nCheck);
  if lPrefs.nCheck < 1 then
    lPrefs.nCheck := 1; //avoid possible divide by zero problems...
  if lPrefs.nCheck > 0 then
    for lI := 1 to  lPrefs.nCheck do
      IniCheckPoint(lRead,lIniFile, 'Point'+inttostr(lI),lPrefs.CheckPos[lI],lIncludesMultiModes);
  lIniFile.Free;
end;//IniFile

procedure SetDefaultAppPrefs (var lPrefs: TAppPrefs);
var
  i: integer;
begin
  with lPrefs do begin
    CheckColor := $0F2F0F;//$80FF80; //$80FF80;
    UnCheckColor := $DFD0D0;//$FF;
    CommentVisible := false;
    //MarkDefectMode := false;
    EditableTargetPositions := false;
  end;
end;  //SetDefaultAppPrefs

function AppIniFile(lRead: boolean; lFilename: string; var lPrefs: TAppPrefs): boolean;
var
  lIniFile: TIniFile;
  lI: integer;
begin
  result := false;
  if lRead then
     SetDefaultAppPrefs(lPrefs);
  if (lRead) and (not Fileexists(lFilename)) then
        exit;
  lIniFile := TIniFile.Create(lFilename);
  IniInt(lRead,lIniFile, 'CheckedColor',lPrefs.CheckColor);
  IniInt(lRead,lIniFile, 'UncheckedColor',lPrefs.UncheckColor);
  IniBool(lRead,lIniFile,'CommentVisible',lPrefs.CommentVisible);
  lIniFile.Free;
end; //AppIniFile

end.