module {
    public type ApiError = {
   #Unauthorized;
   #InvalidTokenId;
   #ZeroAddress;
   #Other;
};

 public type OwnerResult = {
   #Err: ApiError;
   #Ok: Principal;
 };

 public type TxReceipt = {
   #Err: ApiError;
   #Ok: Nat;
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

 public type ExtendedMetadataResult = {
     metadata_desc: MetadataDesc;
     token_id: Nat64;
 };

 public type MetadataResult = {
   #Err: ApiError;
   #Ok: MetadataDesc;
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
    #TextContent : Text;
    #BlobContent : Blob;
    #NatContent : Nat;
    #Nat8Content: Nat8;
    #Nat16Content: Nat16;
    #Nat32Content: Nat32;
    #Nat64Content: Nat64;
  };

 public type TransactionResult = {
     fee: Nat;
     transaction_type: TransactionType;
 };

 public type TransactionType = {
      #Transfer: {
        token_id: Nat64;
        from: Principal;
        to: Principal;
     };
     #TransferFrom: {
          token_id: Nat64;
          from: Principal;
          to: Principal;
      };
      #Approve: {
          token_id: Nat64;
          from: Principal;
          to: Principal;
       };
      #SetApprovalForAll: {
          from: Principal;
          to: Principal;
       };
      #Mint: {
          token_id: Nat64;
          to: Principal;
       };
      #Burn: {
          token_id: Nat64;
       };
 };

 public type MintReceipt = {
   #Err: ApiError;
   #Ok: MintReceiptPart;
 };

 public type MintReceiptPart = {
   token_id: Nat64;
   id: Nat;
  };


public type Balance = Nat;
public type Memo = Blob;
public type SubAccount = [Nat8];
public type TokenIdentifier = Text;
public type TokenIndex = Nat32;
public type AccountIdentifier = Text;

public type User = {
   #address: AccountIdentifier;
   #principal: Principal;
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

 public type TransferResponse = {
   #Err: {
      #CannotNotify: AccountIdentifier;
      #InsufficientBalance;
      #InvalidToken: TokenIdentifier;
      #Other: Text;
      #Rejected;
      #Unauthorized: AccountIdentifier;
    };
   #Ok: Balance;
 };

 public type MintRequest = {
   metadata: ?MetadataContainer;
   to: User;
 };

 public type CommonError = {
   #InvalidToken: TokenIdentifier;
   #Other: Text;
 };

 public type AccountIdentifierReturn = {
   #Err: CommonError;
   #Ok: AccountIdentifier;
 };

 public type BalanceReturn = {
   #Err: CommonError;
   #Ok: Balance;
 };

 public type MetadataReturn = {
   #Err: CommonError;
   #Ok: Metadata;
 };

 public type TokenMetadata = {
   account_identifier: AccountIdentifier;
   metadata: Metadata;
   token_identifier: TokenIdentifier;
   principal: Principal;
 };

 public type Metadata = {
   #fungible: {
      name: Text;
      symbol: Text;
      decimals: Nat8;
      metadata: ?MetadataContainer;
    };
   #nonfungible: ?MetadataContainer;
 };

public type MetadataContainer = {
    #data : [MetadataValue];
    #blob : Blob;
    #json : Text;
  };

public type MetadataValue = {
      text: Value
      };

public type Value = {
    #text : Text;
    #blob : Blob;
    #nat : Nat;
    #nat8: Nat8;
  };

 public type TransactionId = Nat;
 public type Date = Nat64;

 public type Transaction = {
   txid: TransactionId;
   request: TransferRequest;
   date: Date;
 };

 public type TrasactionsResult = {
   #Err: CommonError;
   #Ok: [Transaction];
 };
}