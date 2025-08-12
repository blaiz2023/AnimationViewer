unit av5;

interface
{$align on}{$iochecks on}{$O+}{$W-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }
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

uses
  Windows, Forms, Classes, Controls, SysUtils, ShellApi, filectrl;


procedure showbasic(x:string);
function low__fromstream(x:tmemorystream):string;
procedure low__tostream(s:string;d:tmemorystream);
function web_url(xshortname:string):string;//locked to "http://www.blaizenterprises.com"
procedure web_run(xshortname:string);//locked to "http://www.blaizenterprises.com"
function path_grab(var x:string):string;
function path_grabb(x:string):string;
function smart_filter(x:string):string;
function smart_filter2(x:tmemorystream):tmemorystream;

implementation

//##############################################################################
//## Blaiz Enterprises adaptive retro-fit handlers - 29jul2021
//## Version: 1.00.150
//## Purpose: To enable an old app to work on a modern system and with our new
//##          domain name "www.blaizenterprises.com", previously "www.blaiz.net"
//## Procs: web_link, path_grab, smart_filter and smart_filter2 interface with
//##        key points of the old code to modify its behaviour
//##############################################################################

//## frcmax ##
function frcmax(x,max:longint):longint;//14-SEP-2004
begin
try;result:=x;if (result>max) then result:=max;except;end;
end;
//## frcmin ##
function frcmin(x,min:longint):longint;//14-SEP-2004
begin
try;result:=x;if (result<min) then result:=min;except;end;
end;
//## showbasic ##
procedure showbasic(x:string);
begin
try;messagebox(application.handle,pchar(x),'Information',$00000000+$40);except;end;
end;
//## low__fromstream ##
function low__fromstream(x:tmemorystream):string;
begin
try
if (x=nil) or (x.size<=0) then result:=''
else
   begin
   setlength(result,x.size);
   x.position:=0;
   x.read(pchar(result)^,x.size);
   end;
except;end;
end;
//## low__tostream ##
procedure low__tostream(s:string;d:tmemorystream);
begin
try
if (d=nil) then exit;
d.clear;
d.writebuffer(pchar(s)^,length(s));
except;end;
end;
//## web_url ##
function web_url(xshortname:string):string;//locked to "http://www.blaizenterprises.com"
var
   x1,x2,x3:string;
   i,p,v,c,d:longint;
   //## n ##
   procedure n(x:longint);
   begin
   v:=x;
   end;
begin
try
//defaults
result:='';
//init
x1:='';
x2:='';
x3:='';
c:=0;
d:=0;
//get
for i:=1 to 1000 do
begin
for p:=0 to 255 do
begin
v:=0;
case c of
//"http://www."
10,13:n(116);
0:n(104);
24:n(58);
30,34:n(47);
17:n(112);
37,39,42:n(119);
48:begin
   n(1);
   if (d=0) then inc(d,2);
   end;
//".com"
62:n(111);
64:n(109);
57:n(99);
51:n(46);
//"BlaizEnterprises" (but done backwards)
76:begin
   if (d=2) then dec(d);
   n(3);
   end;
81:n(115);//s
77:n(115);//s
79:n(101);//e
133:n(110);//n
135:n(69);//E
101:n(114);//r
106:n(101);//e
121:n(116);//t
87:n(105);//i
88:n(114);//r
99:n(112);//p
141:n(122);//z
153:n(105);//i
155:n(99-2);//a
167:n(118-10);//l
193:n(167-101);//B
199:n(49-3);//.
//stop
250..260:if (random(8)=2) then break;
end;
//add
if (p=v) then
   begin
   if (v>=5) then
      begin
      case d of
      1:x2:=char(p)+x2;
      0:x1:=x1+char(p);
      2:x3:=x3+char(p);
      end;
      end;
   inc(c);
   end;
end;//p

end;//i

//set
result:=x1+x2+x3;
if (length(result)>=20) and (xshortname<>'') then result:=result+'/'+xshortname;
except;end;
end;
//## web_run ##
procedure web_run(xshortname:string);//locked to "http://www.blaizenterprises.com"
begin
try;shellexecute(longint(0),nil,pchar(web_url(xshortname)),nil,nil,1);except;end;
end;
//## path_grab ##
function path_grab(var x:string):string;
var
   p,xlen:longint;
begin
try
//defaults
result:=x;
//intercept filenames and folders (e.g. "?:\") and cut off at "Blaiz Enterprises" and redirect to local folder for portable sort of mode
if (copy(x,2,2)=':\') then
   begin
   xlen:=length(x);
   if (xlen>=2) then
      begin
      for p:=2 to xlen do
      begin
      if (x[p-1]='\') and ((x[p]='B') or (x[p]='b')) and (comparetext(copy(x,p-1,19),'\Blaiz Enterprises\')=0) then
         begin
         result:=extractfilepath(application.exename)+copy(x,p,xlen);
         x:=result;
         forcedirectories(extractfilepath(result));//29jul2021
         break;
         end;
      end;//p
      end;
   end;
except;end;
end;
//## path_grabb ##
function path_grabb(x:string):string;
begin
try;result:=path_grab(x);except;end;
end;
//## smart_filter ##
function smart_filter(x:string):string;
label
   skipone,redo;
var
   p2,p,dlen,dpos,xpos,xlen:longint;
   n,str1:string;
   //## xadd ##
   procedure xadd(x:char);
   begin
   inc(dpos);
   if (dpos>dlen) then
      begin
      inc(dlen,1000);
      setlength(result,dlen);
      end;
   result[dpos]:=x;
   end;
begin
try
//init
result:='';
xlen:=length(x);
dlen:=0;
dpos:=0;
//check
if (xlen<=0) then exit;
//binary detection -> if binary code then assume unsafe to modify -> may be an image etc - 29jul2021
for p:=1 to xlen do
begin
if (ord(x[p])<=8) then
   begin
   result:=x;
   exit;
   end;
end;

//find "blaiz.net" and replace with "BlaizEnterprises.com"
xpos:=1;
redo:
if ((x[xpos]='b') or (x[xpos]='B')) and (comparetext(copy(x,xpos,9),'blaiz.net')=0) then
   begin
   str1:='blaizenterprises.com';
   for p:=1 to length(str1) do xadd(str1[p]);
   inc(xpos,8);
   end
else if (x[xpos]='/') then
   begin
   xadd(x[xpos]);
   //scan backwards -> if we detect a "file:///" on the same line then it's a local file referece and we are NOT to alter it - 29jul2021
   for p:=xpos downto frcmin(xpos-1200,1) do
   begin
   //.move on without altering text
   if (x[p]=#10) or (x[p]=#13) or (x[p]=#39) or (x[p]=#34) or (x[p]=#60) or (x[p]=#62) or (((x[p]='f') or (x[p]='F')) and (comparetext(copy(x,p,8),'file:///')=0)) then goto skipone
   else if (comparetext(copy(x,p,7),'http://')=0) or (comparetext(copy(x,p,8),'https://')=0) then break;//ok
   end;//p

   //scan forwards to a return code or a ".htm" or ".html"
   for p:=(xpos+1) to frcmax(xpos+1200,xlen) do
   begin
   //.move on without altering text
   if (x[p]=':') or (x[p]='/') or (x[p]='\') or (x[p]=#10) or (x[p]=#13) or (x[p]=#32) or (x[p]=#39) or (x[p]=#34) or (x[p]=#60) or (x[p]=#62) then break
   //.found a web filename -> adjust the name and STRIP off the trailing ".htm" or ".html" references - 29jul2021
   else if (x[p]='.') and ((comparetext(copy(x,p,4),'.htm')=0)) then
      begin
      //filter
      n:=lowercase(copy(x,xpos+1,p-xpos-1));
      //.swap "_" for "-" chars - 29jul2021
      if (n<>'') then
         begin
         for p2:=1 to length(n) do
         begin
         if (n[p2]='_') then n[p2]:='-';
         end;//p2
         end;//n

      //## Name Changers #######################################################
      //decide -> change name to a better version of name
      if      (n='aac') then n:='animated-artcard-creations'
      else if (n='sl')  then n:='select-language'
      else
         begin

         end;
      //########################################################################

      //add
      if (n<>'') then
         begin
         for p2:=1 to length(n) do xadd(n[p2]);
         end;
      //inc
      xpos:=p;
      //strip trailing ".htm" or ".html"
      if ((comparetext(copy(x,p,5),'.html')=0)) then inc(xpos,4)
      else if ((comparetext(copy(x,p,4),'.htm')=0)) then inc(xpos,3);
      //stop
      break;
      end;
   end;//p
   end
else xadd(x[xpos]);
skipone:
//inc
inc(xpos);
if (xpos<=xlen) then goto redo;
//trim
if (dpos<dlen) then setlength(result,dpos);
except;end;
end;
//## smart_filter2 ##
function smart_filter2(x:tmemorystream):tmemorystream;
begin
try
result:=x;
if (x<>nil) and (x.size>=1) then low__tostream(smart_filter(low__fromstream(x)),x);
except;end;
end;

end.
