import Principal "mo:base/Principal";
import Types "./dip721Types";

shared(msg) actor class DIP721() {

   public query func balanceOfDip721(user: Principal): async Nat64 {
        0;
   };

   public query func ownerOfDip721(token_id: Nat64): async Types.OwnerResult {
       #Ok(Principal.fromText(""));
   };
   
   public func safeTransferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {
        #Ok(0);
   };
   
   public func transferFromDip721(from: Principal, to: Principal, token_id: Nat64): async Types.TxReceipt {
        #Ok(0);
   };

   public query func supportedInterfacesDip721(): async [Types.InterfaceId] {
        [];
   };
   
   public query func logoDip721(): async Types.LogoResult {
       {
        logo_type = "";
        data = ""; 
       }
   };
   
   public query func nameDip721(): async Text {
        "";
   };
   
   public query func symbolDip721(): async Text {
        "";
   };
   
   public query func totalSupplyDip721(): async Nat64 {
        0;
   };
   
   public query func getMetadataDip721(token_id: Nat64): async Types.MetadataResult {
       #Ok([]);
   };
   
   public query func getMaxLimitDip721(): async Nat16 {
       0;
   };
   
   public func mintDip721(to: Principal, metadata: Types.MetadataDesc): async Types.MintReceipt {
       #Ok({
        token_id = 0;
        id = 0;
       });
   };

   public func getMetadataForUserDip721(user: Principal): async [Types.ExtendedMetadataResult] {
        [];
   };
   
   public query func getTokenIdsForUserDip721(user: Principal): async [Nat64] {
       return [];
   };
}