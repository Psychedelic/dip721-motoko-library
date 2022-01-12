import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";

module {
    public type TokenIdentifier = Text;
    public type TokenIndex = Nat32;
    public type AccountIdentifier = Text;

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

    public type MintReceipt = {
        #Ok: MintReceiptPart;
        #Err: ApiError;
    };

    public type MintReceiptPart ={
        token_id: Nat64;
        id: Nat;
    };

    public type User = {
        #address: AccountIdentifier;
        #principal: Principal;
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

    public type TokenMetadata = {
        account_identifier: AccountIdentifier;
        metadata: Metadata;
        token_identifier: TokenIdentifier;
        principal: Principal;
        metadata_desc: MetadataDesc;
    };

    public type TokenLevelMetadata = {
        owner: ?Principal;
        symbol: Text;
        name: Text;
        history: ?Principal;
    };
}