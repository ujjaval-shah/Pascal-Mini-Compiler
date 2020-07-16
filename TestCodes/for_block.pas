program helloworld;

var
    i, j, ans: integer;

begin
    ans:=0;
    for i:=1 to 10 do 
    begin 
        for j:=1 to i do
        begin
            ans:=ans+1;
        end;
    end;
    write(ans);
end.

