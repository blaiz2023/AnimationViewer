program av;

uses
  Forms,
  av2 in 'av2.pas',
  av3 in 'av3.pas',
  av4 in 'av4.pas',
  av1 in 'av1.pas',
  av5 in 'av5.pas';

//{$R *.RES}

{$R av-256.res}
begin
  application.initialize;
  appstart;
  application.run;
  siCloseAll;
end.
