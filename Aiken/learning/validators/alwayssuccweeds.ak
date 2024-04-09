use aiken/transaction.{ScriptContext}

fn demo1(r: Int) -> Bool {
    if r == 11 {
        True
    } else {
        False
    }
}

fn demo2(x: Int) -> Bool {
    when x is {
        22 -> True
        _ -> False
    }
}

fn superPower(param: Int) -> String {
    when param is {
        1 -> @"One"
        2 -> @"Two"
        3 -> @"Three"
        4 -> @"Four"
        5 -> @"Five"
        _ -> @"Not between 1 and 5"
    }
}

validator {
    fn demoVal(datum: Int, redeemer: Int, _scriptContext: ScriptContext) -> Bool {
        demo1(redeemer) || demo2(datum)
    }
}

test demot1() {
    demo1(11)
}

test demot2() {
    demo2(22)
}

test demot3() {
    demo2(1) == False
}

test demor1() {
    demo1(1) == False
}

test superT() {
    superPower(5) == @"Five"
}