import Types "./Types";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

module {

    type User = Types.User;

    public func hashUser(user: User): Hash.Hash {
        switch(user) {
            case(#principal v) {
                Principal.hash(v);
            };
            case(#address a) {
                Text.hash(a);
            };
        }
    };

    public func compareUser(a: User, b: User): Bool {
        a ==b;
    };
}