import AccountIdentifier "./resources/account_identifier";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Types "./types";
import Utils "./utils";
import notifyService "./notify_service";

shared ({ caller = owner }) actor class DIP721() = this {

    type TokenIndex = Types.TokenIndex;
    type TokenMetadata = Types.TokenMetadata;
    type User = Types.User;
    type TokenLevelMetadata = Types.TokenLevelMetadata;
    type LogoResult = Types.LogoResult;

    private stable var isInitialized: Bool = false;
    private stable var txId:Nat = 0;
    private stable var tokenIndex: TokenIndex = 0;

    private stable var tokenLevelMetadata: TokenLevelMetadata = {
        owner = null;
        symbol = "";
        name = "";
        history = null;
    };

    private stable var logo: LogoResult = {
        logo_type = "not set";
        data = "not set";
    };

    private stable var tokenEntries : [(TokenIndex, TokenMetadata)] = [];
    private stable var userTokenEntries : [(User, [TokenIndex])] = [];
    private stable var approvedEntries : [(TokenIndex, Principal)] = [];
    private stable var operatorEntries : [(TokenIndex, [Principal])] = [];

    private var tokens = HashMap.fromIter<TokenIndex,TokenMetadata>(tokenEntries.vals(), 0, Nat32.equal, func(v) {v});
    private var userTokens = HashMap.fromIter<User, Buffer.Buffer<TokenIndex>>(Utils.mapUserTokensForHashmap(userTokenEntries).vals(), 0, Utils.compareUser, Utils.hashUser);
    private var approved = HashMap.fromIter<TokenIndex, Principal>(approvedEntries.vals(), 0, Nat32.equal, func(v) {v});
    private var operators = HashMap.fromIter<TokenIndex, Buffer.Buffer<Principal>>(Utils.mapOperatorsForHashmap(operatorEntries).vals(), 0, Nat32.equal, func(v) {v});

    system func preupgrade() {
        tokenEntries := Iter.toArray(tokens.entries());
        userTokenEntries := Utils.mapUserTokenForUpgrade(userTokens);
        approvedEntries := Iter.toArray(approved.entries());
        operatorEntries := Utils.mapOperatorsForUpgrade(operators);
    };

    system func postupgrade() {
        tokenEntries := [];
        userTokenEntries := [];
        approvedEntries := [];
        operatorEntries := [];
    };

    public shared({caller}) func init(symbol: Text, name: Text, history: Principal) {
        assert(caller == owner and isInitialized == false);
        
        tokenLevelMetadata := {
            owner = ?caller;
            symbol = symbol;
            name = name;
            history = ?history;
        };

        isInitialized := true;
    };

    //Count of all NFTs assigned to user.
    public query func balanceOfDip721(user: Principal): async Nat64 {
        let tokens = userTokens.get(#principal(user));
        
        switch(tokens) {
            case(null) {
                0;
            };
            case(?tokens) {
                let _tokens = tokens.size();
                Nat64.fromNat(_tokens);
            }
        }
    };

    // Returns the owner of the NFT associated with token_id. Returns ApiError.InvalidTokenId, if the token id is invalid.
    public query func ownerOfDip721(token_id: Nat64): async Types.OwnerResult {
        let token = tokens.get(Utils.toTokenIndex(token_id));
        
        switch(token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?token) {
                #Ok(token.principal);
            };
        }
    };

//     // Safely transfers token_id token from user from to user to. 
//     // If to is zero, then ApiError.ZeroAddress should be returned. 
//     // If the caller is neither the owner, nor an approved operator, 
//     // nor someone approved with the approveDip721 function, 
//     // then ApiError.Unauthorized should be returned. If token_id is not valid, 
//     // then ApiError.InvalidTokenId is returned.
    public shared({ caller }) func safeTransferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {
        if(Utils.isAnonymous(to)){
            return #Err(#ZeroAddress);
        };

        let isApproved = _isApproved(Utils.toTokenIndex(token_id), caller);
        let isOperator = _isOperator(Utils.toTokenIndex(token_id), caller);
        let isOwner = _ownerOfDip721(token_id);

        switch(isOwner){
            case(#Ok(value)){
                if(isApproved or isOperator){
                    _setOwnerOfDip721(token_id, caller);
                    txId := txId+1;
                    #Ok(txId);
                }else {
                    return #Err(#Unauthorized);
                };
            };
            case(#Err(value)){
                return #Err(value);
            };
        };
    };

    public shared({ caller }) func safeTransferFromNotifyDip721(from: Principal, to: Principal, token_id: Nat64, data: [Nat8]): async Types.TxReceipt {
        if(Utils.isAnonymous(to)){
            return #Err(#ZeroAddress);
        };

        let isApproved = _isApproved(Utils.toTokenIndex(token_id), caller);
        let isOperator = _isOperator(Utils.toTokenIndex(token_id), caller);
        let isOwner = _ownerOfDip721(token_id);
        
        switch(isOwner){
            case(#Ok(value)){
                if(isApproved or isOperator){
                    _setOwnerOfDip721(token_id, caller);
                    txId := txId+1;
                    let _txId = txId;
                    await notifyService.notify(caller,from,token_id,data);
                    #Ok(_txId);
                }else {
                    return #Err(#Unauthorized);
                };
            };
            case(#Err(value)){
                return #Err(value);
            };
        };
    };

    //Identical to safeTransferFromDip721 except that this function doesn't check whether the to is a zero address or not.
    public shared({ caller }) func transferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {
        let isApproved = _isApproved(Utils.toTokenIndex(token_id), caller);
        let isOperator = _isOperator(Utils.toTokenIndex(token_id), caller);
        let isOwner = _ownerOfDip721(token_id);
        
        switch(isOwner){
            case(#Ok(value)){
                if(isApproved or isOperator){
                    _setOwnerOfDip721(token_id, caller);
                    txId := txId+1;
                    #Ok(txId);
                }else {
                    return #Err(#Unauthorized);
                };
            };
            case(#Err(value)){
                return #Err(value);
            };
        };
    };

    public shared({ caller }) func transferFromNotifyDip721(from: Principal, to: Principal, token_id: Nat64, data: [Nat8]): async Types.TxReceipt {
        let isApproved = _isApproved(Utils.toTokenIndex(token_id), caller);
        let isOperator = _isOperator(Utils.toTokenIndex(token_id), caller);
        let isOwner = _ownerOfDip721(token_id);
        
        switch(isOwner){
            case(#Ok(value)){
                if(isApproved or isOperator){
                    _setOwnerOfDip721(token_id, caller);
                    txId := txId+1;
                    let _txId = txId;
                    await notifyService.notify(caller,from,token_id,data);
                    #Ok(_txId);
                }else {
                    return #Err(#Unauthorized);
                };
            };
            case(#Err(value)){
                return #Err(value);
            };
        };
    };

    // Returns the interfaces supported by this smart contract.
    public query func supportedInterfacesDip721(): async [Types.InterfaceId] {
        [#Mint, #TransactionHistory];
    };

    // Returns the logo of the NFT contract.
    public query func logoDip721(): async Types.LogoResult {
        logo;
    };

    // Set the logo of the NFT contract, the contract must be initialized and 
    // only the owner of the contract can set the image
    
    // "logo_type" refers to the mime-type, "data" is the base64 encoded image
    public query({caller}) func setLogoDip721(logo_type: Text, data: Text): async () {
        let owner = tokenLevelMetadata.owner;

        switch(owner) {
            case(null) {};
            case(?owner){
            assert(isInitialized and caller == owner);
                logo := {
                    logo_type = logo_type;
                    data = data;
                };
            };
        };
    };

    // Returns the name of the NFT contract.
    public query func nameDip721(): async Text {
        tokenLevelMetadata.name;
    };

    // Returns the symbol of the NFT contract.
    public query func symbolDip721(): async Text {
        tokenLevelMetadata.symbol;
    };

    // Returns the total current supply of NFT tokens. 
    // NFTs that are minted and later burned explictely or 
    // sent to the zero address should also count towards totalSupply.
    public query func totalSupplyDip721 (): async Nat64 {
        let _tokens = tokens.size();
        Nat64.fromNat(_tokens);
    };

    // Returns the metadata for token_id. Returns ApiError.InvalidTokenId, if the token_id is invalid.
    public query func getMetadataDip721(token_id: Nat64): async Types.MetadataResult {
        let token = tokens.get(Utils.toTokenIndex(token_id));
        
        switch(token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?token) {
                #Ok(token.metadata_desc);
            };
        }
    };

    // Returns all the metadata for the coins user owns.
    public query func getMetadataForUserDip721(user: Principal): async [Types.ExtendedMetadataResult] {
        let _userTokens = userTokens.get(#principal(user));
        
        switch(_userTokens) {
            case(null) {
                [];
            };
            case(?_userTokens) {
                let _extendedMetaDataResult = Buffer.Buffer<Types.ExtendedMetadataResult>(0);
                
                for(tokenId in _userTokens.vals()) {
                    let _token = tokens.get(tokenId);
                    
                    switch(_token) {
                        case(null) {};
                        case(?_token) {
                            _extendedMetaDataResult.add({
                                metadata_desc = _token.metadata_desc; 
                                token_id = Utils.toTokenId(tokenId);
                                });
                            };
                        };
                    };

                _extendedMetaDataResult.toArray();
            };
        }
    };

    private func _isApproved(tokenIndex:TokenIndex, user:Principal): Bool {
        let exist = approved.get(tokenIndex);
        
        switch(exist) {
            case(?exist){
                return true;
            };
            case(null) {
                return false;
            };
        };
    };

    private func _isOperator(tokenIndex:TokenIndex, user:Principal): Bool {
        let exist = operators.get(tokenIndex);
        
        switch(exist) {
            case(?exist){
                for(op in exist.vals()){
                    if(op == user) {return true}
                };
            };
            case(null) {
                return false;
            };
        };

        return false;
    };

    private func _ownerOfDip721(token_id: Nat64): Types.OwnerResult {
        let token = tokens.get(Utils.toTokenIndex(token_id));
        
        switch(token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?token) {
                #Ok(token.principal);
            };
        }
    };

    private func _setOwnerOfDip721(token_id: Nat64, owner: Principal) {
        let token = tokens.get(Utils.toTokenIndex(token_id));
        
        switch(token) {
            case(null) {};
            case(?token) {
                let _token = {
                    account_identifier = AccountIdentifier.fromPrincipal(owner,null);
                    metadata = token.metadata;
                    token_identifier = token.token_identifier;
                    principal = owner;
                    metadata_desc = token.metadata_desc;
                };
                tokens.put(Utils.toTokenIndex(token_id),_token);
            };
        }
    };

    // Change or reaffirm the approved address for an NFT. 
    // The zero address indicates there is no approved address. 
    // Only one user can be approved at a time to manage token_id. 
    // Approvals given by the approveDip721 function are independent from 
    // approvals given by the setApprovalForAllDip721. 
    // Returns ApiError.InvalidTokenId, if the token_id is not valid. 
    // Returns ApiError.Unauthorized in case the caller neither owns 
    // token_id nor he is an operator approved by a call to the setApprovalForAll function.
    public func approveDip721(user: Principal, token_id: Nat64): async Types.TxReceipt {
        if(Utils.isAnonymous(user)){
            return #Err(#ZeroAddress);
        };

        let tokenId = Utils.toTokenIndex(token_id);
        let token = tokens.get(tokenId);

        switch(token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?token) {
                let approvedToken = approved.get(Utils.toTokenIndex(token_id));
                
                switch(approvedToken) {
                    case(null) {
                        if(token.principal != user) {
                            return #Err(#Unauthorized);
                        };

                        approved.put(tokenId, user);
                        txId := txId + 1;
                        #Ok(txId);
                    };
                    case(approvedToken) {
                        #Err(#Unauthorized);
                    };
                };
            };
        };
    };

    // Enable or disable an operator to manage all of the tokens for the caller of this function. 
    // Multiple operators can be given permission at the same time. w
    // Approvals granted by the approveDip721 function are independent from the approvals 
    // granted by setApprovalForAll function. The zero address indicates there are no approved operators.
    public shared({caller}) func setApprovalForAllDip721(operator: Principal, isApproved: Bool): async Types.TxReceipt {
        if(Utils.isAnonymous(operator)){
            return #Err(#ZeroAddress);
        };

        let _userTokens = userTokens.get(#principal(caller));
        
        switch(_userTokens) {
            case(null) {
                #Err(#Other);
            };
            case(?_userTokens) {
                    
                    for(tokenId in _userTokens.vals()) {
                        let _exisingPrincipals = operators.get(tokenId);
                        var _buffer: Buffer.Buffer<Principal> = Buffer.Buffer(0);
                        
                        switch(_exisingPrincipals) {
                            case(null) {
                                if(isApproved == true) {
                                    _buffer.add(operator);
                                    operators.put(tokenId, _buffer);
                                    txId := txId + 1;
                                } else {
                                    // There are no existing principals to remove;
                                    return #Err(#Other);
                                }
                            };

                            case(?_exisingPrincipals) {
                                _buffer := _exisingPrincipals;
                                if(isApproved == true) {
                                    _buffer.add(operator);
                                    operators.put(tokenId, _buffer);
                                    txId := txId + 1;
                                } else {
                                    let _existingOperator = Array.find<Principal>(_exisingPrincipals.toArray(), func (p) { p == operator});
                                    switch(_existingOperator) {
                                        case(null) {
                                            // There are no existing principals to remove;
                                            return #Err(#Other);
                                        };
                                        case(?_existingOperator) {
                                            operators.put(tokenId, Utils.removePrincipalFromBuffer(operator, _buffer));
                                            txId := txId + 1;
                                        }
                                    }
                                }
                            };
                        }
                    };
                    
                #Ok(txId);
            };
        };
    };

    // Returns the approved user for token_id. Returns zero address if the token_id is invalid.
    public query func getApprovedDip721(token_id: Nat64): async Principal {
        let _approved = approved.get(Utils.toTokenIndex(token_id));

        switch(_approved) {
            case(null) {
                Principal.fromText(Utils.anonymousPrincipal);
            };
            case(?_approved) {
                _approved;
            };
        };
    };

    // Returns true if the given operator is an approved operator for all the tokens owned by the caller, returns false otherwise
    public query({caller}) func isApprovedForAllDip721(operator: Principal): async Bool {
        let _userTokens = userTokens.get(#principal(caller));
        var _tokensWithOperator = 0;
        
        switch(_userTokens) {
            case(null) {
                return false;
            };
            case(?_userTokens) {
        
                for (tokenId in _userTokens.vals()) {
                    let _operators = operators.get(tokenId);
        
                    switch(_operators) {
                        case(null) {};
                        case(?_operators) {
                            let operatorsArray = Iter.toArray(_operators.vals());
                            let _operator = Array.find<Principal>(operatorsArray, func (o) {o == operator});
        
                            switch(_operator) {
                                case(null) {};
                                case(?_operator) {
                                    _tokensWithOperator := _tokensWithOperator + 1;
                                }
                            }
                        };
                    }
                };
                _tokensWithOperator == _userTokens.size();
            };
        };
    };

    // Mint an NFT for principal to. 
    // The parameter blobContent is non zero, if the NFT contract embeds the NFTs in the smart contract. 
    // Implementations are encouraged to only allow minting by the owner of the smart contract. 
    // Returns ApiError.Unauthorized, if the caller doesn't have the permission to mint the NFT.
    public shared({caller}) func mintDip721(to: Principal, metadata: Types.Metadata, blobContent: Blob): async Types.MintReceipt {
        if(?caller == tokenLevelMetadata.owner) {
            return #Err(#Unauthorized);
        };

        if(Utils.isAnonymous(to)){
            return #Err(#ZeroAddress);
        };

        // Check this -> metadata_desc
        let tokenMetaData: Types.TokenMetadata = {
            account_identifier = AccountIdentifier.fromPrincipal(to,null);
            metadata = metadata;
            token_identifier = Utils.tokenIndexToTokenIdentifier(tokenIndex);
            principal = to;
            metadata_desc = [{
                purpose = #Preview;
                key_val_data = [];
                data = blobContent;
            }];
        };

        let _existingTokens = userTokens.get(#principal(to));
        var _tokenBuffer: Buffer.Buffer<TokenIndex> = Buffer.Buffer(0);
        switch(_existingTokens) {
            case(null) {
                _tokenBuffer.add(tokenIndex);
            };
            case(?_existingTokens) {
                _tokenBuffer := _existingTokens;
                _tokenBuffer.add(tokenIndex);
            };
        };
            tokens.put(tokenIndex, tokenMetaData);
            userTokens.put(#principal(to), _tokenBuffer);

        let mintReceipt: Types.MintReceiptPart = {
            token_id = Utils.toTokenId(tokenIndex);
            id = txId;
        };
        txId := txId + 1;
        tokenIndex := tokenIndex + 1;

        #Ok(mintReceipt);

    };

    // Burn an NFT identified by token_id. Implementations are encouraged to only allow burning by the owner of the token_id. 
    // Returns ApiError.Unauthorized, if the caller doesn't have the permission to burn the NFT. Returns ApiError.InvalidTokenId, 
    // if the provided token_id doesn't exist.
    public shared({caller}) func burnDip721(token_id: Nat64): async Types.TxReceipt {
        let _token = tokens.get(Utils.toTokenIndex(token_id));

        switch(_token) {
            case(null) {
                #Err(#InvalidTokenId);
            };
            case(?_token) {
                let _userTokens = userTokens.get(#principal(caller));
                
                switch(_userTokens) {
                    case(null) {
                        #Err(#Unauthorized);
                    };
                    case(?_userTokens) {
                        let _userTokensArray = _userTokens.toArray();
                        let _fetchedToken = Array.find<TokenIndex>(_userTokensArray, func(t) {t == Utils.tokenIdentifierToIndex(_token.token_identifier) });
                        
                        switch(_fetchedToken) {
                            case(null) {
                                #Err(#Unauthorized);
                            };
                            case(?_fetchedToken) {
                                #Ok(Nat32.toNat(_fetchedToken));
                            };
                        };
                    };
                };
            };
        }

    };

//     // transferFromNotifyDip721 and safeTransferFromNotifyDip721 functions can 
//     // - upon successfull NFT transfer 
//     // - notify other smart contracts that adhere to the following interface.
//     // caller is the entity that called the transferFromNotifyDip721 or safeTransferFromNotifyDip721 function, and from is the previous owner of the NFT.
    
//     // ??????
//     // public func onDIP721Received: (address caller, address from, uint256 token_id, bytes data) -> ();
//     // ?????

}