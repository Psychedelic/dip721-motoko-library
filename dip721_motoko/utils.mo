import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Types "./types";
import _userTokens "mo:base/Blob";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";

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
        a == b;
    };

    public func mapUserTokensForHashmap(userTokens: [(User, [TokenIndex])]): [(User, Buffer.Buffer<TokenIndex>)] {
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
    
    public func mapUserTokenForUpgrade(userTokens: HashMap.HashMap<User, Buffer.Buffer<TokenIndex>>): [(User, [TokenIndex])] {
        let _userTokenEntries: Buffer.Buffer<(User, [TokenIndex])> = Buffer.Buffer(0);
        for((user, indexes) in userTokens.entries()) {
            _userTokenEntries.add(user, indexes.toArray());
        };

        _userTokenEntries.toArray();
    };

    public func toTokenIndex(value:Nat64) : Nat32 {
        let _value = Nat64.toNat(value);
        Nat32.fromNat(_value);
    };

    public func toTokenId(value:Nat32) : Nat64 {
        let _value = Nat32.toNat(value);
        Nat64.fromNat(_value);
    };
}