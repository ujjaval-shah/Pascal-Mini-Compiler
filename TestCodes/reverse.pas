program helloworld;

var
    inp, ans, divi, remain, loopc, temp: integer;

begin
    ans:=0;
    writeln('ENTER_A_NUMBER_TO_REVERSE');
    read(input, inp);
    loopc:=1;

    while (loopc=1) do 
    begin
        divi := inp div 10;
        temp := divi * 10;
        ans:=ans*10;
        remain:=inp - temp;
        ans:=ans+remain;
        inp:=divi;
        if divi=0 then loopc:=0;
    end;
    writeln('THIS_IS_THE_REVERSE');
    writeln(ans);

end.
