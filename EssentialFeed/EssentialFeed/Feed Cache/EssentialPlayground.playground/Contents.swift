struct Text {
    let description: String
}

protocol Modifyer {
    func modify() -> Text
}

class ConcreteModifyer: Modifyer {
    func modify() -> Text {
        return Text(description: "Text")
    }
}

class ModifyerDecorator: Modifyer {
    let decoratee: Modifyer
    
    init(_ modifyer: Modifyer) {
        self.decoratee = modifyer
    }
    
    func modify() -> Text {
        return decoratee.modify()
    }
}

class ParenthesesDecorator: ModifyerDecorator {
    override func modify() -> Text {
        return Text(description: "(\(decoratee.modify().description))")
    }
}

class SquareBracketsDecorator: ModifyerDecorator {
    override func modify() -> Text {
        return Text(description: "[\(decoratee.modify().description)]")
    }
}

class AngleBracketsDecorator: ModifyerDecorator {
    override func modify() -> Text {
        return Text(description: "<\(decoratee.modify().description)>")
    }
}

class CurlyBracketsDecorator: ModifyerDecorator {
    override func modify() -> Text {
        return Text(description: "{\(decoratee.modify().description)}")
    }
}

func client() {
    var modifyer: Modifyer = ConcreteModifyer()
    print(modifyer.modify())
    
    modifyer = ParenthesesDecorator(modifyer)
    print(modifyer.modify())
    
    modifyer = SquareBracketsDecorator(modifyer)
    print(modifyer.modify())
    
    modifyer = AngleBracketsDecorator(modifyer)
    print(modifyer.modify())
    
    modifyer = CurlyBracketsDecorator(modifyer)
    print(modifyer.modify())
}

client()


class Dog {
    
    let legsCount = 4
    let url = "http://"
    
    let age: Int = 3
    var isHungry: Bool = true
    
    func run() {
        isHungry = true
    }
    
    func eat() {
        isHungry = false
    }
}
