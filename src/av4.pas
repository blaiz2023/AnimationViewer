unit av4;
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//##
//## Please note: This is legacy code and is designed to compile in Borland Delphi 3
//##
//##############################################################################
//## Name........ Animation Viewer
//## Desciption.. Easily views animations
//## Items....... 1
//## Version..... -
//## Date........ -
//## Lines....... 975
//##
//## ======================================================================================
//## | Name                   | Base Type          | Version   | Date        | Desciption
//## |------------------------|--------------------|-----------|-------------|----------------
//## | tanimationviewer       | tvirtualpage       | 1.00.1288 | 05-MAR-2008 | Views animations
//## ====================================================================================
//##
//## Language Enabled
//##############################################################################

interface
{$align on}{$iochecks on}{$O+}{$W-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }

Uses
  Windows, Forms, SysUtils, Classes, Graphics, clipbrd, av2, av3;

const
    vspFrameimage                       =vsProgramBASE+0;
    vspPotTol                           =vsProgramBASE+1;
    vspUsePreviewBgcolor                =vsProgramBASE+3;
    vspPreviewBgcolor                   =vsProgramBASE+4;
    vspShowTools                        =vsProgramBASE+5;
    vspSendFolder1                      =vsProgramBASE+6;
    vspSendFolder2                      =vsProgramBASE+7;
    vspReplacePrompt1                   =vsProgramBASE+8;
    vspReplacePrompt2                   =vsProgramBASE+9;
    vspScrollDelay                      =vsProgramBASE+10;
    vspScrollFlash                      =vsProgramBASE+11;
    vspRetainSaveAsFormat               =vsProgramBASE+12;
    vspRetainSaveAsFormat1              =vsProgramBASE+13;
    vspRetainSaveAsFormat2              =vsProgramBASE+14;
    //masks
    vspImageMasks                       =vsProgramBASE+30;//from this point and upwards - depends on number of supported formats specified by "tmisc.imageexts"

type
{tanimationviewer}
    tanimationviewer=class(tvirtualpagevsplit)
    private
     isendpath1,isendpath2,ifilename1,ifilename2,tsFilename,tsFps,tsCells,tsSize,tsBytes,tsW,tsH:string;
     ishowtools,iretainsaveasformat,iretainsaveasformat1,iretainsaveasformat2,iscrollflash,iscrolltoggle,iscrolling,iscrollingup,ireplace1,ireplace2,ilocked,ionce:boolean;
     itime2:currency;
     ibgcolor,itrans,ifps20,ifps10,ifps7,ifps4,ifps2,ifps1,ieditsan,istatus,ifaster,islower,isave,isaveas,icopy,icopyall,icopyalltext,icopyb64,ipasteall,ipastenew:tvirtualcontrol;
     iscrollup,iscrolldn,istop:tvirtuallink;
     isend1,isendf1,ipastefrom1,ipastefrom2,isaveas1,isend2,isendf2,isaveas2,irename,itrim:tvirtualcontrol;
     ipottol:byte;
     itimer2:integer;
     iviewer:tvirtualanimationviewer;
     iflip,imirror,itransparent:tvirtualtick;
     idelay:tvirtualdroplist;
     ifilename:string;
     itool:array[0..39] of tvirtualcontrol;//pointers only
     itoolcount:byte;
     procedure _ontimer(sender:tobject); override;
     procedure _ontimer2(sender:tobject);
     procedure __onclick(sender:tobject);
     procedure __onstop(sender:tobject);
     procedure _onload(sender:tobject);
     procedure updatebuttons;
     procedure pullinfo;
     procedure pushinfo;
     procedure _reload(x:string);
     procedure scroll(x:integer);
     procedure syncbgcolor;
     function addtool(x:tvirtualcontrol):tvirtualcontrol;
    public
     //internal
     procedure readwrite(mode:tvirtualstoragemode); override;
     //create
     constructor create(_gui:tvirtualform); override;
     destructor destroy; override;
     //workers
     function cansend(z:string):boolean;
     function send(z:string;prompt:boolean;var e:string):boolean;
    end;

procedure __appstart;
procedure __appclonescheme(start:boolean);//26JAN2008
procedure __appvs(vs:tvirtualstorage);
procedure __applc;//update any "license based" code
procedure __appdeletelist(var filelist:tstringlist);

implementation

uses av1;//iversion

//### tanimationviewer #########################################################
//## create ##
constructor tanimationviewer.create;
const
   sp=5;
   tab='TABS:S5,L0,L100,L200,L350';
   tab2='TABS:S5,L0,L150';
var
   p,pageid:integer;
   _pages:tvirtualpages;
   tmp:string;
begin
//self
inherited create(_gui);
createinit(false,false);
pageheight:=100;
align:=valTop;
//check
_pages:=_gui.lastpages;
if (_pages=nil) then showerror60('Invalid control');
//vars
for p:=0 to high(itool) do itool[p]:=nil;
itoolcount:=0;
itime2:=ms64-9999;
ionce:=true;
tsFps:=ntranslate('fps');
tsCells:=ntranslate('cells');
tsSize:=ntranslate('size');
tsBytes:=ntranslate('bytes');
tsW:=lowercase(translate('w'));
tsH:=lowercase(translate('h'));
tsFilename:=ntranslate('file name');
//controls

//PAGES ------------------------------------------------------------------------
_pages.newpageb(ntranslate('&view'),tepControl,rthtranslate('View and modify animations e.g. GIF, SAN, EAN, ATEP...'),vpsNormal,self,pageID);
with pages[0].client do
begin
//VIEW
//.animation
iviewer:=new('animationviewer',ntranslate('animation'),'','',valTop,nil) as tvirtualanimationviewer;
iviewer.sysptr:=vsPath;
iviewer.oVariableHeight:=true;
iviewer.oShowfilename:=true;
iviewer.base.pageheight:=350;
iviewer.pathlink.visible:=true;
with iviewer.title do
begin
help:=rthtranslate('Animation tools');
icopy:=newlink(ntranslate('copy'),tepCopy20,rthtranslate('Copy first cell of animation to Clipboard'),__onclick);
icopyall:=newlink(ntranslate('copy cells'),tepCopy20,rthtranslate('Copy animation to Clipboard as Image Strip (horizontal cells)'),__onclick);
icopyalltext:=newlink(ntranslate('copy as text'),tepCopy20,rthtranslate('Copy animation to Clipboard as plain text (animated text picture "atep")'),__onclick);
icopyb64:=newlink(ntranslate('copy as base64'),tepCopy20,rthtranslate('Copy animation to Clipboard as base 64 encoded text'),__onclick);
ipasteall:=newlink(ntranslate('paste cells'),tepPaste20,rthtranslate('Displace current with animation from Clipboard (horizontal Image Strip). An "Image Strip" window will display. Type number of cells and click "OK button'),__onclick);
ipastenew:=newlink(ntranslate('paste new'),tepPaste20,rthtranslate(
 'Create new animation from horizontal "Image Strip" in Clipboard (e.g. from MS Paint, graphics package) - an "Image Strip" Window will display, type number of cells in image strip (all equal width) - '+
 'click "OK" button. A "Save Image" Window will display, type file name and select format - click "Save" button. New animation will display in "Files" list'
 ),__onclick);
ieditsan:=newlink(ntranslate('edit'),tepWebPage20,rthtranslate('Open animation in Animator for editing'),__onclick);
isave:=newlink(ntranslate('save'),tepSaveAs20,rthtranslate('Save animation and modifications with same name (no prompt)'),__onclick);
isaveas:=newlink(ntranslate('save as'),tepSaveAs20,rthtranslate('Save animation and modifications. A "Save As" window will display - type a name and click "Save" button'),__onclick);
//TOOLS
//..scroll
iscrolldn:=addtool(newlink(ntranslate('scroll down'),tepDown20a,rthtranslate('Automatically scroll down files with display'),__onclick)) as tvirtuallink;
if (iscrolldn.image<>nil) then iscrolldn.image.run:=false;
istop:=addtool(newlink(ntranslate('stop'),tepStop20,rthtranslate('Halt automatic scrolling'),__onclick)) as tvirtuallink;
iscrollup:=addtool(newlink(ntranslate('scroll up'),tepUp20a,rthtranslate('Automatically scroll up files with display'),__onclick)) as tvirtuallink;
if (iscrollup.image<>nil) then iscrollup.image.run:=false;
iscrollup.alignsep:=sp;
//OTHER
irename:=addtool(newlink(ntranslate('rename'),tepWebPage20,rthtranslate('Change animation file name. A "Rename File" window will display, type new name and click "OK" button'),__onclick));
//1
isend1:=addtool(newlink(ntranslate('send')+' 1',tepTransfer20,rthtranslate('Copy animation file to "Send Folder 1"'),__onclick));
isaveas1:=addtool(newlink(ntranslate('save as')+' 1',tepSaveAs20,rthtranslate('Save animation and modifications. A "Save As" window will display - type a name and click "Save" button'),__onclick));
ipastefrom1:=addtool(newlink(ntranslate('paste from')+' 1',tepPaste20,rthtranslate('Open animation file and save in current folder/format'),__onclick));
isendf1:=addtool(newlink(ntranslate('folder')+' 1',tepFolder20,rthtranslate('View "Send Folder 1"'),__onclick));
isendf1.alignsep:=sp;
//2
isend2:=addtool(newlink(ntranslate('send')+' 2',tepTransfer20,rthtranslate('Copy animation file to "Send Folder 2"'),__onclick));
isaveas2:=addtool(newlink(ntranslate('save as')+' 2',tepSaveAs20,rthtranslate('Save animation and modifications. A "Save As" window will display - type a name and click "Save" button'),__onclick));
ipastefrom2:=addtool(newlink(ntranslate('paste from')+' 2',tepPaste20,rthtranslate('Open animation file and save in current folder/format'),__onclick));
isendf2:=addtool(newlink(ntranslate('folder')+' 2',tepFolder20,rthtranslate('View "Send Folder 2"'),__onclick));
end;//end of with
//left align all links
iviewer.title.aligns:=valLeft;
end;//end of with

//.options
with pages[1].client do
begin
oheight:=vhsControls;
with new('titlegrid',ntranslate('options'),'',rthtranslate('Animation options'),valTop,nil) as tvirtualgrid do
begin
ifps1:=newlink(ntranslate('1 fps'),tepWebPage20,rthtranslate('Paint 1 cell per second'),__onclick);
ifps2:=newlink(ntranslate('2 fps'),tepWebPage20,rthtranslate('Paint 2 cells per second'),__onclick);
ifps4:=newlink(ntranslate('4 fps'),tepWebPage20,rthtranslate('Paint 4 cells per second'),__onclick);
ifps7:=newlink(ntranslate('7 fps'),tepWebPage20,rthtranslate('Paint 7 cells per second'),__onclick);
ifps10:=newlink(ntranslate('10 fps'),tepWebPage20,rthtranslate('Paint 10 cells per second'),__onclick);
ifps20:=newlink(ntranslate('20 fps'),tepWebPage20,rthtranslate('Paint 20 cells per second'),__onclick);
islower:=newlink(ntranslate('slower'),tepMinusSign20,rthtranslate('Reduce paint speed'),__onclick);
ifaster:=newlink(ntranslate('faster'),tepPlusSign20,rthtranslate('Increase paint speed'),__onclick);
itrim:=newlink(ntranslate('trim'),tepTrim20,rthtranslate('Delete outer areas'),__onclick);
itrans:=newlink(ntranslate('pot fill'),tepPotFill20,rthtranslate('Fill outer areas with block color and make transparent'),__onclick);
ibgcolor:=newlink(ntranslate('bgcolor'),tepToggleColors20,rthtranslate('Switch Preview area color between "Standard > Background" color and "Custom Preview Background Color"'),__onclick);
end;//end of with

with new('page','','','',valTop,nil) as tvirtualpage do
begin
normal:=true;
bordersize:=0;
itransparent:=new('tick',ntranslate('transparent'),'',rthtranslate('Bullet: Paint cells transparently using top left pixel color'),valLeft,__onclick) as tvirtualtick;
iflip:=new('tick',ntranslate('flip'),'',rthtranslate('Bullet: Paint cells vertically flipped'),valLeft,__onclick) as tvirtualtick;
imirror:=new('tick',ntranslate('mirror'),'',rthtranslate('Bullet: Paint cells horizontally flipped'),valLeft,__onclick) as tvirtualtick;
end;//end of with
idelay:=new('droplist',translate('Delay in milliseconds'),'',rthtranslate('Time delay time between successive cell paints - animations with 2 or more cells | 1 second = 1000ms | Slow Example: 1000ms = 1 cell painted every second | Fast Example: 50ms = 20 cells painted every second'),valTop,nil) as tvirtualdroplist;
//.fill list
tmp:='1000*1#;500*2#;333*3#;250*4#;200*5#;150*6#;100*10#;50*20#;';
general.swapstrs(tmp,'*',' - ');
general.swapstrs(tmp,'#',lowercase(translate('fps')));
idelay.text:=general.swapcharsb(tmp,';',#13);
//.status
istatus:=new('label','',tab,rthtranslate('Animation statistical overview'),valTop,__onclick);
istatus.oVariableheight:=true;
end;//end of with

//SETTINGS
with _pages.newpage(ntranslate('&settings'),tepSettings,rthtranslate('Program specific settings'),vpsNormal,pageID) as tvirtualpage do
begin

//formats
with client.pagetabs.newpagescrollex(ntranslate('formats'),tepWebPage20,rthtranslate('Bullet graphic formats to view'),true,true).client do
begin
for p:=0 to (misc.imageextcount-1) do newb('tick',misc.imageextdes(misc.imageext[p],''),'',rthtranslate('Bullet to include graphic format'),valTop,nil,vspImageMasks+p,sgsBoolean,'1','');
end;//end of with

//options
with client.pagetabs.newpagescrollex(ntranslate('options'),tepWebPage20,rthtranslate('Customise general options'),true,true).client do
begin
newb('tick',ntranslate('retain saveas format'),'',rthtranslate('Bullet: "Save As" window maintains previous format selection'),valTop,nil,vspRetainSaveAsFormat,sgsBoolean,'1','');
newb('tick',ntranslate('frame image'),'',rthtranslate('Bullet: Display animations framed with a single pixel border'),valTop,nil,vspFrameimage,sgsBoolean,'1','');
newb('droplist',ntranslate('pot fill tolerance'),';0;1;2;3;4;5;10;20;30;40;50;60;70;80;90;100',rthtranslate('Custom fill strength. Higher value, stronger fill/smaller value, less fill'),valTop,nil,vspPotTol,sgsInteger,'5',vs.rangeint(0,255));
//..preview bgcolor
newb('tick',ntranslate('custom preview background color'),'',rthtranslate('Bullet: Preview area filled in custom color'),valTop,nil,vspUsePreviewBgcolor,sgsBoolean,'0','');
newb('color',ntranslate('preview background color'),'','',valTop,nil,vspPreviewBgcolor,sgsInteger,'0','');
end;//end of with

//additional tools
with client.pagetabs.newpagescrollex(ntranslate('additional options'),tepWebPage20,rthtranslate('Customise additional options'),true,true).client do
begin
newb('tick',ntranslate('show all tools'),'',rthtranslate('Bullet: View all tools'),valTop,nil,vspShowtools,sgsBoolean,'1','');
newb('tick',ntranslate('flash preview background color while scrolling'),'',rthtranslate('Bullet: Automatically toggles between "Custom Preview Background Color" and standard'),valTop,nil,vspScrollFlash,sgsBoolean,'0','');
newb('tick',ntranslate('send replace prompt')+' 1','',rthtranslate('Bullet: User prompt for overwrite confirmation'),valTop,nil,vspReplacePrompt1,sgsBoolean,'1','');
newb('tick',ntranslate('send replace prompt')+' 2','',rthtranslate('Bullet: User prompt for overwrite confirmation'),valTop,nil,vspReplacePrompt2,sgsBoolean,'1','');
newb('tick',ntranslate('retain saveas format')+' 1','',rthtranslate('Bullet: "Save As" window maintains previous format selection'),valTop,nil,vspRetainSaveAsFormat1,sgsBoolean,'1','');
newb('tick',ntranslate('retain saveas format')+' 2','',rthtranslate('Bullet: "Save As" window maintains previous format selection'),valTop,nil,vspRetainSaveAsFormat2,sgsBoolean,'1','');
newb('path',ntranslate('send folder')+' 1','',rthtranslate('Custom target Folder for "Send 1"'),valTop,nil,vspSendFolder1,sgsString,'c:\','');
newb('path',ntranslate('send folder')+' 2','',rthtranslate('Custom target Folder for "Send 2"'),valTop,nil,vspSendFolder2,sgsString,'c:\','');
//.delay
tmp:=';100;200;300;400;500;600;700;800;900;1000;1500;2000;2500;3000;3500;4000;4500;5000';
newb('droplist',translate('Scroll delay in milliseconds'),tmp,rthtranslate('Idle period whilst scrolling'),valTop,nil,vspScrolldelay,sgsInteger,'2000',vs.rangeint(100,maxint));
end;//end of with
end;//end of with

//events
iviewer.onload:=_onload;
iviewer.onstopnext:=__onstop;
idelay.onchange:=__onclick;
idelay.edit.onchange:=__onclick;
//timer
timer:=500;
itimer2:=mt.new(_ontimer2,1000,false);
_ontimer(self);
//defaults
_onload(iviewer);
end;
//## destroy ##
destructor tanimationviewer.destroy;
begin
try
//timer
mt.del(itimer2);
//self
inherited;
//controls
except;end;
end;
//## addtool ##
function tanimationviewer.addtool(x:tvirtualcontrol):tvirtualcontrol;
begin
try
//defaults
result:=x;
//add
if (x<>nil) and (itoolcount<=high(itool)) then
   begin
   itool[itoolcount]:=x;
   inc(itoolcount);
   end;//end of if
except;end;
end;
//## cansend ##
function tanimationviewer.cansend(z:string):boolean;
begin
try;result:=(iviewer.filename<>'') and fileexists(iviewer.path+iviewer.filename) and (z<>'') and directoryexists(z);except;end;
end;
//## send ##
function tanimationviewer.send(z:string;prompt:boolean;var e:string):boolean;
var
   d:string;
begin
try
//defaults
result:=false;
e:=gecUnexpectedError;
if not cansend(z) then exit;
//get
e:=gecTaskFailed;
d:=z+iviewer.filename;
//prompt
if prompt and fileexists(d) and (not showreplacefile(d,true)) then
   begin
   result:=true;
   exit;
   end;//end of if
//set
result:=general.copyto(iviewer.path+iviewer.filename,d);
except;end;
end;
//## updatebuttons ##
procedure tanimationviewer.updatebuttons;
var
   havefile,havebmp,havetext,oka,ok:boolean;
   fps,tmp:string;
   cells,w,h:integer;
begin
try
//init
cells:=1;
w:=0;
h:=0;
fps:='-';
if (iviewer.image<>nil) then
   begin
   cells:=frcmin(iviewer.image.ai.count,1);
   w:=frcmin(iviewer.image.ai.cellwidth,1);
   h:=frcmin(iviewer.image.ai.cellheight,1);
   if (iviewer.image.ai.delay>=1) then fps:=general.strdec(floattostr(1000/iviewer.image.ai.delay),2,true);
   end;//end of if
//once off
if ionce then
   begin
   ionce:=false;
   //animtor
   ieditsan.visible:=bvfFindtool('animator',tmp);
   //filename setup
   ifilename:=iviewer.path;
   end;//end of if
//copy
//.get
havefile:=(iviewer.filename<>'');
havebmp:=clipboard.hasformat(cf_bitmap) or clipboard.hasformat(cf_text);
oka:=false;
ok:=iviewer.image<>nil;
if ok and (iviewer.image.ai.count>=2) then oka:=true;
//.set
icopy.enabled:=ok;
icopyall.enabled:=ok;
icopyalltext.enabled:=ok;
icopyb64.enabled:=ok;
ipasteall.enabled:=ok and havebmp;
ipastenew.enabled:=havebmp;
isave.enabled:=ok;
isaveas.enabled:=ok;
islower.enabled:=oka;
ifaster.enabled:=oka;
ifps1.enabled:=oka;
ifps2.enabled:=oka;
ifps4.enabled:=oka;
ifps7.enabled:=oka;
ifps10.enabled:=oka;
ifps20.enabled:=oka;
if ieditsan.visible then ieditsan.enabled:=ok and (comparetext(readfileext(iviewer.filename,false),'SAN')=0);
//.tools
isaveas1.enabled:=ok;
isaveas2.enabled:=ok;
ipastefrom1.enabled:=havefile;
ipastefrom2.enabled:=havefile;
//file based links - slow update cycles
if ((ms64-itime2)>=2000) then
   begin
   //tools
   if ishowtools then
      begin
      isend1.enabled:=cansend(isendpath1);
      isendf1.enabled:=directoryexists(isendpath1);
      isend2.enabled:=cansend(isendpath2);
      isendf2.enabled:=directoryexists(isendpath2);
      irename.enabled:=fileexists(iviewer.path+iviewer.filename);
      end;//end of if
   //other
   itime2:=ms64;
   end;//end of if
if ishowtools then istop.enabled:=iscrolling;
//status
istatus.caption:=
 tsFps+': '+fps+#9+
 tsCells+': '+general.thousands(cells)+#9+
 tsSize+': '+general.thousands(w)+tsW+' x '+general.thousands(h)+tsH+#9+
 tsBytes+': '+general.thousands(iviewer.tag);
except;end;
end;
//## _onload ##
procedure tanimationviewer._onload(sender:tobject);
begin
try;pullinfo;except;end;
end;
//## pullinfo ##
procedure tanimationviewer.pullinfo;
var
   a:tvirtualbitmapanimated;//pointer only
   delay:integer;
   ok,ok2:boolean;
begin
try
//defaults
ilocked:=true;
ok:=false;
ok2:=false;
a:=nil;
a:=iviewer.image;
delay:=500;
if (a<>nil) then
   begin
   ok:=ccs.supporttransparency(iviewer.filename);
   if (a.ai.count>=2) then ok2:=true;
   end;//end of if
//check
itrim.enabled:=(a<>nil);
itrans.enabled:=ok;
itransparent.enabled:=ok;
iflip.enabled:=(a<>nil);
imirror.enabled:=(a<>nil);
idelay.enabled:=ok2;
//get
itransparent.ticked:=(a<>nil) and a.ai.transparent;
iflip.ticked:=(a<>nil) and a.ai.flip;
imirror.ticked:=(a<>nil) and a.ai.mirror;
if (a<>nil) and (a.ai.count>=2) then delay:=frcmin(a.ai.delay,20);//max of 50 fps
idelay.edit.text:=inttostr(delay);
//.filesize
iviewer.tag:=frcmin(general.filesize(iviewer.path+iviewer.filename),0);
//buttons
updatebuttons;
except;end;
try;ilocked:=false;except;end;
end;
//## pushinfo ##
procedure tanimationviewer.pushinfo;
label
   skipend;
var
   a:tvirtualbitmapanimated;//pointer only
   ai:tanimationinformation;
begin
try
//check
if ilocked then exit else ilocked:=true;
//init
a:=nil;
a:=iviewer.image;
if (a=nil) then goto skipend;
ai:=a.ai;
//get
ai.transparent:=itransparent.ticked;
ai.flip:=iflip.ticked;
ai.mirror:=imirror.ticked;
ai.delay:=frcmin(strint(idelay.edit.text),20);//max of 50fps
//set
a.ai:=ai;
skipend:
except;end;
try;ilocked:=false;except;end;
end;
//## scroll ##
procedure tanimationviewer.scroll(x:integer);
begin
try
//get
if (iscrollup.image<>nil) then iscrollup.image.run:=(x<0);
if (iscrolldn.image<>nil) then iscrolldn.image.run:=(x>0);
if (x=0) then syncbgcolor;
//set
iscrolling:=(x<>0);
iscrollingup:=(x<0);
mt.enabled[itimer2]:=(x<>0);
except;end;
end;
//## __onstop ##
procedure tanimationviewer.__onstop(sender:tobject);
begin
try;scroll(0);except;end;
end;
//## __onclick ##
procedure tanimationviewer.__onclick(sender:tobject);
label
   skipend;
var
   a:tbitmapenhanced;
   fromtext,saved,hasimage,tmpok,ok:boolean;
   tmp,ext,newfilename,v,f,e:string;
   z,zby:integer;
   pf:pstring;
begin
try
//defaults
a:=nil;
e:=gecTaskFailed;
ok:=true;
f:=iviewer.path+iviewer.filename;
hasimage:=(iviewer.image<>nil);
fromtext:=false;
//.newfilename
case (sender=isaveas) of
true:newfilename:=misc.retainformatext(iviewer.path+general.aorbstr(iviewer.filename,'untitled.gif',iviewer.filename=''),ifilename,iretainsaveasformat);
false:newfilename:=iviewer.path+'untitled.'+general.aorbstr(readfileext(iviewer.filename,false),'gif',iviewer.filename='');
end;//end of case
//get
//.stop scrolling
if iscrolling then
   begin
   if (sender<>idelay) and (sender<>idelay.edit) and (sender<>ibgcolor) then scroll(0);
   end;//end of if
//.tools
if (sender=iscrollup) then scroll(-1)
else if (sender=iscrolldn) then scroll(1)
else if (sender=istop) then scroll(0)
else if (sender=irename) then
   begin
   if showrenamefile60(iviewer.path+iviewer.filename,tmp) then _reload(tmp);
   end
else if (sender=isend1) then ok:=send(isendpath1,ireplace1,e)
else if (sender=isend2) then ok:=send(isendpath2,ireplace2,e)
else if (sender=isendf1) then run(isendpath1,'')
else if (sender=isendf2) then run(isendpath2,'')
else if (sender=isaveas1) or (sender=isaveas2) then
   begin
   //init
   ok:=false;
   tmpok:=false;
   case (sender=isaveas1) of
   true:begin
      tmpok:=iretainsaveasformat1;
      pf:=@ifilename1;
      if not directoryexists(extractfilepath(pf^)) then pf^:=isendpath1;
      end;//end of begin
   false:begin
      tmpok:=iretainsaveasformat2;
      pf:=@ifilename2;
      if not directoryexists(extractfilepath(pf^)) then pf^:=isendpath2;
      end;//end of begin
   end;//end of case
   //range
   pf^:=misc.retainformatext(extractfilepath(pf^)+iviewer.filename,pf^,tmpok);
   //animation -> bitmap
   a:=tbitmapenhanced.create;
   if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
   //save
   if misc.saveimagedlgex(a,pf^,pf^,saved) and saved then _reload(pf^);
   //successful
   ok:=true;
   end
else if (sender=ipastefrom1) or (sender=ipastefrom2) then
   begin
   //init
   f:='';
   //decide
   case (sender=ipastefrom1) of
   true:begin
      tmp:=iviewer.path+general.udv(iviewer.filename,'untitled.bmp');
      if misc.pastefromimagedlg(ifilename1,tmp) then
         begin
         f:=tmp;
         ifilename1:=misc.retainformatext(extractfilepath(ifilename1)+extractfilename(tmp),ifilename1,true);
         end;//end of begin
      end;//end of begin
   false:begin
      tmp:=iviewer.path+general.udv(iviewer.filename,'untitled.bmp');
      if misc.pastefromimagedlg(ifilename2,tmp) then
         begin
         f:=tmp;
         ifilename2:=misc.retainformatext(extractfilepath(ifilename2)+extractfilename(tmp),ifilename2,true);
         end
      end;//end of begin
   end;//end of case
   //reload
   if (f<>'') then _reload(f);
   end
//.other
else if (sender=ibgcolor) then
   begin
   vs.b[vspUsePreviewBgcolor]:=not vs.b[vspUsePreviewBgcolor];
   vs.writetocontrols;
   end
else if (sender=itrans) then
   begin
   ok:=false;
   //check
   if (iviewer.image=nil) then goto skipend;
   //animation -> bitmap
   a:=tbitmapenhanced.create;
   if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
   //adjust
   if not ccs.transpotfill(a,ipottol,e) then goto skipend;
   iviewer.image.pai.transparent:=true;
   //display
   if not iviewer.image.img.copyfromb(a,'',nil,e) then goto skipend;
   //successful
   pullinfo;
   iviewer.image.paint;
   ok:=true;
   end
else if (sender=itrim) then
   begin
   ok:=false;
   //check
   if (iviewer.image=nil) then goto skipend;
   //animation -> bitmap
   a:=tbitmapenhanced.create;
   if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
   //adjust
   if not ccs.transtrim(a,e) then goto skipend;
   //display
   if not iviewer.image.img.copyfromb(a,'',nil,e) then goto skipend;
   //successful
   pushinfo;
   pullinfo;
   ok:=true;
   end
else if (sender=ieditsan) then bvfRuntool('animator',iviewer.path+iviewer.filename)
else if (sender=itransparent) or (sender=iflip) or (sender=imirror) or (sender=idelay) or (sender=idelay.edit) then pushinfo
else if (sender=ifps20) or (sender=ifps10) or (sender=ifps7) or (sender=ifps4) or (sender=ifps2) or (sender=ifps1) then
   begin
   //get
   if (sender=ifps20) then z:=50
   else if (sender=ifps10) then z:=100
   else if (sender=ifps7) then z:=142
   else if (sender=ifps4) then z:=250
   else if (sender=ifps2) then z:=500
   else z:=1000;
   //set
   idelay.edit.text:=inttostr(z);
   end
else if (sender=ifaster) or (sender=islower) then
   begin
   //get
   z:=frcmin(strint(idelay.edit.text),20);//max of 50fps
   case z of
   0..50:zby:=10;//10=1 GIF delay unit
   51..200:zby:=20;
   else zby:=50;
   end;//end of case
   //decide
   if (sender=ifaster) then zby:=-zby;
   //set
   idelay.edit.text:=inttostr(frcmin(strint(idelay.edit.text)+zby,20));
   end
else if (sender=islower) then idelay.edit.text:=inttostr(frcmin(strint(idelay.edit.text)+50,20))//max of 50fps
else if (sender=isave) or (sender=isaveas) then
   begin
   ok:=false;
   //animation -> bitmap
   a:=tbitmapenhanced.create;
   if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
   //save
   case (sender=isave) of
   true:if ccs.tofile(a,f,e) then iviewer.load else goto skipend;
   false:if misc.saveimagedlgex(a,newfilename,newfilename,saved) then
      begin
      ifilename:=newfilename;
      if saved then _reload(newfilename);
      end;//end of if
   end;//end of case
   //successful
   ok:=true;
   end
else if (sender=icopy) then
   begin
   if hasimage then ok:=ccs.copytoclipboard(iviewer.image,false,true,e)//single cells
   end
else if (sender=icopyall) then
   begin
   if hasimage then ok:=ccs.copytoclipboard(iviewer.image,true,true,e)//all cells
   end
else if (sender=icopyalltext) then
   begin
   if hasimage then
      begin
      //init
      ok:=false;
      //animation -> bitmap
      a:=tbitmapenhanced.create;
      if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
      //convert
      if (a.ai.count>=2) then a.ai.format:='ATEP' else a.ai.format:='TEP';
      if not ccs.todata(a,tmp,e) then goto skipend;
      //copy
      e:=gecTaskFailed;
      clipboard.astext:=tmp;
      //successful
      ok:=true;
      end;//end of if
   end
else if (sender=icopyb64) then
   begin
   if hasimage then
      begin
      //init
      ok:=false;
      //animation -> bitmap
      a:=tbitmapenhanced.create;
      if not ccs.tobmp(a,iviewer.image,true,e) then goto skipend;
      //get
      a.ai.format:=readfileext(f,true);
      a.ai.subformat:='';
      a.ai.writeB64:=true;//base64 encode output
      if not ccs.todata(a,tmp,e) then goto skipend;
      //set
      e:=gecTaskFailed;
      clipboard.astext:=tmp;
      //successful
      ok:=true;
      end;//end of if
   end
else if (sender=ipasteall) or (sender=ipastenew) then
   begin
   //defaults
   ok:=false;
   e:=gecTaskFailed;
   //get
   a:=tbitmapenhanced.create;
   //.clipboard as text - reads all supported text formats
   if clipboard.hasformat(cf_text) then
      begin
      tmp:=clipboard.astext;
      if not ccs.fromdata(a,tmp,e) then goto skipend;
      fromtext:=true;
      end
   else a.assign(clipboard);
   if not ccs.nonempty24(a) then goto skipend;
   //prompt
   //.get
   v:='2';
   if (iviewer.image<>nil) then v:=inttostr(frcmin(iviewer.image.ai.count,1));
   //.set
   if fromtext then v:=inttostr(a.ai.count)//"fromtext" means we have entire animation, so no need to ask for cell count!
   else if not showedit60(v,ntranslate('image strip'),translate('Type number of image strip cells/frames'),'') then
      begin
      ok:=true;
      goto skipend;
      end;//end of if
   //build
   a.ai.count:=frcmin(frcrange(strint(v),1,a.width),1);
   if not fromtext then//only set if "cells", else if "fromtext" we have entire animation so we already know this information
      begin
      a.ai.delay:=frcmin(strint(general.aorbstr('500',idelay.edit.text,hasimage)),20);//max of 50fps
      a.ai.transparent:=itransparent.ticked;
      end;//end of if
   a.ai.cellwidth:=frcmin(a.width div a.ai.count,1);
   a.ai.cellheight:=a.height;
   a.ai.format:=readfileext(iviewer.filename,false);
   a.ai.subformat:='';
   //set
   if (sender=ipasteall) then
      begin
      v:='';
      if not ccs.todata(a,v,e) then goto skipend;
      if (iviewer.image<>nil) then iviewer.image.animation:=v;
      _onload(iviewer);
      end
   else if (sender=ipastenew) then
      begin
      if misc.saveimagedlgex(a,newfilename,newfilename,saved) and saved then _reload(newfilename);
      end;//end of if
   //successful
   ok:=true;
   end;//end of if
skipend:
except;end;
try
if not ok then showerror60(translate(e));
freeobj(@a);
except;end;
end;
//## _reload ##
procedure tanimationviewer._reload(x:string);
begin//Note: only reload if new filename "x" resides in same folder
try;if (comparetext(asfolder(extractfilepath(x)),iviewer.path)=0) then iviewer.reload(extractfilename(x),true);except;end;
end;
//## _ontimer2 ##
procedure tanimationviewer._ontimer2(sender:tobject);
var
   c:integer;
   ok:boolean;
begin//scroller
try
//init
iscrolltoggle:=not iscrolltoggle;
if not iscrollflash then iscrolltoggle:=true;
//set
if (not iviewer.cannext) or (not ishowtools) then scroll(0)
else
   begin
   //get
   ok:=vs.b[vspUsePreviewBgcolor];
   case iscrolltoggle of
   false:c:=general.aorb(vs.i[vspPreviewBgcolor],clNone,ok);
   true:c:=general.aorb(clNone,vs.i[vspPreviewBgcolor],ok);
   end;//end of case
   //set
   if iscrolltoggle then
      begin
      iviewer.previewbgcolor:=c;
      iviewer.next(iscrollingup);
      end
   else
      begin
      iviewer.previewbgcolor:=c;
      iviewer.image.paint;
      end;//end of if
   end;//end of if
except;end;
end;
//## syncbgcolor ##
procedure tanimationviewer.syncbgcolor;
var
   c:integer;
begin
try
c:=clNone;
if vs.b[vspUsePreviewBgcolor] then c:=vs.i[vspPreviewBgcolor];
if (iviewer.previewbgcolor<>c) then
   begin
   iviewer.previewbgcolor:=c;
   iviewer.image.paint;
   end;//end of if
except;end;
end;
//## _ontimer ##
procedure tanimationviewer._ontimer(sender:tobject);
begin//every 2 seconds
try
//update buttons
updatebuttons;
except;end;
end;
//## readwrite ##
procedure tanimationviewer.readwrite(mode:tvirtualstoragemode);
var
   p,c:integer;
   newmask:string;
begin
try
case mode of
vsmReadfromcontrols:;
vsmWritetocontrols:;
vsmUpdatecontrols:begin
   //scroll
   iscrollflash:=vs.b[vspScrollFlash];
   mt.interval[itimer2]:=vs.i[vspScrolldelay] div general.aorb(1,2,iscrollflash);
   //mask
   newmask:='';
   for p:=vspImageMasks to (vspImageMasks+misc.imageextcount-1) do if vs.b[p] then newmask:=newmask+'*.'+misc.imageext[p-vspImageMasks]+';';
   //tools
   ishowtools:=vs.b[vspShowTools];
   for p:=0 to (itoolcount-1) do itool[p].visible:=ishowtools;
   isendpath1:=asfolder(vs.s[vspSendFolder1]);
   isendpath2:=asfolder(vs.s[vspSendFolder2]);
   ireplace1:=vs.b[vspReplacePrompt1];
   ireplace2:=vs.b[vspReplacePrompt2];
   //preview bgcolor
   syncbgcolor;
   //settings
   ipottol:=byte(frcrange(vs.i[vspPotTol],0,255));
   iviewer.oFrameimage:=vs.b[vspFrameimage];
   iretainsaveasformat:=vs.b[vspRetainSaveAsFormat];
   iretainsaveasformat1:=vs.b[vspRetainSaveAsFormat1];
   iretainsaveasformat2:=vs.b[vspRetainSaveAsFormat2];
   //hints
   isend1.hint:=isendpath1;
   isendf1.hint:=isendpath1;
   isend2.hint:=isendpath2;
   isendf2.hint:=isendpath2;
   //update
   if (newmask<>iviewer.mask) then
      begin
      iviewer.mask:=newmask;
      iviewer.path:=iviewer.path;
      end;//end of if
   updatebuttons;
   end;//end of begin
end;//end of case
except;end;
end;


//## __appstart ##
procedure __appstart;
var
   tmp:string;
begin
try
//process
//.form - occurs now before "tpg.setup"
application.createform(tvirtualform,forma);
forma.lockalign:=true;
//.setup
pg.setup(816651,1417728,12,12,[],clNone,clNone);
//.pages
forma.pages:=forma.new('pages','','','',valTop,nil,nil) as tvirtualpages;
//.control
tanimationviewer.create(forma);
//.user management
forma.new('User Management','','','',valTop,nil,nil);
forma.lockalign:=false;
//.done - sized for a 800x600 [720,560] screen
pg.done(800,560);
//.command line
tmp:=paramstr(1);
if (tmp<>'') then
   begin
   vs.s[vsPath]:=tmp;
   vs.writetocontrols;
   end;//end of if
except;general.startfailure;end;
end;
//## __appclonescheme ##
procedure __appclonescheme(start:boolean);//26JAN2008
begin//Allow program to modify "vs" before clone saves a copy and restore after
try
case start of
true:begin
   end;//end of begin
false:;
end;//end of case
except;end;
end;
//## __appvs ##
procedure __appvs(vs:tvirtualstorage);
begin//Example: vs.initfill(vsPort,sgsInteger,inttostr(_rgtPortDefault),rangeint(1,high(word)));//#
try
//yyyyyyyyy
vs.initfill(vsPath,sgsString,bvfportable(bvfAnimations),'');
except;end;
end;
//## _applc ##
procedure __applc;//update any "license based" code
begin
try;vs.apply;except;end;
end;
//## _appdeletelist ##
procedure __appdeletelist(var filelist:tstringlist);//v1.00.022, 29OCT2007
begin//Note: Fill filelist with program specific files that are to be deleted.
try  //      All core system files will already be listed, just program specific are needed.
//check
if (filelist=nil) then exit;
//program specific files

except;end;
end;

initialization
  //start
  siInit;
  //start
  randomize;

finalization
  //system
  siCloseAll;

end.
