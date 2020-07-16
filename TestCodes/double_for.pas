program helloworld;

var
    i, j, ans: integer;

begin
    ans:=0;
    for i:=1 to 10 do for j:=1 to i do ans:=ans+1;
    writeln(ans);
end.

