import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Bool "mo:base/Bool";
import List "mo:base/List";

actor {
    type Profile = {
        username: Text;
        bio: Text;
        saldo: Nat;
        carrito: List.List<Product>;
    };

    type Product = {
        nombre: Text;
        precio: Nat;
    };

    type GetProfileError = {
        #userNotAuthenticated;
        #profileNotFound;
    };

    type GetProfileResponse = Result.Result<Profile, GetProfileError>;

    type CreateProfileError = {
        #profileAlreadyExists;
        #userNotAuthenticated;
    };

    type CreateProfileResponse = Result.Result<Bool, CreateProfileError>;

    type UpdateProfileError = {
        #userNotAuthenticated;
        #profileNotFound;
    };

    type UpdateProfileResponse = Result.Result<Bool, UpdateProfileError>;

    type DeleteProfileError = {
        #userNotAuthenticated;
        #profileNotFound;
    };

    type DeleteProfileResponse = Result.Result<Bool, DeleteProfileError>;

    type AddToCartError = {
        #userNotAuthenticated;
        #profileNotFound;
    };

    type AddToCartResponse = Result.Result<Bool, AddToCartError>;

    type RemoveFromCartError = {
        #userNotAuthenticated;
        #profileNotFound;
        #productNotFound;
    };

    type RemoveFromCartResponse = Result.Result<Bool, RemoveFromCartError>;

    type PurchaseError = {
        #userNotAuthenticated;
        #profileNotFound;
        #insufficientFunds;
    };

    type PurchaseResponse = Result.Result<Bool, PurchaseError>;

    type DeductFundsError = {
        #userNotAuthenticated;
        #profileNotFound;
        #insufficientFunds;
    };

    type DeductFundsResponse = Result.Result<Bool, DeductFundsError>;

    let profiles = HashMap.HashMap<Principal, Profile>(0, Principal.equal, Principal.hash);

    public query ({caller}) func getProfile(): async GetProfileResponse {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        switch profile {
            case (?profile) {
                return #ok(profile);
            };
            case null {
                return #err(#profileNotFound);
            };
        }
    };

    public shared ({caller}) func createProfile(username: Text, bio: Text): async CreateProfileResponse {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        if (profile != null) return #err(#profileAlreadyExists);

        let newProfile: Profile = {
            username = username;
            bio = bio;
            saldo = 0;
            carrito = List.nil<Product>();  // Inicializamos el carrito vacío
        };

        profiles.put(caller, newProfile);

        return #ok(true);
    };

    public shared ({caller}) func updateProfile(username: Text, bio: Text): async UpdateProfileResponse {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        switch profile {
            case (?profile) {
                let updatedProfile: Profile = {
                    username = username;
                    bio = bio;
                    saldo = profile.saldo;
                    carrito = profile.carrito;
                };
                profiles.put(caller, updatedProfile);
                return #ok(true);
            };
            case null {
                return #err(#profileNotFound);
            };
        }
    };

    public query ({caller}) func getSaldo(): async Result.Result<Nat, GetProfileError> {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        switch profile {
            case (?profile) {
                return #ok(profile.saldo);
            };
            case null {
                return #err(#profileNotFound);
            };
        }
    };

    public shared ({caller}) func setSaldo(amount: Nat): async Result.Result<Bool, GetProfileError> {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        switch profile {
            case (?profile) {
                let updatedProfile: Profile = {
                    username = profile.username;
                    bio = profile.bio;
                    saldo = profile.saldo + amount;
                    carrito = profile.carrito;
                };
                profiles.put(caller, updatedProfile);
                return #ok(true);
            };
            case null {
                return #err(#profileNotFound);
            };
        }
    };

    

    

    public shared ({caller}) func deductFunds(amount: Nat): async DeductFundsResponse {
        if (Principal.isAnonymous(caller)) return #err(#userNotAuthenticated);

        let profile = profiles.get(caller);

        switch profile {
            case (?profile) {
                if (profile.saldo < amount) {
                    return #err(#insufficientFunds);
                };
                let updatedProfile: Profile = {
                    username = profile.username;
                    bio = profile.bio;
                    saldo = profile.saldo - amount;
                    carrito = profile.carrito;
                };
                profiles.put(caller, updatedProfile);
                return #ok(true);
            };
            case null {
                return #err(#profileNotFound);
            };
        }
    };
}
