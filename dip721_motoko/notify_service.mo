import Principal "mo:base/Principal";

module {

    public func notify(caller: Principal, from: Principal, token_id: Nat64, data: [Nat8]): async () {
        let canister = actor(Principal.toText(caller)) : actor { 
            onDIP721Received: (Principal, Principal, Nat64, [Nat8]) -> async ();
        };

        await canister.onDIP721Received(caller,from,token_id,data);
    };
}