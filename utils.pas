unit utils;

interface
uses Prefs,SysUtils,dialogs;

const
  kStatSep  = chr(9);
  Type
  TStats4A = record
     Le,Re,Wc,Rc,Lc,Lo,Ro: integer; //allocentricValues: left/right/whole cancelled [c],  errors of commission [e], ommission errors [o]
     FoundWholeEgoLeft, MissedWholeEgoLeft, FoundWholeEgoRight, MissedWholeEgoRight: integer;//egocentricValues
  end;

function StatString (var lPrefs: TPRefs; lTextLabels: boolean; var lCalibratedMean: double): string;
function BoundInt (lV,lMin,lMax: integer): integer;
function AppDirVisible (lDefault: string): string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/ for /folder/myapp.app/app
function FilenameParts (lInName: string; var lPath,lName,lExt: string): boolean;
function AppIniFilename: string;
function IncludesMultiModes (var lPrefs: TPRefs): boolean;
function StartupIniName: string;
function RealToStr(lR: double ; lDec: integer): string;
function  peseverateString(var lPrefs: TPrefs): string;
procedure ClearStats4A (var lA: TStats4A);
procedure AddStats4A (var lPrefs: TPRefs; var lA: TStats4A);
function Compute4A (var lA: TStats4A): string;
function Compute4Ego (var lA: TStats4A): string;


implementation

(*function gammln (xx: extended): extended;  {Numerical Recipes for Pascal, p 177}
const
     stp = 2.50662827465;
var
   x, tmp, ser: double;
begin
     x := xx - 1.0;
     tmp := x + 5.5;
     tmp := (x + 0.5) * ln(tmp) - tmp;
     ser := 1.0 + 76.18009173 / (x + 1.0) - 86.50532033 /
         (x + 2.0) + 24.01409822 / (x + 3.0) - 1.231739516 / (x + 4.0) + 0.120858003e-2 / (x + 5.0) - 0.536382e-5 / (x + 6.0);
     gammln := tmp + ln(stp * ser)
end; //gammln

const
     ITMAX = 300;
     EPS = 3.0e-7;

     procedure gser(var gamser, a,x, gln: real);
     var n: integer;
            sum, del, ap: real;
     begin
          gln := gammln(a);
          if x <= 0.0 then begin
            	if x < 0.0 then Showmessage('x less then 0 in routine GSER');
            	gamser:= 0.0;
          end else begin
            	ap := a;
            	sum := 1.0/a;
            	del := sum;
            	for n := 1 to ITMAX do begin
            		ap := ap + 1;
            		del := del * (x/ap);
            		sum := sum + del;
            		if (abs(del) < abs((sum)*EPS) )then begin
            			gamser := sum * exp(-x+a*ln(x)-gln);
            			exit;
            		end;
            	end;
            	Showmessage('GSER error: ITMAX too small for requested a-value');
          end;
     end; //gser
     *)

const
  kMaxFact = 512; //extended precision limits to <= 1754
  	ITMAX = 300;
	EPS = 3.0e-7;
var
gFactRAready: boolean;

type
	FactRA = array[0..kMaxFact] of extended;
	DataType = Array [1..1] of integer;
	IntPtr= ^DataType;
var
   gFactRA : FactRA;

procedure InitFact;
var lX: word;
begin
	gFactRA[0]:= 1;
	gFactRA[1] := 1;
	for lx := 2 to kMaxFact do
         gFactRA[lx] := lx * gFactRA[lx-1];
	gFactRAready := true;
end;

function gammln (xx: extended): extended;  {Numerical Recipes for Pascal, p 177}
	const
		stp = 2.50662827465;
	var
		x, tmp, ser: double;
begin
	x := xx - 1.0;
	tmp := x + 5.5;
	tmp := (x + 0.5) * ln(tmp) - tmp;
	ser := 1.0 + 76.18009173 / (x + 1.0) - 86.50532033 /
 (x + 2.0) + 24.01409822 / (x + 3.0) - 1.231739516 / (x + 4.0) + 0.120858003e-2 / (x + 5.0) - 0.536382e-5 / (x + 6.0);
{zzz}		gammln := tmp + ln(stp * ser)
end; //procedure gammln}
 procedure gser(var gamser, a,x, gln: real);
var n: integer;
	sum, del, ap: real;
begin
	gln := gammln(a);
	if x <= 0.0 then begin
		if x < 0.0 then ShowMessage('x less then 0 in routine GSER');
		gamser:= 0.0;
	end else begin
		ap := a;
		sum := 1.0/a;
		del := sum;
		for n := 1 to ITMAX do begin
			ap := ap + 1;
			del := del * (x/ap);
			sum := sum + del;
			if (abs(del) < abs((sum)*EPS) )then begin
				gamser := sum * exp(-x+a*ln(x)-gln);
				exit;
			end;
		end;
		ShowMessage('GSER error: ITMAX too small for requested a-value');
	end;
end;

{$IFDEF Darwin}
(*function AppDir: string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/myapp.app/ for /folder/myapp.app/app
var
   lInName,lPath,lName,lExt: string;
begin
 result := '';
 lInName := extractfilepath(paramstr(0));
 lExt := '';
 while (length(lInName) > 0) and (upcase(lExt) <> '.APP')  do begin
       FilenameParts (lInName, lPath,lName,lExt) ;
       lInName := ExpandFileName(lInName + '\..');
 end;
 if (upcase(lExt) = '.APP')  then begin
    result := lPath;//+lName+lExt+pathdelim;
    //showmessage(lPath);
 end;
end; //AppDir*)

function FileNameNoExt (lFilewExt:String): string;
//remove final extension
var
   lLen,lInc: integer;
   lName: String;
begin
	lName := '';
     lLen := length(lFilewExt);
	lInc := lLen+1;
	 if  lLen > 0 then begin
	   repeat
                 dec(lInc);
           until (lFileWExt[lInc] = '.') or (lInc = 1);
	 end;
     if lInc > 1 then
        for lLen := 1 to (lInc - 1) do
            lName := lName + lFileWExt[lLen]
     else
         lName := lFilewExt; //no extension
     Result := lName;
end;

function DefaultsDir (lSubFolder: string): string;
//for Linux: DefaultsDir is ~/appname/SubFolder/, e.g. /home/username/mricron/subfolder/
//Note: Final character is pathdelim
const
     pathdelim = '/';
var
   lBaseDir: string;
begin
     lBaseDir := GetEnvironmentVariable ('HOME')+pathdelim+'.'+ FileNameNoExt(ExtractFilename(paramstr(0) ) );
     if not DirectoryExists(lBaseDir) then begin
        {$I-}
        MkDir(lBaseDir);
        if IOResult <> 0 then begin
               //Msg('Unable to create new folder '+lBaseDir);
        end;
        {$I+}
     end;
     result := lBaseDir+pathdelim;
end;

function AppDirVisible (lDefault: string): string;
begin
 if (length(lDefault) > 0) and DirectoryExists(lDefault) then
    result := lDefault
 else
     result := extractfilepath(paramstr(0));
end; //AppDir

function AppDirHidden: string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/myapp.app/ for /folder/myapp.app/app
begin
 result := DefaultsDir(extractfilename(paramstr(0)));
 //result := extractfilepath(paramstr(0));
end; //AppDir
{$ELSE}
function AppDirVisible: string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/myapp.app/ for /folder/myapp.app/app
begin
 result := extractfilepath(paramstr(0));
end; //AppDir

function AppDirHidden: string; //e.g. c:\folder\ for c:\folder\myapp.exe, but /folder/myapp.app/ for /folder/myapp.app/app
begin
 result := extractfilepath(paramstr(0));
end; //AppDir
{$ENDIF}

function StartupIniName: string;
begin

     result := AppDirHidden+'startup.ini'
end; //StartupIniName

function AppIniFilename: string;
begin
  result := AppDirHidden+ 'cancel.inx'
end; //AppIniFilename

function FilenameParts (lInName: string; var lPath,lName,lExt: string): boolean;
var
   lLen,lPos,lExtPos,lPathPos: integer;
begin
    result := false;
    lPath := '';
    lName := '';
    lExt := '';
    lLen := length(lInName);
    if lLen < 1 then exit;
    //next find final pathdelim
    lPathPos := lLen;
    while (lPathPos > 0) and (lInName[lPathPos] <> '\') and (lInName[lPathPos] <> '/') do
          dec(lPathPos);
    if (lInName[lPathPos] = '\') or (lInName[lPathPos] = '/') then begin
       for lPos := 1 to lPathPos do
           lPath := lPath + lInName[lPos];
    end;
    inc(lPathPos);
    //next find first ext
    lExtPos := 1;
    while (lExtPos <= lLen) and (lInName[lExtPos] <> '.') do
          inc(lExtPos);
    if (lInName[lExtPos] = '.')  then begin
       for lPos := lExtPos to lLen do
           lExt := lExt + lInName[lPos];
    end;
    dec(lExtPos);
    //next extract filename
    if (lPathPos <= lExtPos) then
       for lPos := lPathPos to lExtPos do
           lName := lName + lInName[lPos];
    result := true;
end; //FilenameParts

function BoundInt (lV,lMin,lMax: integer): integer;
begin
  if lMin > lMax then begin
     result := BoundInt(lV,lMax,lMin);
     exit;
  end;
  result := lV;
  if result < lMin then
     result := lMin;
  if result > lMax then
     result := lMax;
end;  //BoundInt

function RealToStr(lR: double ; lDec: integer): string;
begin
     result := FloatToStrF(lR, ffFixed,7,lDec);
end; //RealToStr

function IncludeTarget (lTargetType: integer; lDefectMode: boolean): boolean;
begin
     if (lDefectMode) then
       result :=  (lTargetType <> kNormalTargetType)
     else
         result :=  (lTargetType = kNormalTargetType);
end; //IncludeTarget

function IncludesMultiModes (var lPrefs: TPRefs): boolean;
var
  i: integer;
begin
  result := true;
  if (lPrefs.nCheck < 1) then exit;
  for i := 1 to lPrefs.nCheck do
      if (lPrefs.CheckPos[i].TargetType <> kNormalTargetType) then
        exit;
  result := false;
end; //IncludesMultiModes





procedure gcf(var gammcf: real; a,x, gln: real);
var n: integer;
       gold,fac,b1,b0,a0,g,ana,anf,an,a1: real;
begin
     fac := 1.0;
     b1 := 1.0;
     b0 := 0.0;
     a0 := 1.0;
     gold := 0.0;
     gln := gammln(a);
     a1 := x;
     for n := 1 to ITMAX do begin
       	an :=(n);
       	ana := an - a;
       	a0 := (a1 + a0*ana)*fac;
       	b0 := (b1 + b0*ana)*fac;
       	anf := an * fac;
       	a1 := x*a0+anf*a1;
       	b1 := x*b0+anf*b1;
       	if a1 <> 0 then begin
       		fac := 1.0/a1;
       		g := b1*fac;
       		if (abs((g-gold)/g)<EPS) then begin
       			gammcf := exp(-x+a*ln(x)-gln)*g;
       			exit;
       		end;
       		gold := g;
       end;
     end;
     ShowMessage('GCF error: ITMAX too small for requested a-value');
end; //gcf

function gammq( a,x: real): real;
var
  gamser, gammcf, gln: real;
begin
     gammq := 0;
     if (x < 0) or (a <= 0.0) then
        ShowMessage('Invalid arguments in routine GAMMQ')
     else begin
       	if (x < (a+1.0)) then begin
       		gser(gamser,a,x,gln);
       		gammq := 1.0 - gamser;
       	end else begin
       		gcf(gammcf,a,x,gln);
       		gammq := gammcf;
       	end;
     end;
end; //gammq

procedure Chi2x2 (A, B, C, D: integer; var pMinExp, pChi, p, puChi, pup: extended); {FisherExactTest, use instead of chi}
 {alternate to Chi Square, see Siegel & Castellan, Nonparametric Statistics}
 {use instead of Chi when n <= 20}
 {A= X hits, B= control hits, C = X misses, D = control misses}
 var
    lA, lB, lC, lD, lN: extended;
    lSameOdds: boolean;
 begin
      lA := A; {convert to extended}
      lB := B;
      lC := C;
      lD := D;
      ln := lA + lB + lC + lD;
      if lN > 0 then begin {avoid divide by 0}
         pMinExp := ((lA + lB) * (lA + lC)) / lN;
         if (((lA + lB) * (lB + lD)) / lN) < pMinExp then
            pMinExp := ((lA + lB) * (lB + lD)) / lN;
         if (((lC + lD) * (lA + lC)) / lN) < pMinExp then
            pMinExp := ((lC + lD) * (lA + lC)) / lN;
         if (((lC + lD) * (lB + lD)) / lN) < pMinExp then
            pMinExp := ((lC + lD) * (lB + lD)) / lN;
      end else
          pMinExp := 0;
      lSameOdds := false;
      if (lC > 0) and (lD > 0) then begin
         if (lA / lC) = (lB / lD) then
            lSameOdds := true;
      end;
      if (lC = 0) and (lD = 0) then
         lSameOdds := true;
      if ((lA+lC) = 0) or ((lB+lD) = 0) then
         lSameOdds := true;
      if (lSameOdds = true) then begin
         pChi := 0;   {same odds}
         p := 1.0;
         puChi := 0;
         pup := 1.0;
      end else begin
          puChi := ((sqr((lA * lD) - (lB * lC))) * lN) / ((la + lb) * (lc + ld) * (lb + ld) * (la + lc));
          pup := gammq(0.5, 0.5 * puChi); {half df}
          pChi := ((sqr(abs((lA * lD) - (lB * lC)) - (0.5 * lN))) * lN) / ((la + lb) * (lc + ld) * (lb + ld) * (la + lc));
          p := gammq(0.5, 0.5 * pChi);
      end;
 end; //Chi2x2

function Chi2x2p (nLeftFound,nLeftNotFound,nRightFound,nRightNotFound: integer): double;
var
   pMinExp, pChi, p, puChi, pup: extended;
begin
     Chi2x2 (nLeftFound,nLeftNotFound,nRightFound,nRightNotFound, pMinExp, pChi, p, puChi, pup);
     result := p;
     if (p < 1.0) then begin
        if ( nLeftFound/(nLeftFound+nLeftNotFound)) > ( nRightFound/(nRightFound+nRightNotFound)) then
           result := -p;
     end;
end; //chi2x2p

function ComputeA (var lPrefs: TPrefs; lTextLabels: boolean): string;
var
   Le,Re,Wc,Rc,Lc,i,Lo,Ro: integer;
   a, lChip: double;
begin
     result := '';
     if (lPrefs.nCheck < 1) or (not IncludesMultiModes(lPrefs)) then
        exit;
     Le := 0; //left errors - items with left gap marked as Whole
     Re := 0; //right errors - items with right gap marked as Whole
     Wc := 0; //whole cancelled
     Rc := 0; //right cancelled
     Lc := 0; //left cancelled
     Lo := 0; //left ommissions - items with left gap not cancelled
     Ro := 0; //right ommissions - items with right gap not cancelled
     for i := 1 to lPrefs.nCheck do begin
       if (lPrefs.CheckPos[i].TargetType = kNormalTargetType) and (lPrefs.CheckPos[i].checked) then
          inc(Wc);
       if (lPrefs.CheckPos[i].TargetType = kDefectLeftTargetType) then begin
          if lPrefs.CheckPos[i].checkedDefectMode then
             inc(Lc)  //left cancelled
          else
              inc(Lo); //left omitted
          if lPrefs.CheckPos[i].checked then
              inc(Le);//left error
       end;
       if (lPrefs.CheckPos[i].TargetType = kDefectRightTargetType) then begin
          if lPrefs.CheckPos[i].checkedDefectMode then
             inc(Rc)  //right cancelled
          else
            inc(Ro); //right omitted
          if lPrefs.CheckPos[i].checked then
              inc(Re);//right error
       end;
     end;
     if (Wc = 0) then begin
        result := ' Unable to Compute A: no whole items detected';
        exit;
     end;
     if ((Rc+Lc) = 0) then begin
        result := ' Unable to Compute A: no defective items detected';
        exit;
     end;
     a := ((Le-Re)/Wc + (Rc-Lc)/(Rc+Lc))/2;
     lChip :=  Chi2x2p(Lc,Lo,Rc,Ro);
     {if (lTextLabels) then
        result := ' Le: '+inttostr(le)+ ' Re: '+inttostr(re)+ ' Wc: '+inttostr(wc)+
        ' Lc: '+inttostr(Lc)+ ' Rc: '+inttostr(rc)+
        ' a: '+floattostr(a)
       }
     if (lTextLabels) then
        result := ' a: '+floattostr(a) //+' alloChi: '+floattostr(lChip)
     else
        result :=  floattostr(a)+ kStatSep+floattostr(lChip);;
end; //ComputeA



procedure ClearStats4A (var lA: TStats4A);
begin
   lA.Wc := 0; //whole cancelled
   lA.Lc := 0; //left cancelled
   lA.Le := 0; //left error of commission
   lA.Lo := 0; //left error of ommission
   lA.Rc := 0;
   lA.Re := 0;
   lA.Ro := 0;
   lA.FoundWholeEgoLeft := 0;
   lA.MissedWholeEgoLeft := 0;
   lA.FoundWholeEgoRight := 0;
   lA.MissedWholeEgoRight   := 0;
end;

function FindMidX (var lPrefs: TPrefs): integer;
//returns midpoint of page, in whatever units specified by test
var
   i,x,lMaxX,lMinX: integer;
begin
     result := 0;
     if lPrefs.nCheck < 1 then exit;
     lMinX := lPrefs.CheckPos[1].X;
     lMaxX := lMinX;
     for i := 1 to lPrefs.nCheck do begin
         x := lPrefs.CheckPos[i].X;
         if x > lMaxX then
            lMaxX := x;
         if x < lMinX then
            lMinX := x;
  end; //for each item
  result := lMinX + ((lMaxX-lMinX) div 2);

end;

procedure AddStats4A (var lPrefs: TPRefs; var lA: TStats4A);
var
   i, MiddleOfPage: integer;
begin
     //
     MiddleOfPage := FindMidX(lPrefs);
     for i := 1 to lPrefs.nCheck do begin
       if (lPrefs.CheckPos[i].TargetType = kNormalTargetType) then begin //ego values
          if (lPrefs.CheckPos[i].checked) then begin //detected
             if (lPrefs.CheckPos[i].X >MiddleOfPage) then //on right side
                inc(lA.FoundWholeEgoRight)
             else
                inc(lA.FoundWholeEgoLeft) ;
          end else begin //undected
            if (lPrefs.CheckPos[i].X >MiddleOfPage) then //on right side
               inc(lA.MissedWholeEgoRight)
            else
               inc(lA.MissedWholeEgoLeft) ;

          end; //if detected else undetected
       end; //ego values
       if (lPrefs.CheckPos[i].TargetType = kNormalTargetType) and (lPrefs.CheckPos[i].checked) then
          inc(lA.Wc);
       if (lPrefs.CheckPos[i].TargetType = kDefectLeftTargetType) then begin
          if lPrefs.CheckPos[i].checkedDefectMode then
             inc(lA.Lc)  //left cancelled
          else
              inc(lA.Lo); //left omitted
          if lPrefs.CheckPos[i].checked then
              inc(lA.Le);//left error
       end;
       if (lPrefs.CheckPos[i].TargetType = kDefectRightTargetType) then begin
          if lPrefs.CheckPos[i].checkedDefectMode then
             inc(lA.Rc)  //right cancelled
          else
            inc(lA.Ro); //right omitted
          if lPrefs.CheckPos[i].checked then
              inc(lA.Re);//right error
       end;
     end; //for each item
end;

function NChooseR (pN, pR: word): extended;
{var Lextended: extended; }
begin
     if not gFactRAready then InitFact;
     NChooseR := 0;
     if pN <= kMaxFact then
        NChooseR := (gFactRA[pN] )/(gFactRA[pR]*gFactRA[pN-pR]);
{     NChooseR := (subtractorial(pN,(pN-pR)) / (factorial(pR)) ); }
end;
function Power(B, E:extended): extended;
begin
    Power := 0;
    if B > 0 then
       Power := Exp(E * Ln(B) );
end;
function BinomialProb(pN, pNHits: integer): extended; {pn > 1}
{probability of pHits or more in pN attempts}
{pNHits could be between 0 and pN}
{single tail test, double value for 2 tails}
var
   lProb : extended;
   lHitCnt, lnHits: integer;
begin
     if pnHits <= (pN div 2) then
        lnHits := pN - pnHits
     else lnHits := pnHits;
     LProb := 0;
     for lHitCnt := pN downto lNHits do
         LProb := lProb + NChooseR(pN, lHitCnt)*(power(0.5,lHitCnt) )*(Power(0.5,(pN-lHitCnt) ) );
     if lProb > 1 then lProb := 1;
	 BinomialProb := lProb;
end;


function Compute4A (var lA: TStats4A): string;
var
   lChip, a: single;
   Sig: integer;
begin


if ((lA.Rc+lA.Lc) = 0) then begin
   result := 'Unable to Compute A: no defective items detected'+kStatSep+'n/a'+kStatSep+'n/a';
   exit;
end;
lChip :=  Chi2x2p(lA.Lc,lA.Lo,lA.Rc,lA.Ro);
if abs(lChip) < 0.05 then
   Sig := 1
else
    Sig := 0;
if (lA.Wc = 0) then begin
   result := 'Unable to Compute A: no whole items detected'+kStatSep+floattostr(lChip)+kStatSep+inttostr(Sig);
   exit;
end;
if ( ((lA.Le+lA.Re)/2) >= lA.Wc) then begin
   result := 'Unable to Compute A: participant is marking at least as many broken items as whole as they are finding whole items'+kStatSep+floattostr(lChip)+kStatSep+inttostr(Sig);
   exit;
end;

a := ((lA.Le-lA.Re)/lA.Wc + (lA.Rc-lA.Lc)/(lA.Rc+lA.Lc))/2;
result := 'Wc:'+kStatSep+inttostr(lA.Wc)+kStatSep +'Le:'+kStatSep+inttostr(lA.Le)+kStatSep+'Re:'+kStatSep+inttostr(lA.Re)
+kStatSep+'Lc:'+kStatSep+inttostr(lA.Lc)+kStatSep+'Rc:'+kStatSep+inttostr(lA.Rc);


result :=  floattostr(a)+ kStatSep+floattostr(lChip)+kStatSep+inttostr(Sig);
end;

function Compute4Ego (var lA: TStats4A): string;
var
   lChip: single;
   Sig: integer;
begin
     lChip :=  Chi2x2p(lA.FoundWholeEgoLeft,lA.MissedWholeEgoLeft,lA.FoundWholeEgoRight,lA.MissedWholeEgoRight);
     if abs(lChip) < 0.05 then
        Sig := 1
     else
         Sig := 0;

     result :=  floattostr(lA.FoundWholeEgoLeft)+ kStatSep+floattostr(lA.MissedWholeEgoLeft)+ kStatSep+ floattostr(lA.FoundWholeEgoRight)+ kStatSep+floattostr(lA.MissedWholeEgoRight)
            +kStatSep+floattostr(lChip)+kStatSep+inttostr(Sig);



end;

(*  lA.FoundWholeEgoLeft := 0;
lA.MissedWholeEgoLeft := 0;
lA.FoundWholeEgoRight := 0;
lA.MissedWholeEgoRight   := 0; *)

function  peseverateString(var lPrefs: TPrefs): string;
begin
  result := '0';
  if lPrefs.Perseverate then
    result := '1';
end;

type
  TStat = record
    	nTotal, nMarked: integer;
        maxX, minX, sumXTotal, sumXMarked: single;

  end;

procedure initStat(var Stat: TStat);
begin
    Stat.maxX := -maxint;
    Stat.minX := maxint;
    Stat.sumXTotal := 0;
    Stat.nTotal := 0;
    Stat.sumXMarked := 0;
    Stat.nMarked := 0;
end;

procedure addStat(X: integer; marked: boolean; var Stat: TStat);
begin
    if X < Stat.minX then stat.minX := X;
    if X > Stat.maxX then stat.maxX := X;
    Stat.sumXTotal := Stat.sumXTotal + X;
    Stat.nTotal := Stat.nTotal + 1;
    if not marked then exit;
    Stat.sumXMarked := Stat.sumXMarked + X;
    Stat.nMarked := Stat.nMarked + 1;
end;

function simpleCoC(MinX, MaxX: single; var Stat: TStat): single;
var
   rangeX, x: single;
begin
  rangeX := maxX - minX;
  x := Stat.sumXMarked - (Stat.nMarked * minX); //0...range
  x := x /  (Stat.nMarked * rangeX);   //0..1
  result := (x * 2) -1;
end;

function StatStr(Title: string; Stat: TStat; isCoc: boolean = false): string;
var
  rangeX, x, CoC: single;
begin
    result := '';
    if Stat.nTotal < 1 then exit;

    result := format('%s %d/%d ', [Title, Stat.nMarked, Stat.nTotal]);
    if not isCoc then exit;
    CoC := 0.0;
    if (Stat.nMarked < 1) or (Stat.minX >= Stat.maxX) then exit;
    rangeX := Stat.maxX - Stat.minX;
    x := Stat.sumXMarked - (Stat.nMarked * Stat.minX); //0...range
    x := x /  (Stat.nMarked * rangeX);   //0..1
    CoC := (x * 2) -1;
    //CoC := x / Stat.nMarked;
    //CoC := x / (Stat.maxX-Stat.minX); //0..1
    //CoC := (2 * CoC) - 1.0;
    result := result + format('CoC %g ', [CoC]);
end;


function CopyA(L,R: TStat): string;
var
  A: single;
begin
    if ( R.nMarked + L.nMarked) < 1 then exit ('A = 0.0');
    A := ((R.nMarked - L.nMarked))  / ( R.nMarked + L.nMarked);
    result:=format(' A: %g ', [A]);

end;

function StatStringCopy (var lPrefs: TPrefs; lTextLabels: boolean; var lCalibratedMean: double): string;
var
   L,R,All: TStat;
   i, x: integer;
begin
  if lPrefs.nCheck  < 1 then exit;
  initStat(L);
  initStat(R);
  initStat(All);
  for i := 1 to lPrefs.nCheck do begin
    x := lPrefs.CheckPos[i].X;
    addStat(x, lPrefs.CheckPos[i].Checked, All);
    if lPrefs.CheckPos[i].targettype = kDefectLeftTargetType then
       addStat(x, lPrefs.CheckPos[i].Checked, L);
    if lPrefs.CheckPos[i].targettype = kDefectRightTargetType then
       addStat(x, lPrefs.CheckPos[i].Checked, R);
  end;
  result := StatStr('All',All, true)+ StatStr('L',L)+StatStr('R',R)+CopyA(L,R);
  if L.nTotal <> R.nTotal then
     result := result + format(' not balanced %d L and %d R items', [L.nTotal, R.nTotal]);

end;

function StatString (var lPrefs: TPrefs; lTextLabels: boolean; var lCalibratedMean: double): string;
const
     lDefectMode = false;
var
  //Mode has three values -   kNormalAllType, kNormalTargetType, kAltTargetType
  //Mode of kNormalAllType returns CoC for all items, whereas kNormalTargetType and kAltTargetType return CoC values only for these items....
  allStat: TStat;
  lChecked : boolean;
  nLeftFound,nLeftNotFound,nRightFound,nRightNotFound: integer;
  n, y,lnChecked,lMinY,lMaxY,lMinX,lMaxX,lRangeX,lRangeY ,i,x: integer;
  peseverateTxt : string;
  lCalibratedMeanY, lSumCheckedCaly,lSumCalY,ycal,{lLateralityIndex,}xcal,lSumCal, lSumCheckedCal,lMeanPix,lSum,lSumChecked,lChiP: double;
begin
  result := '';
  peseverateTxt := peseverateString(lPrefs);
  if lPrefs.CopyTask then begin
     result :=  StatStringCopy (lPrefs, lTextLabels, lCalibratedMean);//+ kStatSep+peseverateTxt;
     exit;
  end;
  if lPrefs.nCheck < 1 then
    exit;
  nLeftFound := 0; nLeftNotFound := 0; nRightFound := 0; nRightNotFound := 0;
  lSum := 0;
  lSumChecked := 0;
  lSumCal := 0;
  lSumCheckedCal := 0;
  lSumCaly := 0;
  lSumCheckedCaly := 0;
  lMaxY := 0;
  lMinY := maxint;
  lMaxX := 0;
  lMinX := maxint;
  lnChecked := 0;
  //first pass - find min and max
  n := 0;
  for i := 1 to lPrefs.nCheck do begin
    if IncludeTarget (lPrefs.CheckPos[i].TargetType, lDefectMode) then begin
      inc(n);
      x := lPrefs.CheckPos[i].X;
      if x > lMaxX then
        lMaxX := x;
      if x < lMinX then
        lMinX := x;
      y := lPrefs.MaxY-lPrefs.CheckPos[i].y;
      if y > lMaxy then
        lMaxy := y;
      if y < lMiny then
        lMinY := y;
    end; //only included...
  end; //for each item
  if n = 0 then
    exit; //no targets of targettype specified by Mode
  lRangeX := lMaxX - lMinX;
  lRangeY := lMaxY - lMinY;
  //lMidx := round((lRangeX/2)+lMinX);
  //lMidy := round((lRangeY/2)+lMinY);
  if (lRangeX = 0) or (lRangeY = 0) then
    exit;
  initStat(allStat);
  //second pass - find values...
  for i := 1 to lPrefs.nCheck do begin
    addStat(lPrefs.CheckPos[i].X, lPrefs.CheckPos[i].checked, allStat);

    addStat(lPrefs.CheckPos[i].X, lPrefs.CheckPos[i].checkedDefectMode, allStat);

    if IncludeTarget (lPrefs.CheckPos[i].TargetType, lDefectMode) then begin
      x := lPrefs.CheckPos[i].X;
      //lPrefs.CheckPos[i].checked;
      lSum :=lSum + x;
      if lDefectMode then
         lChecked := lPrefs.CheckPos[i].checkedDefectMode
      else
          lChecked := lPrefs.CheckPos[i].checked;
      if lChecked then begin
        lnChecked := lnChecked + 1;
        lSumChecked := lSumChecked + x;
        //if x < lMidX then
        //  inc(lnLeftChecked);
      end;
      xcal :=  (x-lMinX)/lRangex;
      lSumCal :=lSumCal + xcal;
      if (xcal > 0.5) then begin //right side
        if lChecked then
           inc(nRightFound)
        else
            inc(nRightNotFound);
      end else begin //if right else left side
        if lChecked then
           inc(nLeftFound)
        else
            inc(nLeftNotFound);
      end;

      if lChecked then
        lSumCheckedCal := lSumCheckedCal + xcal;
      ycal :=  ( (lPrefs.MaxY-lPrefs.CheckPos[i].Y)-lMinY)/lRangeY;
      lSumCaly :=lSumCaly + ycal;
      if lChecked then
        lSumCheckedCaly := lSumCheckedCaly + ycal;
    end;//only included targets
  end; //for each item
  //now compute stats
  if (lSum = 0) or (lnChecked = 0) then begin
    lMeanPix := 0;
    lCalibratedMean :=0;
    lCalibratedMeanY := 0;
    //lLateralityIndex := 0.5;
  end else begin
    lMeanPix := lSumChecked/lnChecked;
    //calibrate - minimum value is zero...
    lCalibratedMean := 2* (lSumCheckedCal/lnChecked - lSumCal/n);
    lCalibratedMeanY := 2* (lSumCheckedCalY/lnChecked - lSumCalY/n);
    //lLateralityIndex := lnLeftChecked/n;
  end;
   lChip := Chi2x2p(nLeftFound,nLeftNotFound,nRightFound,nRightNotFound);
  if lTextLabels then
    result := 'CoC: '+RealToStr( lCalibratedMean,3)+' TargetsFound: '+floattostr(lnChecked)+' Targets: '+floattostr(n)+' Name: '+lPrefs.IniName +  ComputeA(lPrefs,lTextLabels)
  else
    result := floattostr( lMeanPix)+kStatSep+floattostr( lCalibratedMean)+kStatSep+floattostr(lnChecked)+kStatSep+floattostr(n)+kStatSep+floattostr( lCalibratedMeanY) + kStatSep+lPrefs.ImageName  + kStatSep+lPrefs.INIname
    +kStatSep+floattostr(nLeftFound)+kStatSep+floattostr(nLeftNotFound)+kStatSep+floattostr(nRightFound)+kStatSep+floattostr(nRightNotFound)+kStatSep+floattostr( lChiP )
    +kStatSep+  ComputeA(lPrefs,lTextLabels)+kStatSep+peseverateTxt;
  if AllStat.nMarked > 0 then begin
    result := result +kStatSep+ 'CoC_All'+kStatSep+floattostr(simpleCoC(lMinX, lMaxX, allStat));

  end;


end; //StatString


begin
  gFactRAready := false;
end.
