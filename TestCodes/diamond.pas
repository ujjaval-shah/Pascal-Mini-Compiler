program helloworld;

var
i,j,k,len: integer;

begin
    read(input,len);
    for i:=1 to len do
    begin
        for j:=1 to (i-1) do write(0);
        for j:=1 to (len-i) do write(1);
        write(1);
        for j:=1 to (len-i) do write(1);
        for j:=1 to (i-1) do write(0);
        writeln();
    end;
    for i:=len downto 1 do
    begin
        for j:=1 to (i-1) do write(0);
        for j:=1 to (len-i) do write(1);
        write(1);
        for j:=1 to (len-i) do write(1);
        for j:=1 to (i-1) do write(0);
        writeln();
    end;
end.

