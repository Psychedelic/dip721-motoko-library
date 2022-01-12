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
import Prim "mo:⛔";

module {

    type User = Types.User;
    type TokenIndex = Types.TokenIndex;

    private let anonymousPrincipal : Blob = "\04";

    public func isAnonymous(p : Principal) : Bool {
        return Prim.blobOfPrincipal p == anonymousPrincipal;
    };
    
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

    public func mapOperatorsForHashmap(userTokens: [(TokenIndex, [Principal])]): [(TokenIndex, Buffer.Buffer<Principal>)] {
        let _Operators: Buffer.Buffer<(TokenIndex, Buffer.Buffer<Principal>)> = Buffer.Buffer(0);

        for ((token, indexes) in _Operators.vals()) {
            let buffer: Buffer.Buffer<Principal> = Buffer.Buffer(0);
            
            for (index in indexes.vals()) {
                buffer.add(index);
            };

            _Operators.add(token, buffer);
        };
        
        _Operators.toArray();
    };
    
    public func mapUserTokenForUpgrade(userTokens: HashMap.HashMap<User, Buffer.Buffer<TokenIndex>>): [(User, [TokenIndex])] {
        let _userTokenEntries: Buffer.Buffer<(User, [TokenIndex])> = Buffer.Buffer(0);
        
        for((user, indexes) in userTokens.entries()) {
            _userTokenEntries.add(user, indexes.toArray());
        };

        _userTokenEntries.toArray();
    };

    public func mapOperatorsForUpgrade(operators: HashMap.HashMap<TokenIndex, Buffer.Buffer<Principal>>): [(TokenIndex, [Principal])] {
        let _OperatorEntries: Buffer.Buffer<(TokenIndex, [Principal])> = Buffer.Buffer(0);
        
        for((token, indexes) in operators.entries()) {
            _OperatorEntries.add(token, indexes.toArray());
        };

        _OperatorEntries.toArray();
    };

    public func toTokenIndex(value:Nat64) : Nat32 {
        let _value = Nat64.toNat(value);
        Nat32.fromNat(_value);
    };

    public func toTokenId(value:Nat32) : Nat64 {
        let _value = Nat32.toNat(value);
        Nat64.fromNat(_value);
    };

    public func removePrincipalFromBuffer(principal: Principal, principals: Buffer.Buffer<Principal>): Buffer.Buffer<Principal> {
        let _principals = principals.toArray();
        let _buffer: Buffer.Buffer<Principal> = Buffer.Buffer(0);

        for(p in _principals.vals()) {
            if(p != principal) {
                _buffer.add(p);
            };
        };
        _buffer;
    };
}