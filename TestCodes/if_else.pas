program helloprog;

var 
    i,j,lower,upper: integer;

begin
    i:=0;
    j:=60;
    if i=0 then writeln(1000);
    i:=100;
    if i<10 then write(1);
    if j<50 
    then if j<25 then write(25) else write(50) 
    else if j<75 then write(75) else write(100);
end.