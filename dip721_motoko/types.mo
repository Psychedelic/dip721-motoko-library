import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";

module {
    public type Balance = Nat;
    public type Memo = Blob;
    public type SubAccount = [Nat8];
    public type TokenIdentifier = Text;
    public type TokenIndex = Nat32;
    public type AccountIdentifier = Text;
    public type Date = Nat64;
    public type TransactionId = Nat;
    
    public type AccountIdentifierReturn = {
        #Ok: AccountIdentifier;
        #Err: CommonError;
    };

    public type BalanceReturn = {
        #Ok: Balance;
        #Err: CommonError;
    };

    public type MetadataReturn = {
        #Ok: Metadata;
        #Err: CommonError;
    };

// BEGIN DIP-721 //

public type ApiError = {
    #Unauthorized;
    #InvalidTokenId;
    #ZeroAddress;
    #Other;
};

public type TxReceipt = {
    #Ok: Nat;
    #Err: ApiError;
};

public type InterfaceId = {
    #Approval;
    #TransactionHistory;
    #Mint;
    #Burn;
    #TransferNotification;
};

public type LogoResult = {
    logo_type: Text;
    data: Text;
};

public type OwnerResult = {
    #Ok: Principal;
    #Err: ApiError;
};

public type ExtendedMetadataResult = {
    metadata_desc: MetadataDesc;
    token_id: Nat64;
};

public type MetadataResult = {
    #Ok: MetadataDesc;
    #Err: ApiError;
};

public type MetadataDesc = [MetadataPart];

public type MetadataPart = {
    purpose: MetadataPurpose;
    key_val_data: [MetadataKeyVal];
    data: Blob;
};

public type MetadataPurpose = {
    #Preview;
    #Rendered;
};

public type MetadataKeyVal = {
    key: Text;
    val: MetadataVal;
};

public type MetadataVal = {
    #TextContent: Text;
    #BlobContent: Blob;
    #NatContent: Nat;
    #Nat8Content: Nat8;
    #Nat16Content: Nat16;
    #Nat32Content: Nat32;
    #Nat64Content: Nat64;
};

// public type TransactionResult = {
//     fee: Nat;
//     transaction_type: DIP721TransactionType;
// };

public type Transfer = {
    token_id: Nat64;
    from: Principal;
    to: Principal;
};

public type TransferFrom = {
    token_id: Nat64;
    from: Principal;
    to: Principal;
};

public type Approve  = {
    token_id: Nat64;
    from: Principal;
    to: Principal;
};

public type SetApprovalForAll = {
    from: Principal;
    to: Principal;
};

public type Mint = {
    token_id: Nat64;
    to: Principal;
};

public type Burn = {
    token_id: Nat64;
};

public type MintReceipt = {
    #Ok: MintReceiptPart;
    #Err: ApiError;
};

public type MintReceiptPart ={
    token_id: Nat64;
    id: Nat;
};

/// END DIP-721 ///

public type User = {
    #address: AccountIdentifier;
    #principal: Principal;
};

// impl From<User> for AccountIdentifierStruct {
//     fn from(user: User) -> Self {
//         match user {
//             User::principal(p) => p.into(),
//             User::address(a) => {
//                 AccountIdentifierStruct::from_hex(&a).expect("unable to decode account identifier")
//             }
//         }
//     }
// }

// impl From<User> for String {
//     fn from(user: User) -> Self {
//         match user {
//             User::principal(p) => Into::<AccountIdentifierStruct>::into(p).to_hex(),
//             User::address(a) => a,
//         }
//     }
// }

// impl From<Principal> for User {
//     fn from(principal: Principal) -> Self {
//         User::principal(principal)
//     }
// }

// impl From<AccountIdentifier> for User {
//     fn from(account_identifier: AccountIdentifier) -> Self {
//         User::address(account_identifier)
//     }
// }
// --------------

public func into_token_index(token_identifier: TokenIdentifier): TokenIndex {
    assert(token_identifier.size() > 0);
        let chars = token_identifier.chars();

        var num : Nat = 0;
        for (v in chars){
            let charToNum = Nat32.toNat(Char.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };

        Nat32.fromNat(num);
};

public func into_token_identifier(token_index: TokenIndex): TokenIdentifier {
    Nat32.toText(token_index);
};

public type TransferRequest = {
    amount: Balance;
    from: User;
    memo: Memo;
    notify: Bool;
    subaccount: ?SubAccount;
    to: User;
    token: TokenIdentifier;
};

public type TransferError = {
    #CannotNotify: AccountIdentifier;
    #InsufficientBalance;
    #InvalidToken: TokenIdentifier;
    #Other: Text;
    #Rejected;
    #Unauthorized: AccountIdentifier;
};

public type TransferResponse = {
    #Ok: Balance; 
    #Err: TransferError;
};

public type MintRequest = {
    metadata: ?MetadataContainer;
    to: User;
};

public type Metadata = {
    #fungible: FungibleMetadata;
    #nonfungible: ?MetadataContainer;
};

public type FungibleMetadata = {
    name: Text;
    symbol: Text;
    decimals: Nat8;
    metadata: ?MetadataContainer;
};

public type MetadataContainer = {
    #data: [MetadataValue];
    #blob: Blob;
    #json: Text;
};

public type MetadataValue = (Text, Value);

public type Value = {
    #text: Text;
    #blob: Blob;
    #nat: Nat;
    #nat8: Nat8;
};

public type CommonError = {
    #InvalidToken: TokenIdentifier;
    #Other: Text;
};

public type TokenMetadata = {
    var account_identifier: AccountIdentifier;
    var metadata: Metadata;
    var token_identifier: TokenIdentifier;
    var principal: Principal;
    var metadata_desc: MetadataDesc;
};

// public type TokenLevelMetadata = {
//     owner: ?Principal;
//     symbol: Text;
//     name: Text;
//     history: ?Principal;
// };

// public type Transaction = {
//     txid: TransactionId;
//     request: TransferRequest;
//     date: Date;
// };

// type TransactionRequestFilter = {
//     #txid: TransactionId;
//     #user: User;
//     #date: (Date, Date);
//     #page: (Nat, Nat);
//     #all;
// };

// public type TransactionsRequest = {
//     query: TransactionRequestFilter;
//     token: TokenIdentifier;
// }

// fn get_detail_value(key: &str, details: Vec<(String, DetailValue)>) -> Option<DetailValue> {
//     let entry = details.iter().find(|&x| x.0.as_str() == key);
//     match entry {
//         Some(x) => Some(x.1.clone()),
//         None => None,
//     }
// }

// public type TxLog = {
//     tx_records: VecDeque<IndefiniteEvent>,
// }

// #[derive(CandidType)]
// public struct StableStorageBorrowed<'a> {
//     public ledger: &'a Ledger,
//     public token: &'a TokenLevelMetadata,
//     public fleek: &'a Fleek,
// }

// #[derive(CandidType, Deserialize)]
// public struct StableStorage {
//     public ledger: Ledger,
//     public token: TokenLevelMetadata,
//     public fleek: Fleek,
// }
}