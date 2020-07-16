program helloworld;

var
    i, j, max, sum: integer;

begin
    i:=1;
    max:=5;
    sum:=0;
    while(i<max) do
    begin
        j:=i;
        while(j<max) do
        begin
            sum:=sum+j;
            j:=j+1;
        end;
        i:=i+1;
    end;
    sum:=sum+0;
end.

