import Types "./Types";

module {
    type User = Types.User;

    public func expect_principal(user: User): Bool {
        switch(user) {
            case(#address a) {
                false;
            };
            case(#principal p) {
                true;
            };
        };
    };
};