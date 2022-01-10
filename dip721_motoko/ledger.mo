import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Types "./types";
import Utils "./utils";
import _tokens "mo:base/List";

module {

    type TokenIndex = Types.TokenIndex;
    type TokenMetadata = Types.TokenMetadata;
    type MetadataDesc = Types.MetadataDesc;
    type Metadata = Types.Metadata;
    type MintReceipt = Types.MintReceipt;
    type MintReceiptPart = Types.MintReceiptPart;
    type MetadataResult = Types.MetadataResult;
    type ExtendedMetadataResult = Types.ExtendedMetadataResult;
    type TokenIdentifier = Types.TokenIdentifier;
    type OwnerResult = Types.OwnerResult;
    type User = Types.User;

    public class Ledger(
        tokens: HashMap.HashMap<TokenIndex,TokenMetadata>,
        user_tokens: HashMap.HashMap<User,[TokenIndex]>,
    ) 
    {
            public func mintNFT(to: Principal, metadata_desc: MetadataDesc): MintReceipt {
            let token_index = tokens.size();
            let token_index_nat32 = Nat32.fromNat(token_index);

            let tokenMetadata: TokenMetadata = {
                var account_identifier = Principal.toText(to);
                var metadata = #nonfungible(null);
                var token_identifier = Types.into_token_identifier(token_index_nat32);
                var principal = to;
                var metadata_desc = metadata_desc;
            };

            let mintReceipt: MintReceiptPart = {
                token_id = Nat64.fromNat(token_index);
                id = 1;
            };
            let existing_tokens = user_tokens.get(#principal(to));
            switch(existing_tokens) {
                case(null) {
                    user_tokens.put(#principal(to), [token_index_nat32]);
                };
                case(?existing_tokens) {
                    user_tokens.put(#principal(to), Array.append(existing_tokens, [token_index_nat32]));
                }
            };

            #Ok(mintReceipt);
        };

        public func total_supply(): Nat64 {
            Nat64.fromNat(tokens.size());
        };

        public func get_metadata(token_id: Nat64): MetadataResult {
            let token_id_nat = Nat64.toNat(token_id);
            let token_id_nat32 = Nat32.fromNat(token_id_nat);
            let fetched_tokens = tokens.get(token_id_nat32);

            switch(fetched_tokens) {
                case(null) {
                    #Err(#InvalidTokenId);
                };
                case(?fetched_tokens) {
                    #Ok(fetched_tokens.metadata_desc);
                }
            };
        };

    public func get_metadata_for_user(user: Principal): [ExtendedMetadataResult] {
        let _user_tokens = user_tokens.get(#principal(user));
        
        switch(_user_tokens) {
            case(null) {
                [];
            };
            
            case(?_user_tokens) {
                var temp_tokens: [ExtendedMetadataResult] = [];
                
                for (token_index in Array.vals(_user_tokens)) {
                    let _tokens = tokens.get(token_index);
                    
                    switch(_tokens) {
                        case(null) {};
                        case(?_tokens) {
                            let extendedMetadataResult: ExtendedMetadataResult = {
                                metadata_desc = _tokens.metadata_desc;
                                token_id = Nat64.fromNat(Nat32.toNat(token_index));
                            };

                            temp_tokens := Array.append(temp_tokens, [extendedMetadataResult]);
                        }
                    };
                };
                
                temp_tokens;
            };
        }
    };

    public func get_token_ids_for_user(user: Principal): [Nat64] {
        let _user_tokens = user_tokens.get(#principal(user));
        switch(_user_tokens) {
            case(null) {
                [];
            };
            case(?_user_tokens) {
                var temp_token_indexes: [Nat64] = [];
                for (token_index in Array.vals(_user_tokens)) {
                    let token_id_nat = Nat32.toNat(token_index);
                    let token_id_nat64 = Nat64.fromNat(token_id_nat);
                    temp_token_indexes := Array.append(temp_token_indexes, [token_id_nat64]);
                };

                temp_token_indexes;
            };
        }
    };

    public func owner_of(token_identifier: TokenIdentifier): OwnerResult {
        let _token = tokens.get(Types.into_token_index(token_identifier));
        switch(_token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?_token) {
                #Ok(_token.principal);
            };
        }
    };

    public func balance_of(user: User): Nat64 {
        let _tokens = user_tokens.get(user);
        switch(_tokens) {
            case(null) {
                0;
            };
            case(?_tokens) {
                Nat64.fromNat(_tokens.size());
            }
        }
    };

public func transfer(from: User, to: User, token_identifier: TokenIdentifier) { 
        let token_index = Types.into_token_index(token_identifier);
        var token_metadata = tokens.get(token_index);

        switch(token_metadata) {
            case(null) {};
            case(?token_metadata) {
                switch(to) {
                    case(#principal p) {
                        var token_metadata = {
                            var account_identifier = to;
                            var principal = to;
                        };
                    };
                    case(#address a) {};
                };
            }
        }
    }

    




    // pub fn transfer(&mut self, from: &User, to: &User, token_identifier: &TokenIdentifier) {
    //     // changeing token owner in the tokens map
    //     let token_index = into_token_index(token_identifier);
    //     let mut token_metadata = ledger()
    //         .tokens
    //         .get_mut(&token_index)
    //         .expect("unable to find token identifier in tokens");

    //     token_metadata.account_identifier = to.clone().into();
    //     token_metadata.principal = expect_principal(&to);

    //     // remove the token from the previous owner's tokenlist
    //     let from_token_indexes = ledger()
    //         .user_tokens
    //         .get_mut(&from)
    //         .expect("unable to find previous owner");
    //     from_token_indexes.remove(
    //         from_token_indexes
    //             .iter()
    //             .position(|token_index_in_vec| &token_index == token_index_in_vec)
    //             .expect("unable to find token index in users_token"),
    //     );
    //     if from_token_indexes.len() == 0 {
    //         ledger().user_tokens.remove(&from);
    //     }

    //     // add the token to the new owner's tokenlist
    //     ledger()
    //         .user_tokens
    //         .entry(to.clone())
    //         .or_default()
    //         .push(token_index);
    // }

    // pub fn bearer(&self, token_identifier: &TokenIdentifier) -> AccountIdentifierReturn {
    //     AccountIdentifierReturn::Ok(
    //         ledger()
    //             .tokens
    //             .get(&into_token_index(&token_identifier))
    //             .expect("unable to locate token id")
    //             .account_identifier
    //             .clone(),
    //     )
    // }

    // pub fn supply(&self, _token_identifier: &TokenIdentifier) -> BalanceReturn {
    //     BalanceReturn::Ok(ledger().tokens.len().into())
    // }

    // pub fn get_all_metadata_for_user(&self, user: &User) -> Vec<TokenMetadata> {
    //     ledger()
    //         .user_tokens
    //         .get(user)
    //         .unwrap_or(&vec![])
    //         .iter()
    //         .map(|token_index| {
    //             ledger()
    //                 .tokens
    //                 .get(token_index)
    //                 .expect("unable to find token index")
    //                 .clone()
    //         })
    //         .collect()
    // }

    // pub fn metadata(&self, token_identifier: &TokenIdentifier) -> MetadataReturn {
    //     MetadataReturn::Ok(
    //         ledger()
    //             .tokens
    //             .get(&into_token_index(&token_identifier))
    //             .expect("unable to find token index")
    //             .metadata
    //             .clone(),
    //     )
    // }

    // #[allow(dead_code)]
    // #[cfg(test)]
    // pub fn clear(&mut self) {
    //     self.tokens.clear();
    //     self.user_tokens.clear();
    // }

    }
}

// public func transfer(from: User, to: User, token_identifier: TokenIdentifier) {
    //     let token_index = Types.into_token_index(token_identifier);
    //     var token_metadata = tokens.get(token_index);

    //     switch(token_metadata) {
    //         case(null) {};
    //         case(?token_metadata) {
    //             switch(to) {
    //                 case(#principal p) {
    //                     var token_metadata = {
    //                         var account_identifier = to;
    //                         var principal = to;
    //                     };
    //                 };
    //                 case(#address a) {};
    //             };

    //             var from_token_indexes = user_tokens.get(from);

    //             switch(from_token_indexes) {
    //                 case(null) {};
    //                 case(?from_token_indexes) {
    //                     for (index in Array.vals(from_token_indexes)) {
    //                         if(index == token_index) {
    //                             Array.filter(from_token_indexes, func(i) {i == token_index});
    //                         };

    //                         if(from_token_indexes.size() == 0) {
    //                         user_tokens.delete(from);

    //                         user_tokens.get(to);
    //                     switch(user_tokens) {
    //                         case(null) {};
    //                         case(?user_tokens) {
    //                             user_tokens.put(to, Array.append(user_tokens, [token_index]));
    //                         }
    //                     }
    //                     };
    //                     }


                        
                        
                        
    //                 }
    //             }
    //         };
    //     }
// };