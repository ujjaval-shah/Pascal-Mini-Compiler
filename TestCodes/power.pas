program helloworld;

var
    i, j: integer;

begin
    j:=1;
    i:=10;
    while i>0 do 
    begin
        j:=j+j;
        i:=i-1;
    end;
    writeln(j);
end.

