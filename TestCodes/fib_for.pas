program helloworld;

var
    m, n, fprev, fnext, temp: integer;

begin
    fprev:=0;
    fnext:=1;
    n:=15;
    for m:=1 to n do
    begin
        temp:=fprev;
        fprev:=fnext;
        fnext:=temp+fnext;
    end;
    write(fnext);
end.