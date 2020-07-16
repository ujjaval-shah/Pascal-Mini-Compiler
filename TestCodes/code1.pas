program progname;

var 
i, j: integer;

begin
    for i:=0 to 6 do
    begin
        for j:=i downto 0 do write(1);
        for j:=(6-i) downto 0 do write(0);
        writeln();
        write();
    end;
end.
