import Types "./Types";
import Buffer "mo:base/Buffer";

actor {
    //Count of all NFTs assigned to user.
    public query func balanceOfDip721(user: Principal): async Nat64 {

    };

    // Returns the owner of the NFT associated with token_id. Returns ApiError.InvalidTokenId, if the token id is invalid.
    public query func ownerOfDip721(token_id: Nat64): async Types.OwnerResult {

    };

    // Safely transfers token_id token from user from to user to. 
    // If to is zero, then ApiError.ZeroAddress should be returned. 
    // If the caller is neither the owner, nor an approved operator, 
    // nor someone approved with the approveDip721 function, 
    // then ApiError.Unauthorized should be returned. If token_id is not valid, 
    // then ApiError.InvalidTokenId is returned.
    public func safeTransferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {

    };

    // Identical to safeTransferFromDip721 except that this function doesn't check whether the to is a zero address or not.
    public func transferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {

    };

    // Returns the interfaces supported by this smart contract.
    public query func supportedInterfacesDip721(): async Buffer.Buffer<Types.InterfaceId> {

    };

    // Returns the logo of the NFT contract.
    public query func logoDip721(): async Types.LogoResult {

    };

    // Returns the name of the NFT contract.
    public query func nameDip721(): async Text {

    };

    // Returns the symbol of the NFT contract.
    public query func symbolDip721(): async Text {

    };

    // Returns the total current supply of NFT tokens. 
    // NFTs that are minted and later burned explictely or 
    // sent to the zero address should also count towards totalSupply.
    public query func totalSupplyDip721 (): async Nat64 {

    };

    // Returns the metadata for token_id. Returns ApiError.InvalidTokenId, if the token_id is invalid.
    public query func getMetadataDip721(token_id: Nat64): async Types.MetadataResult {

    };

    // Returns all the metadata for the coins user owns.
    public func getMetadataForUserDip721(user: Principal): async Buffer.Buffer<Types.ExtendedMetadataResult> {

    };

    // Same as safeTransferFromDip721, but to is treated as a smart contract that implements the Notification interface. 
    // Upon successful transfer onDIP721Received is called with data.
    public func safeTransferFromNotifyDip721(from: Principal, to: Principal, token_id: Nat64, data: Buffer.Buffer<Nat8>): async Types.TxReceipt {

    };

    // Same as transferFromDip721, but to is treated as a smart contract that implements the Notification interface. 
    // Upon successful transfer onDIP721Received is called with data.
    public func transferFromNotifyDip721(from: Principal, to: Principal, token_id: Nat64, data: Buffer.Buffer<Nat8>): async Types.TxReceipt {

    };

    // Change or reaffirm the approved address for an NFT. 
    // The zero address indicates there is no approved address. 
    // Only one user can be approved at a time to manage token_id. 
    // Approvals given by the approveDip721 function are independent from 
    // approvals given by the setApprovalForAllDip721. 
    // Returns ApiError.InvalidTokenId, if the token_id is not valid. 
    // Returns ApiError.Unauthorized in case the caller neither owns 
    // token_id nor he is an operator approved by a call to the setApprovalForAll function.
    public query func approveDip721(user: Principal, token_id: Nat64): async Types.TxReceipt {

    };

    // Enable or disable an operator to manage all of the tokens for the caller of this function. 
    // Multiple operators can be given permission at the same time. 
    // Approvals granted by the approveDip721 function are independent from the approvals 
    // granted by setApprovalForAll function. The zero address indicates there are no approved operators.
    public func setApprovalForAllDip721(operator: Principal, isApproved: Bool): async Types.TxReceipt {

    };

    // Returns the approved user for token_id. Returns ApiError.InvalidTokenId if the token_id is invalid.
    public query func getApprovedDip721(token_id: Nat64): async Types.TxReceipt {

    };

    // Returns true if the given operator is an approved operator for all the tokens owned by the caller, returns false otherwise.
    public query func isApprovedForAllDip721(operator: Principal): Bool {

    };

    // Mint an NFT for principal to. 
    // The parameter blobContent is non zero, if the NFT contract embeds the NFTs in the smart contract. 
    // Implementations are encouraged to only allow minting by the owner of the smart contract. 
    // Returns ApiError.Unauthorized, if the caller doesn't have the permission to mint the NFT.
    public func mintDip721(to: Principal, metadata: Metadata, blobContent: Blob): async Types.MintReceipt {
        
    };

    // Burn an NFT identified by token_id. Implementations are encouraged to only allow burning by the owner of the token_id. 
    // Returns ApiError.Unauthorized, if the caller doesn't have the permission to burn the NFT. Returns ApiError.InvalidTokenId, 
    // if the provided token_id doesn't exist.
    public func burnDip721(token_id: Nat64): async Types.TxReceipt {

    };

    // transferFromNotifyDip721 and safeTransferFromNotifyDip721 functions can 
    // - upon successfull NFT transfer 
    // - notify other smart contracts that adhere to the following interface.
    // caller is the entity that called the transferFromNotifyDip721 or safeTransferFromNotifyDip721 function, and from is the previous owner of the NFT.
    
    // ??????
    // public func onDIP721Received: (address caller, address from, uint256 token_id, bytes data) -> ();
    // ?????

}