program av;

uses
  Forms,
  av1 in 'av1.pas',
  av2 in 'av2.pas',
  av3 in 'av3.pas',
  av4 in 'av4.pas',
  av5 in 'av5.pas',
  main in 'main.pas';


//include multi-format icon - Delphi 3 can't compile an icon of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R av-256.res}

//include app version information
{$R ver.res}

begin
  application.initialize;
  appstart;
  application.run;
  siCloseAll;
end.
