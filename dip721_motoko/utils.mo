import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Types "./Types";
import _userTokens "mo:base/Blob";

module {

    type User = Types.User;
    type TokenIndex = Types.TokenIndex;

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

    public func tokenIndexToBuffer(userTokens: [(User, [TokenIndex])]): [(User, Buffer.Buffer<TokenIndex>)] {
        let _userTokens: Buffer.Buffer<(User, Buffer.Buffer<TokenIndex>)> = Buffer.Buffer(0);

        for ((user, indexes) in userTokens.vals()) {
            let buffer: Buffer.Buffer<TokenIndex> = Buffer.Buffer(0);
            for (index in indexes.vals()) {
                buffer.add(index);
            };
            _userTokens.add(user, buffer);
        };
        
        _userTokens.toArray();
    };
}