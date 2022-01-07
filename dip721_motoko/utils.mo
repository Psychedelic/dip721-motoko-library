import Types "./Types";

module {
    type User = Types.User;

    public func expect_principal(user: User): Bool {
        // assert(user == (#principal, p));
        // user;
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