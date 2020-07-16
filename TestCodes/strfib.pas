program helloworld;

var
    fprev, fnext, m, n, temp: integer;

begin
    writeln('ENTER_N_TO_GET_NTH_FIBONACI');
    fprev:=0;
    fnext:=1;
    read(input,n);
    m:=1;
    while(m<n)do
    begin
        temp:=fprev;
        fprev:=fnext;
        fnext:=temp+fnext;
        m:=m+1;
    end;
    write(fprev);
end.
