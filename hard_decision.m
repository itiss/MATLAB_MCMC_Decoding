function output =hard_decision(input)% MATLAB里算LLR是把b=0的概率放在分母上面的，所以是大于0的判定为比特0
    input(input>0)=0;
    input(input<0)=1;
    output=input;